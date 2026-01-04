output "queue_url" {
  value = aws_sqs_queue.jobs.url
}

output "queue_arn" {
  value = aws_sqs_queue.jobs.arn
}

output "lambda_arn" {
  value = aws_lambda_function.worker.arn
}
