output "table_bucket_arn" {
  description = "ARN of the S3 table bucket"
  value       = aws_s3tables_table_bucket.this.arn
}

output "table_bucket_name" {
  description = "Name of the S3 table bucket"
  value       = aws_s3tables_table_bucket.this.name
}

output "namespace" {
  description = "S3 Tables namespace name"
  value       = aws_s3tables_namespace.orders.namespace
}

output "table_name" {
  description = "Iceberg table name"
  value       = aws_s3tables_table.orders.name
}

output "table_arn" {
  description = "ARN of the Iceberg table"
  value       = aws_s3tables_table.orders.arn
}
