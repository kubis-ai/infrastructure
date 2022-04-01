terraform {
  backend "s3" {
    key = "services/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-kubis"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "terraform-state-kubis"
    key    = "cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "charts" {
  backend = "s3"
  config = {
    bucket = "terraform-state-kubis"
    key    = "charts/terraform.tfstate"
    region = "us-east-1"
  }
}

################################################################################
# CDN (CloudFront)
################################################################################

locals {
  alb_origin_id = "alb"
}

resource "aws_cloudfront_distribution" "alb_distribution" {
  origin {
    origin_id   = local.alb_origin_id
    domain_name = data.terraform_remote_state.cluster.outputs.alb_dns_name

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  aliases = [var.domain, "www.${var.domain}", var.docs_domain, ]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.alb_origin_id

    viewer_protocol_policy = "allow-all"


    min_ttl     = 0
    default_ttl = 1800
    max_ttl     = 3600
    compress    = true

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.terraform_remote_state.cluster.outputs.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  # By default, cloudfront caches error for five minutes. There can be situation when a developer has
  # accidentally broken the website and you would not want to wait for five minutes for the error response to be cached.
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/CustomErrorDocSupport.html
  custom_error_response {
    error_code            = 400
    error_caching_min_ttl = 30
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 30
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 30
  }

  custom_error_response {
    error_code            = 405
    error_caching_min_ttl = 30
  }
}

################################################################################
# Domain aliasing
################################################################################

module "dns" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/dns"

  domain = var.domain

  # All domains pointing to a CloudFront distribution must also be configured as
  # aliases in the CloudFront settings.
  alias = [
    {
      source  = var.domain,
      target  = aws_cloudfront_distribution.alb_distribution.domain_name
      zone_id = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
    },
    {
      source  = var.cicd_domain
      target  = data.terraform_remote_state.cluster.outputs.alb_dns_name
      zone_id = data.terraform_remote_state.cluster.outputs.alb_zone_id
    },
    {
      source  = var.api_domain
      target  = data.terraform_remote_state.cluster.outputs.alb_dns_name
      zone_id = data.terraform_remote_state.cluster.outputs.alb_zone_id
    },
    {
      source  = var.docs_domain
      target  = aws_cloudfront_distribution.alb_distribution.domain_name
      zone_id = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
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
# Email (SES)
################################################################################

module "email" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/email"

  domain           = var.domain
  email_identities = var.email_identities
  aws_region       = var.aws_region
}

################################################################################
# Email (WorkMail)
################################################################################

data "aws_route53_zone" "primary" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "mx" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = data.aws_route53_zone.primary.name
  type    = "MX"
  ttl     = 86400
  records = ["10 inbound-smtp.${var.aws_region}.amazonaws.com."]
}

// enable Autodiscover service for Outlook and other clients
resource "aws_route53_record" "autodiscover" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "autodiscover.${data.aws_route53_zone.primary.name}"
  type    = "CNAME"
  ttl     = 86400
  records = ["autodiscover.mail.${var.aws_region}.awsapps.com."]
}

// SES identity / verification
resource "aws_ses_domain_identity" "identity" {
  domain = data.aws_route53_zone.primary.name
}

// DKIM
resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.identity.domain
}

resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${data.aws_route53_zone.primary.name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com."]
}

// DMARC record
resource "aws_route53_record" "dmarc" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "_dmarc.${data.aws_route53_zone.primary.name}"
  type    = "TXT"
  ttl     = 86400
  records = ["v=DMARC1;p=quarantine;pct=100;fo=1;"]
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

resource "aws_ssm_parameter" "filesystem_secret_access_key" {
  name        = var.filesystem_secret_access_key_path
  description = "The AWS secret access key for the Filesystem service."
  type        = "SecureString"
  value       = aws_iam_access_key.filesystem.secret
}

resource "aws_db_subnet_group" "filesystem_db" {
  name       = "filesystem_db_main"
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
}

resource "random_password" "filesystem_db_password" {
  length           = 16
  special          = true
  override_special = "%@"
}

resource "aws_db_instance" "filesystem_db" {
  name = "filesystem_db"

  engine            = "postgres"
  engine_version    = "13.4"
  instance_class    = var.filesystem_db_instance_class
  allocated_storage = var.filesystem_db_allocated_storage

  username = "filesystem_db"
  password = random_password.filesystem_db_password.result
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.allow_traffic_from_cluster.id]
  db_subnet_group_name   = aws_db_subnet_group.filesystem_db.id

  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  skip_final_snapshot       = false
  final_snapshot_identifier = var.filesystem_db_final_snapshot_identifier

  deletion_protection = var.filesystem_db_deletion_protection
}

resource "aws_ssm_parameter" "filesystem_database_connection_uri" {
  name        = var.filesystem_database_connection_uri_path
  description = "The connection URI for the Filesystem service database."
  type        = "SecureString"
  value       = "postgres://${urlencode("${aws_db_instance.filesystem_db.username}")}:${urlencode("${aws_db_instance.filesystem_db.password}")}@${aws_db_instance.filesystem_db.endpoint}/${aws_db_instance.filesystem_db.name}"
}

################################################################################
# Cloud service
################################################################################

resource "aws_security_group" "allow_traffic_from_cluster" {
  name        = "allow_traffic_from_cluster"
  description = "Allow traffic from the cluster nodes."
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description     = "Allows traffic on port 5432."
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.cluster.outputs.worker_security_group_id]
  }
}

resource "aws_db_subnet_group" "cloud_db" {
  name       = "cloud_db_main"
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
}

resource "random_password" "cloud_db_password" {
  length           = 16
  special          = true
  override_special = "%@"
}

resource "aws_db_instance" "cloud_db" {
  name = "cloud_db"

  engine            = "postgres"
  engine_version    = "13.4"
  instance_class    = var.cloud_db_instance_class
  allocated_storage = var.cloud_db_allocated_storage

  username = "cloud_db"
  password = random_password.cloud_db_password.result
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.allow_traffic_from_cluster.id]
  db_subnet_group_name   = aws_db_subnet_group.cloud_db.id

  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  skip_final_snapshot       = false
  final_snapshot_identifier = var.cloud_db_final_snapshot_identifier

  deletion_protection = var.cloud_db_deletion_protection
}

resource "aws_ssm_parameter" "cloud_database_connection_uri" {
  name        = var.cloud_database_connection_uri_path
  description = "The connection URI for the Cloud service database."
  type        = "SecureString"
  value       = "postgres://${urlencode("${aws_db_instance.cloud_db.username}")}:${urlencode("${aws_db_instance.cloud_db.password}")}@${aws_db_instance.cloud_db.endpoint}/${aws_db_instance.cloud_db.name}"
}

resource "aws_iam_user" "cloud" {
  name = "CloudService"
}

resource "aws_iam_access_key" "cloud" {
  user = aws_iam_user.cloud.name
}

resource "aws_iam_policy" "cloud_pricing_policy" {
  name        = "PricingAccessForCloudService"
  description = "This policy gives cloud service permission to request pricing of AWS products."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "pricing:GetProducts",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "cloud_pricing_policy_attach" {
  user       = aws_iam_user.cloud.name
  policy_arn = aws_iam_policy.cloud_pricing_policy.arn
}

resource "aws_iam_policy" "cloud_assume_role_policy" {
  name        = "AssumeRoleForCloudService"
  description = "This policy allows cloud service to gain access of users' AWS accounts."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "cloud_assume_role_policy_attach" {
  user       = aws_iam_user.cloud.name
  policy_arn = aws_iam_policy.cloud_assume_role_policy.arn
}

resource "aws_ssm_parameter" "cloud_access_key_id" {
  name        = var.cloud_access_key_id_path
  description = "The AWS access key id for the Cloud service."
  type        = "String"
  value       = aws_iam_access_key.cloud.id
}

resource "aws_ssm_parameter" "cloud_secret_access_key" {
  name        = var.cloud_secret_access_key_path
  description = "The AWS secret access key for the Cloud service."
  type        = "SecureString"
  value       = aws_iam_access_key.cloud.secret
}

data "aws_ami" "cpu_machine_image" {
  most_recent = true

  owners = ["045329000471"]

  filter {
    name   = "name"
    values = ["kubis-deep-learning-py36-cpu-*"]
  }
}

resource "aws_ssm_parameter" "aws_cpu_machine_image" {
  name        = var.cloud_aws_cpu_machine_image_path
  description = "The AWS CPU machine image for the Cloud service."
  type        = "String"
  value       = data.aws_ami.cpu_machine_image.id
}

data "aws_ami" "gpu_machine_image" {
  most_recent = true

  owners = ["045329000471"]

  filter {
    name   = "name"
    values = ["kubis-deep-learning-py36-gpu-*"]
  }
}

resource "aws_ssm_parameter" "aws_gpu_machine_image" {
  name        = var.cloud_aws_gpu_machine_image_path
  description = "The AWS GPU machine image for the Cloud service."
  type        = "String"
  value       = data.aws_ami.gpu_machine_image.id
}

resource "aws_ssm_parameter" "cloud_redis_connection_uri" {
  name        = var.cloud_redis_connection_uri_path
  description = "The connection URI for the Cloud service Redis."
  type        = "SecureString"
  value       = data.terraform_remote_state.charts.outputs.redis_connection_uri
}

################################################################################
# Notebook service
################################################################################

resource "aws_db_subnet_group" "notebook_db" {
  name       = "notebook_db_main"
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
}

resource "random_password" "notebook_db_password" {
  length           = 16
  special          = true
  override_special = "%@"
}

resource "aws_db_instance" "notebook_db" {
  name = "notebook_db"

  engine            = "postgres"
  engine_version    = "13.4"
  instance_class    = var.notebook_db_instance_class
  allocated_storage = var.notebook_db_allocated_storage

  username = "notebook_db"
  password = random_password.notebook_db_password.result
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.allow_traffic_from_cluster.id]
  db_subnet_group_name   = aws_db_subnet_group.notebook_db.id

  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  skip_final_snapshot       = false
  final_snapshot_identifier = var.notebook_db_final_snapshot_identifier

  deletion_protection = var.notebook_db_deletion_protection
}

resource "aws_ssm_parameter" "notebook_database_connection_uri" {
  name        = var.notebook_database_connection_uri_path
  description = "The connection URI for the Notebook service database."
  type        = "SecureString"
  value       = "postgres://${urlencode("${aws_db_instance.notebook_db.username}")}:${urlencode("${aws_db_instance.notebook_db.password}")}@${aws_db_instance.notebook_db.endpoint}/${aws_db_instance.notebook_db.name}"
}

resource "aws_ssm_parameter" "notebook_redis_connection_uri" {
  name        = var.notebook_redis_connection_uri_path
  description = "The connection URI for the Notebook service Redis."
  type        = "SecureString"
  value       = data.terraform_remote_state.charts.outputs.redis_connection_uri
}
