terraform {
  required_version = "~>1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  custom_message_lambda_filename = "${path.module}/lambdas/custom-message-lambda.auto.zip"
  custom_message_lambda_name     = "custom_message_lambda__auto__"
}

################################################################################
# Secrets and parameters
################################################################################

data "aws_ssm_parameter" "google_oauth2_client_secret" {
  name = var.google_oauth2_client_secret_name
}

data "aws_ssm_parameter" "google_oauth2_client_id" {
  name = var.google_oauth2_client_id_name
}

resource "aws_ssm_parameter" "cognito_client_id" {
  name        = var.cognito_client_id_name
  description = "The id for the website client giving access to Cognito."
  type        = "String"
  value       = aws_cognito_user_pool_client.website.id
}

resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name        = var.cognito_user_pool_id_name
  description = "The user pool id to be used by the Cognito client."
  type        = "String"
  value       = aws_cognito_user_pool.users.id
}

################################################################################
# User pools
################################################################################

resource "aws_cognito_user_pool" "users" {
  name = "users"

  alias_attributes         = ["phone_number"]
  auto_verified_attributes = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  email_configuration {
    email_sending_account = "DEVELOPER"
    source_arn            = var.ses_domain_identity_arn
    from_email_address    = var.from_email_address
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  username_configuration {
    case_sensitive = false
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  lambda_config {
    custom_message = aws_lambda_function.custom_message.arn
  }
}

################################################################################
# User pool domain
################################################################################

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "kubis"
  user_pool_id = aws_cognito_user_pool.users.id
}

################################################################################
# Identity providers
################################################################################

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.users.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "profile email openid"
    client_id        = data.aws_ssm_parameter.google_oauth2_client_id.value
    client_secret    = data.aws_ssm_parameter.google_oauth2_client_secret.value
  }

  attribute_mapping = {
    email       = "email"
    family_name = "family_name"
    given_name  = "given_name"
    name        = "name"
    picture     = "picture"
    username    = "sub"
  }
}

################################################################################
# Lambdas
################################################################################

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "null_resource" "create_custom_message_lambda" {
  triggers = {
    # null_resource is recreated on every call to 'terraform apply'
    uuid = uuid()
  }

  provisioner "local-exec" {
    command = templatefile(
      "${path.module}/lambdas/custom-message/create_lambda.sh",
      {
        LAMBDA_FOLDER                        = "${abspath(path.module)}/lambdas/custom-message"
        LAMBDA_FILENAME                      = "${local.custom_message_lambda_name}.py"
        DOMAIN                               = "https://${var.domain}"
        ACCOUNT_VALIDATION_ENDPOINT          = var.account_validation_endpoint,
        PASSWORD_RESET_CONFIRMATION_ENDPOINT = var.password_reset_confirmation_endpoint,
      }
    )
  }
}


data "archive_file" "zip_custom_message_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/custom-message/"
  output_path = local.custom_message_lambda_filename

  depends_on = [
    null_resource.create_custom_message_lambda
  ]
}

resource "aws_lambda_function" "custom_message" {
  function_name = "cognito_custom_message"
  description   = "This function responds to the CustomMessage trigger providing custom messages for Cognito."

  role = aws_iam_role.iam_for_lambda.arn

  handler          = "${local.custom_message_lambda_name}.lambda_handler"
  filename         = local.custom_message_lambda_filename
  source_code_hash = data.archive_file.zip_custom_message_lambda.output_base64sha256
  runtime          = "python3.6"
}

// this resource allows lambda to be invoked by our user pool
resource "aws_lambda_permission" "allow_cognito" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.custom_message.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.users.arn
}


################################################################################
# Clients
################################################################################

resource "aws_cognito_user_pool_client" "website" {
  name         = "kubis-website"
  user_pool_id = aws_cognito_user_pool.users.id

  id_token_validity       = var.id_token_validity
  access_token_validity   = var.access_token_validity
  refresh_token_validity  = var.refresh_token_validity
  enable_token_revocation = true

  token_validity_units {
    id_token      = "hours"
    access_token  = "hours"
    refresh_token = "hours"
  }

  // JavaScript SDK doesn't support apps that have a client secret.
  generate_secret = false

  supported_identity_providers         = ["COGNITO", aws_cognito_identity_provider.google.provider_name]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "aws.cognito.signin.user.admin",
    "email",
    "openid",
    "profile",
  ]
  callback_urls = ["http://localhost:3000"]
  logout_urls   = ["http://localhost:3000"]

  prevent_user_existence_errors = "ENABLED"
}
