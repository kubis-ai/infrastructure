################################################################################
# Secrets and parameters
################################################################################

variable "google_oauth2_client_id_name" {
  description = "The Google OAuth2 client id name stored in AWS Parameter Store."
  type        = string
}

variable "google_oauth2_client_secret_name" {
  description = "The Google OAuth2 client secret name stored in AWS Parameter Store."
  type        = string
}

variable "cognito_client_id_name" {
  description = "The name for exporting the cognito client id to the AWS Parameter Store."
  type        = string
}

variable "cognito_user_pool_id_name" {
  description = "The name for exporting the cognito user pool id to the AWS Parameter Store."
  type        = string
}

################################################################################
# Email
################################################################################

variable "ses_domain_identity_arn" {
  description = "The ARN of the SES verified email domain identity."
  type        = string
}

variable "from_email_address" {
  description = "Sender’s email address or sender’s display name with their email address"
  type        = string
}

################################################################################
# Tokens
################################################################################

variable "id_token_validity" {
  description = "Time limit in hours (max 24 hours) after which the ID token is no longer valid and cannot be used."
  type        = string
  default     = "1"
}

variable "access_token_validity" {
  description = "Time limit in hours (max 24 hours) after which the access token is no longer valid and cannot be used."
  type        = string
  default     = "1"
}

variable "refresh_token_validity" {
  description = "Time limit in hours (max 24 hours) after which the refresh token is no longer valid and cannot be used."
  type        = string
  default     = "24"
}

################################################################################
# Endpoints
################################################################################

variable "domain" {
  description = "The application domain. Required for setting up custom message lambdas."
  type        = string
}

variable "account_validation_endpoint" {
  description = "The account validation endpoint. Users will be redirected to this page to confirm their emails"
  type        = string
}
