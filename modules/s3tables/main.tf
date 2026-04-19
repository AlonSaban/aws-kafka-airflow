resource "aws_s3tables_table_bucket" "this" {
  name = var.table_bucket_name

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_s3tables_namespace" "orders" {
  namespace        = var.namespace
  table_bucket_arn = aws_s3tables_table_bucket.this.arn
}

resource "aws_s3tables_table" "orders" {
  name             = var.table_name
  namespace        = aws_s3tables_namespace.orders.namespace
  table_bucket_arn = aws_s3tables_namespace.orders.table_bucket_arn
  format           = "ICEBERG"

  metadata {
    iceberg {
      schema {
        field {
          name     = "id"
          type     = "long"
          required = true
        }

        field {
          name     = "customer_name"
          type     = "string"
          required = true
        }

        field {
          name     = "amount"
          type     = "decimal(10,2)"
          required = true
        }

        field {
          name     = "status"
          type     = "string"
          required = true
        }

        field {
          name     = "created_at"
          type     = "timestamp"
          required = true
        }

        field {
          name     = "__op"
          type     = "string"
          required = true
        }

        field {
          name     = "__source_ts"
          type     = "timestamp"
          required = true
        }
      }
    }
  }
}
