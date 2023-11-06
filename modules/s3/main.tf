terraform {
  backend "local" {}
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22.0"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.env
      Owner       = var.organization
    }
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = var.log_bucket_prefix
}

resource "aws_s3_bucket_versioning" "versioning_log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "state_bucket" {
  bucket_prefix = var.state_bucket_prefix
}

resource "aws_s3_bucket_versioning" "versioning_tf_bucket" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "log_access" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "tf_access" {
  bucket                  = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_access_from_root" {

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root", "arn:aws:iam::127311923021:root"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.log_bucket.arn,
      "${aws_s3_bucket.log_bucket.arn}/*",
    ]
  }
}


data "aws_iam_policy_document" "allow_access_from_another_account" {

  source_policy_documents = [data.aws_iam_policy_document.allow_access_from_root.json]

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl",
    ]
    resources = [
      aws_s3_bucket.log_bucket.arn,
      "${aws_s3_bucket.log_bucket.arn}/*",
    ]
  }
}


    