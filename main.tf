module "label" {
  source  = "lablabs/label/null"
  version = "0.14.1"

  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
}

resource "aws_s3_bucket" "default" {
  bucket        = "${module.label.name}-${var.source_environment}"
  force_destroy = var.force_destroy
  policy        = data.aws_iam_policy_document.bucket_policy.json

  versioning {
    enabled = var.versioning_enabled
  }

  # lifecycle_rule {
  #   id      = module.label.id
  #   enabled = var.lifecycle_rule_enabled
  #   prefix  = var.prefix
  #   tags    = module.label.tags

  #   noncurrent_version_transition {
  #     days          = var.noncurrent_version_transition_days
  #     storage_class = "GLACIER"
  #   }

  #   noncurrent_version_expiration {
  #     days = var.noncurrent_version_expiration_days
  #   }
  # }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_arn
      }
    }
  }

  tags = module.label.tags
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AWSCloudTrailAclCheck20131101"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${module.label.name}-${var.source_environment}"]

    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite20131101"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
  
    resources = formatlist(
      "arn:aws:s3:::${module.label.name}-${var.source_environment}/AWSLogs/%s/*", 
      var.push_access_accounts_ids
    )

    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
}