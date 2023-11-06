output "log_bucket" {
  description = "LOG BUCKET"
  value       = aws_s3_bucket.log_bucket.id
}

output "state_bucket" {
  description = "STATEFILE BUCKET"
  value       = aws_s3_bucket.state_bucket.id
}
