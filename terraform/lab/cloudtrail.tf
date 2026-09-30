data "aws_partition" "current" {}

locals {
  cloudtrail_name = "devsecops-lab-security-trail"

  cloudtrail_arn = "arn:${data.aws_partition.current.partition}:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
}

# ------------------------------------------------------------------
# S3 bucket used only for CloudTrail log-file storage
# ------------------------------------------------------------------

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "devsecops-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"

  force_destroy = true

  tags = {
    Name = "devsecops-cloudtrail-logs"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# ------------------------------------------------------------------
# Allow the CloudTrail service to deliver logs into the S3 bucket
# ------------------------------------------------------------------

data "aws_iam_policy_document" "cloudtrail_bucket" {

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.cloudtrail_logs.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket.json
}

# ------------------------------------------------------------------
# CloudWatch Logs destination for easier investigation
# ------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/devsecops-lab"
  retention_in_days = 7

  tags = {
    Name = "devsecops-lab-cloudtrail"
  }
}


# ------------------------------------------------------------------
# IAM role CloudTrail uses to deliver events to CloudWatch Logs
# ------------------------------------------------------------------

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  name = "devsecops-lab-cloudtrail-cloudwatch-role"

  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:*"
    ]
  }
}


resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "devsecops-lab-cloudtrail-cloudwatch-policy"
  role = aws_iam_role.cloudtrail_to_cloudwatch.id

  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch.json
}


# ------------------------------------------------------------------
# CloudTrail
# ------------------------------------------------------------------

resource "aws_cloudtrail" "security" {
  name = local.cloudtrail_name

  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.id

  include_global_service_events = true
  is_multi_region_trail         = false

  enable_logging             = true
  enable_log_file_validation = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_to_cloudwatch.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"

      values = [
        "${aws_s3_bucket.iam_lab.arn}/"
      ]
    }
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs,
    aws_iam_role_policy.cloudtrail_cloudwatch
  ]

  tags = {
    Name = "devsecops-lab-security-trail"
  }
}
