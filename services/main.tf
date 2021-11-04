terraform {
  backend "s3" {
    key = "services/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "terraform-state-kubis"
    key    = "cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

################################################################################
# Domain aliasing
################################################################################

module "dns" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/dns"

  domain = var.domain

  alias = [
    {
      source  = var.domain,
      target  = data.terraform_remote_state.cluster.outputs.dns_name
      zone_id = data.terraform_remote_state.cluster.outputs.zone_id
    },
    {
      source  = var.cicd_domain
      target  = data.terraform_remote_state.cluster.outputs.dns_name
      zone_id = data.terraform_remote_state.cluster.outputs.zone_id
    },
    {
      source  = var.api_domain
      target  = data.terraform_remote_state.cluster.outputs.dns_name
      zone_id = data.terraform_remote_state.cluster.outputs.zone_id
    },
  ]
}

################################################################################
# Authentication (Firebase)
################################################################################

// Records needed for using custom domain in e-mails sent by Firebase
// and for custom domain hosting using in OAuth flows
data "aws_route53_zone" "kubis" {
  name = var.domain
}

resource "aws_route53_record" "firebase_cname_1" {
  zone_id = data.aws_route53_zone.kubis.zone_id
  name    = "firebase1._domainkey.kubis.ai"
  type    = "CNAME"
  ttl     = "5"

  records = ["mail-kubis-ai.dkim1._domainkey.firebasemail.com."]
}

resource "aws_route53_record" "firebase_cname_2" {
  zone_id = data.aws_route53_zone.kubis.zone_id
  name    = "firebase2._domainkey.kubis.ai"
  type    = "CNAME"
  ttl     = "5"

  records = ["mail-kubis-ai.dkim2._domainkey.firebasemail.com."]
}

resource "aws_route53_record" "firebase_txt" {
  zone_id = data.aws_route53_zone.kubis.zone_id
  name    = "kubis.ai"
  type    = "TXT"
  ttl     = "5"

  records = [
    "v=spf1 include:_spf.firebasemail.com ~all",
    "firebase=aerial-ceremony-330017",
    "google-site-verification=9QIbZRfgIYgDTW_KPR73dxSVTFYOxJrS__oduUlG6Pg"
  ]
}

resource "aws_route53_record" "firebase_auth_domain" {
  zone_id = data.aws_route53_zone.kubis.zone_id
  name    = var.auth_domain
  type    = "A"
  ttl     = "5"

  records = ["199.36.158.100"]
}

resource "aws_ssm_parameter" "firebase_auth_domain" {
  name        = var.firebase_auth_domain_path
  description = "The custom domain used by Firebase for authentication."
  type        = "String"
  value       = var.auth_domain
}

################################################################################
# Email
################################################################################

module "email" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/email"

  domain           = var.domain
  email_identities = var.email_identities
  aws_region       = var.aws_region
}

################################################################################
# Container registry
################################################################################

module "container_registry" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/container-registry"

  repository_list      = var.repository_list
  image_tag_mutability = "IMMUTABLE"
  enable_scan_on_push  = true
}

################################################################################
# Filesystem service
################################################################################

resource "aws_s3_bucket" "filesystem_object_store" {
  bucket = var.filesystem_bucket_name

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false
  }

  versioning {
    enabled = true
  }

  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


resource "aws_iam_user" "filesystem" {
  name = "FilesystemService"
}

resource "aws_iam_access_key" "filesystem" {
  user = aws_iam_user.filesystem.name
}


resource "aws_iam_user_policy" "filesystem_policy" {
  name = "S3AccessForFilesystemService"
  user = aws_iam_user.filesystem.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::*/*",
        "arn:aws:s3:::${aws_s3_bucket.filesystem_object_store.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_ssm_parameter" "filesystem_bucket_name" {
  name        = var.filesystem_bucket_name_path
  description = "The name of the S3 bucket for the Filesystem service."
  type        = "String"
  value       = aws_s3_bucket.filesystem_object_store.id
}

resource "aws_ssm_parameter" "filesystem_endpoint" {
  name        = var.filesystem_endpoint_path
  description = "The S3 endpoint for the Filesystem service."
  type        = "String"
  value       = "s3.${aws_s3_bucket.filesystem_object_store.region}.amazonaws.com"
}


resource "aws_ssm_parameter" "filesystem_access_key_id" {
  name        = var.filesystem_access_key_id_path
  description = "The AWS access key id for the Filesystem service."
  type        = "String"
  value       = aws_iam_access_key.filesystem.id
}

resource "aws_ssm_parameter" "filesystem_access_key_secret" {
  name        = var.filesystem_access_key_secret_path
  description = "The AWS access key secret for the Filesystem service."
  type        = "SecureString"
  value       = aws_iam_access_key.filesystem.secret
}

