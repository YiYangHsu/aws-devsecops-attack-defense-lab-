data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "iam_lab" {
  bucket = "devsecops-iam-lab-${data.aws_caller_identity.current.account_id}"

  force_destroy = true

  tags = {
    Name = "devsecops-iam-lab"
  }
}

resource "aws_s3_bucket_public_access_block" "iam_lab" {
  bucket = aws_s3_bucket.iam_lab.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "iam_lab" {
  bucket = aws_s3_bucket.iam_lab.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "allowed_test_data" {
  bucket = aws_s3_bucket.iam_lab.id
  key    = "allowed/test-data.txt"

  content = "TRAINING DATA ONLY - allowed object for IAM least privilege testing."
}

resource "aws_s3_object" "restricted_decoy_data" {
  bucket = aws_s3_bucket.iam_lab.id
  key    = "restricted/decoy-data.txt"

  content = "TRAINING DATA ONLY - object used to verify access denial."
}