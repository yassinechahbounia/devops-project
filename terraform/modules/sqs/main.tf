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

#################################
# S3 : Stockage du code Lambda
#################################

# 1. Création du Bucket
resource "aws_s3_bucket" "lambda_artifacts" {
  # Assurez-vous que ce nom est unique au monde
  bucket        = "lambda-s3-bucket-devops-brief-${var.environment}" 
  force_destroy = true 
}

# 2. Upload du fichier ZIP (L'étape qui manquait)
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = var.lambda_s3_key
  source = var.lambda_zip_path
  # Le etag permet de forcer la mise à jour si le contenu du ZIP change
  etag   = filemd5(var.lambda_zip_path)
}

#################################
# SQS
#################################

resource "aws_sqs_queue" "dlq" {
  name = "${var.project}-${var.environment}-dlq"
  tags = local.common_tags
}

resource "aws_sqs_queue" "jobs" {
  name = "${var.project}-${var.environment}-jobs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = local.common_tags
}

#################################
# IAM : Rôles et Politiques
#################################

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-${var.environment}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_sqs" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [aws_sqs_queue.jobs.arn]
  }
}

resource "aws_iam_role_policy" "lambda_sqs" {
  name   = "${var.project}-${var.environment}-lambda-sqs"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_sqs.json
}

#################################
# Lambda Function
#################################

resource "aws_lambda_function" "worker" {
  function_name = "${var.project}-${var.environment}-worker"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  # Références au bucket interne et à l'objet uploadé
  s3_bucket = aws_s3_bucket.lambda_artifacts.id
  s3_key    = aws_s3_object.lambda_code.key

  # Détection automatique de changement de code
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  # IMPORTANT : On attend que l'objet S3 soit créé avant de créer la Lambda
  depends_on = [
    aws_s3_object.lambda_code,
    aws_iam_role_policy_attachment.lambda_basic_logs
  ]

  timeout = var.lambda_timeout
  tags    = local.common_tags
}

resource "aws_lambda_event_source_mapping" "from_sqs" {
  event_source_arn = aws_sqs_queue.jobs.arn
  function_name    = aws_lambda_function.worker.arn

  batch_size = var.batch_size
  enabled    = true
}