# AWS Data Pipeline with Terraform

This repository provisions an end-to-end AWS-based data pipeline with Terraform.

The goal is to capture row-level changes from a transactional PostgreSQL database, publish them into Kafka through Debezium, process them on a schedule with Airflow, store them in Amazon S3 Tables in Iceberg format, and query the result with Trino.

Pipeline flow:

```text
PostgreSQL (CDC) -> Kafka / Kafka Connect -> Airflow -> S3 Tables (Iceberg) -> Trino
```

## Goal

The project is built as a task-oriented DevOps/DataOps implementation with these goals:

- provision the infrastructure with Terraform only
- keep the layout modular and readable
- avoid hardcoded credentials in workloads
- make the data flow reproducible from infrastructure code plus instance bootstrap
- demonstrate an end-to-end CDC path from source database to analytical query layer

This is not a hardened production deployment, but the structure is intentionally close to a production-style layout so the service boundaries and infrastructure responsibilities are clear.

## Current Architecture

The repository currently provisions:

- a VPC with public and private subnets
- workload-specific security groups
- a PostgreSQL source database on EC2
- a Kafka host on EC2 running Kafka, Schema Registry, Kafka Connect, and the Debezium PostgreSQL connector
- an Airflow host on EC2 running a scheduled DAG
- an S3 Tables bucket, namespace, and Iceberg table
- a Trino host on EC2 configured to query the S3 Tables Iceberg catalog

High-level flow:

1. PostgreSQL stores the `orders` table and is configured for logical replication.
2. Debezium, running through Kafka Connect, captures row changes and publishes them into `cdc.orders`.
3. Airflow consumes records from Kafka every 5 minutes.
4. Airflow applies batch upsert/delete semantics into the Iceberg table in S3 Tables.
5. Trino queries the Iceberg table through the Iceberg REST catalog backed by S3 Tables.

## Repository Structure

```text
Dataops/
|-- modules/
|   |-- airflow/
|   |   |-- dags/
|   |   |   `-- kafka_to_s3_tables.py.tftpl
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   |-- user_data.sh.tftpl
|   |   `-- variables.tf
|   |-- database/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   |-- user_data.sh.tftpl
|   |   `-- variables.tf
|   |-- kafka/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   |-- user_data.sh.tftpl
|   |   `-- variables.tf
|   |-- networking/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- s3tables/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- security/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   `-- trino/
|       |-- main.tf
|       |-- outputs.tf
|       |-- templates/
|       |-- user_data.sh.tftpl
|       `-- variables.tf
|-- terraform/
|   |-- backend.tf
|   |-- locals.tf
|   |-- main.tf
|   |-- outputs.tf
|   |-- providers.tf
|   |-- terraform.tfvars
|   |-- variables.tf
|   `-- versions.tf
`-- README.md
```

## Module Overview

### `modules/networking`

Responsible for the AWS network foundation:

- VPC
- public subnets
- private subnets
- route-related infrastructure through the VPC module

Current outputs:

- `vpc_id`
- `vpc_cidr_block`
- `public_subnet_ids`
- `private_subnet_ids`

### `modules/security`

Responsible for security groups:

- public SG
- database SG
- Kafka SG
- Airflow SG
- Trino SG

It also defines targeted SG-to-SG access between workloads, such as Kafka reaching PostgreSQL on port `5432`.

### `modules/database`

Responsible for the CDC source database:

- EC2 instance
- IAM role and instance profile
- generated DB password in SSM Parameter Store
- PostgreSQL install and bootstrap
- logical replication settings
- `orders` table creation
- Debezium publication creation

### `modules/kafka`

Responsible for the streaming layer:

- EC2 instance
- IAM role and instance profile
- Confluent Platform Community install
- Kafka broker bootstrap
- Schema Registry bootstrap
- Kafka Connect bootstrap
- topic creation for `cdc.orders`
- Debezium PostgreSQL connector registration
- DB password retrieval from SSM at boot

### `modules/airflow`

Responsible for orchestration and batch ingestion into Iceberg:

- EC2 instance
- IAM role and instance profile
- generated Airflow admin password in SSM Parameter Store
- Airflow installation and standalone startup
- Airflow connection bootstrap for `aws_default` and `kafka_default`
- deployment of the `kafka_to_s3_tables` DAG

### `modules/s3tables`

Responsible for the analytical storage layer:

- S3 Tables table bucket
- namespace
- Iceberg table

Current table schema:

- `id`
- `customer_name`
- `amount`
- `status`
- `created_at`
- `__op`
- `__source_ts`

### `modules/trino`

Responsible for the query layer:

- EC2 instance
- IAM role and instance profile
- Trino install
- Iceberg REST catalog configuration pointed at S3 Tables
- helper query script on the host

## Services and Data Flow

### 1. PostgreSQL

The database host is configured to:

- install PostgreSQL
- enable logical replication
- create the application database
- create the `orders` table
- create a CDC user
- create the publication used by Debezium

### 2. Kafka / Kafka Connect

The Kafka host is configured to:

- run a single-node KRaft broker
- run Schema Registry
- run Kafka Connect
- install the Debezium PostgreSQL connector
- create the `cdc.orders` topic
- register the Debezium connector against the PostgreSQL source

### 3. Airflow

The DAG `kafka_to_s3_tables` is scheduled every 5 minutes.

It currently:

- reads Kafka messages from `cdc.orders`
- normalizes the CDC payload
- deduplicates by `id` within the consumed batch
- applies delete-then-append behavior to the Iceberg table

This gives you task-level CDC sink behavior for inserts, updates, and deletes.

### 4. S3 Tables / Iceberg

The Iceberg table is created in an S3 Tables table bucket and used as the analytical sink for the pipeline.

### 5. Trino

Trino is configured to use:

- the Iceberg connector
- the REST catalog type
- SigV4 authentication
- the S3 Tables Iceberg REST endpoint

This allows querying the `orders` table after Airflow writes data into it.

## Terraform Root

The Terraform root lives in `terraform/` and wires the modules in this order:

1. networking
2. security
3. s3tables
4. database
5. kafka
6. airflow
7. trino

The root outputs expose the key identifiers and endpoints needed for testing:

- VPC and security group IDs
- database private IP and SSM password parameter name
- Kafka bootstrap server, Connect URL, and Schema Registry URL
- Airflow private IP, web URL, and admin password SSM parameter name
- Trino private IP and web URL

## Prerequisites

You need:

- Terraform 1.5 or newer
- an AWS account
- AWS credentials available to Terraform
- network access from your machine to `registry.terraform.io`
- an S3 backend bucket if you want to use the configured remote state backend

Optional but recommended:

- AWS CLI configured
- SSM Session Manager access for EC2 inspection

## Backend and State

The repository is configured for remote state in `terraform/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "my-tf-state-bucket"
    key          = "dataops/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
  }
}
```

This is still a placeholder-style backend config and should be updated to your real bucket, key, and region before a normal `terraform init`.

For local module and validation work, you can use:

```bash
cd terraform
terraform init -backend=false
terraform validate
```

## Variables

Current local example values are in `terraform/terraform.tfvars`.

Key values include:

- network CIDRs and availability zones
- S3 Tables bucket, namespace, and table name
- database sizing and DB name/user
- Kafka sizing and topic name
- Airflow sizing
- Trino sizing and version

Current defaults in the repo:

```hcl
project_name = "dataops"
aws_region   = "il-central-1"
environment  = "dev"
```

## Deploy

### Validate first

```bash
cd terraform
terraform init -backend=false
terraform validate
```

### Deploy with the configured backend

After you update `terraform/backend.tf` for your actual remote state bucket:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## End-to-End Test Flow

After `apply`, the intended verification path is:

### 1. Confirm infrastructure outputs

Check:

- database private IP
- Kafka bootstrap server
- Kafka Connect REST URL
- Airflow web URL
- Trino web URL

### 2. Insert rows into PostgreSQL

Example:

```sql
INSERT INTO public.orders (customer_name, amount, status)
VALUES ('Alice', 100.00, 'NEW');
```

Then test update and delete behavior:

```sql
UPDATE public.orders
SET status = 'PAID'
WHERE id = 1;

DELETE FROM public.orders
WHERE id = 1;
```

### 3. Verify Kafka Connect

On the Kafka host, check:

- Kafka broker is running
- Kafka Connect is running
- the Debezium connector exists in Kafka Connect REST
- records are arriving in `cdc.orders`

### 4. Verify Airflow

On the Airflow host or in the Airflow UI, check:

- the `kafka_to_s3_tables` DAG is present
- the DAG runs successfully
- the task consumes from Kafka and writes to S3 Tables

### 5. Verify Trino

On the Trino host, use the helper script:

```bash
/usr/local/bin/query-orders.sh
```

Or query manually with the CLI:

```bash
trino --server http://127.0.0.1:8080 --catalog s3tables --schema analytics
```

Example query:

```sql
SELECT * FROM orders LIMIT 10;
```

## Current Limitations

This repo is structurally complete for the task, but there are still expected runtime caveats:

- several modules rely on boot-time package downloads from external repositories
- service startup order matters on first boot
- Airflow is currently run in standalone mode
- Trino is deployed as a single-node coordinator/worker
- security groups are practical for the task, but not fully hardened for a production deployment

## Design Notes

Key design choices in the current implementation:

- EC2 is used for all main services to keep service ownership explicit in Terraform
- bootstrap logic is stored in module-local `user_data.sh.tftpl` templates
- generated secrets are stored in SSM Parameter Store and consumed at boot
- S3 Tables is used as the Iceberg sink instead of a traditional data lake bucket plus separate metastore
- Trino is configured against the Iceberg REST catalog path for S3 Tables

## Recommended Evidence for Submission

To demonstrate the task is working, capture:

- Terraform apply output or screenshots
- Kafka Connect connector status
- Airflow DAG success
- Trino query result for the `orders` table
- optionally a short recording showing the insert, Kafka flow, Airflow run, and final Trino query

## What Is Still Left

From an implementation perspective, the main Terraform work is now in place.

The remaining work is mostly verification and submission polish:

- runtime proof that all EC2 bootstrap scripts complete successfully
- end-to-end CDC validation
- screenshots or recording for submission
- optional tightening of security groups and operational behavior
