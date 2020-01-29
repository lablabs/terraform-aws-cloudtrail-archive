module "label" {
  source      = "../label"
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
}

resource "aws_s3_bucket" "default" {
  count         = length(var.source_environments)
  bucket        = "${module.label.name}-${var.source_environments[count.index].name}"
  force_destroy = var.force_destroy
  policy        = data.aws_iam_policy_document.bucket_policy[count.index].json

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
  count = length(var.source_environments)

  statement {
    sid       = "AWSCloudTrailAclCheck20131101"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${module.label.name}-${var.source_environments[count.index].name}"]

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
      "arn:aws:s3:::${module.label.name}-${var.source_environments[count.index].name}/AWSLogs/%s/*", 
      var.source_environments[count.index].push_access_accounts_ids
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