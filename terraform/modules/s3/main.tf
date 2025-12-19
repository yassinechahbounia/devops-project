locals {
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# Bucket artefacts (recommandé par le brief) [file:1]
resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifacts_bucket_name
  tags   = merge(local.common_tags, { Name = "${var.project}-${var.environment}-artifacts" })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration { status = var.enable_versioning ? "Enabled" : "Suspended" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Optionnel: bucket tfstate (souvent créé en bootstrap manuel)
resource "aws_s3_bucket" "tfstate" {
  count  = var.create_tfstate_bucket ? 1 : 0
  bucket = var.tfstate_bucket_name
  tags   = merge(local.common_tags, { Name = "${var.project}-${var.environment}-tfstate" })
}

resource "aws_s3_bucket_versioning" "tfstate" {
  count  = var.create_tfstate_bucket ? 1 : 0
  bucket = aws_s3_bucket.tfstate[0].id
  versioning_configuration { status = var.enable_versioning ? "Enabled" : "Suspended" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  count  = var.create_tfstate_bucket ? 1 : 0
  bucket = aws_s3_bucket.tfstate[0].id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  count                   = var.create_tfstate_bucket ? 1 : 0
  bucket                  = aws_s3_bucket.tfstate[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
