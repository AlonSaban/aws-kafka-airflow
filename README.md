# AWS Data Pipeline with Terraform (CDC → Kafka → Airflow → Iceberg → Trino)

## Overview

This project provisions and connects an end-to-end data pipeline on AWS using **Terraform only** (no manual console actions).

Pipeline flow:

```
SQL Database (CDC) → Kafka (Confluent Platform) → Apache Airflow → S3 Tables (Iceberg) → Trino
```

The goal is to demonstrate infrastructure provisioning, CDC ingestion, stream processing, and analytical querying in a reproducible, production-oriented setup.

---

## Architecture

* **Database (EC2)**: PostgreSQL/MySQL with CDC enabled
* **Kafka (EC2)**: Confluent Platform (Broker + Schema Registry + Connect)
* **Airflow (EC2)**: Scheduled pipeline execution
* **S3 Tables (Iceberg)**: Analytical storage layer
* **Trino (EC2)**: Query engine for validation
* **Terraform**: Full infrastructure provisioning

---

## Repository Structure

```
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── modules/
│       ├── networking/
│       ├── kafka/
│       ├── database/
│       └── airflow/
├── airflow/
│   └── dags/
│       └── kafka_to_s3_tables.py
├── scripts/
│   ├── setup_kafka.sh
│   ├── setup_db.sh
│   └── setup_trino.sh
└── README.md
```

---

## Prerequisites

* AWS account
* Terraform ≥ 1.5
* AWS CLI configured
* SSH key pair for EC2 access

---

## Deployment

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Configure Variables

Create `terraform.tfvars`:

```hcl
project_name = "data-pipeline"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24"]
azs = ["il-central-1a"]
```

### 3. Apply Infrastructure

```bash
terraform apply
```

---

## Components Setup

### Kafka (Confluent Platform)

* Installed via package manager
* Services:

  * Kafka Broker
  * Schema Registry
  * Kafka Connect
* Topic:

```bash
cdc.orders
```

---

### Database (CDC Source)

* Table:

```sql
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_name TEXT,
  amount DECIMAL,
  status TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

* CDC:

  * PostgreSQL: `wal_level = logical`
  * MySQL: `binlog_format = ROW`

* Debezium Connector:
  Configured via Kafka Connect REST API to stream changes → `cdc.orders`

---

### Airflow

DAG: `kafka_to_s3_tables`

* Schedule: every 5 minutes
* Tasks:

  * Consume Kafka topic `cdc.orders`
  * Transform CDC events
  * Write to Iceberg table in S3

Connections:

* Kafka (bootstrap servers)
* AWS (IAM role, no static credentials)

---

### S3 Tables (Iceberg)

Provisioned via Terraform:

* Table bucket
* Namespace
* Table: `orders`

Schema:

```
id
customer_name
amount
status
created_at
__op
__source_ts
```

---

### Trino

* Deployed on EC2
* Iceberg connector configured to S3 Tables

Example query:

```sql
SELECT * FROM orders LIMIT 10;
```

---

## End-to-End Test

### 1. Insert Data

```sql
INSERT INTO orders (customer_name, amount, status)
VALUES ('Alice', 100, 'NEW');
```

### 2. Verify Flow

* DB → Kafka topic receives event
* Airflow DAG runs
* Data written to Iceberg table
* Query via Trino returns new row

---

## Security

* No hardcoded credentials
* IAM roles attached to EC2 instances
* Least-privilege security groups
* Private subnets for internal services

---

## Design Decisions

* **EC2 over managed services**: explicit control for learning and CDC setup
* **Debezium + Kafka Connect**: standard CDC pattern
* **Iceberg on S3 Tables**: modern table format with schema evolution support
* **Airflow orchestration**: clear scheduling and pipeline control
* **Trino**: lightweight query validation layer

---

## Validation Artifacts

Include:

* Screenshot of Trino query result
* Screenshot or recording of:

  * Kafka topic receiving CDC events
  * Airflow DAG execution
  * Final query result

---

## Optional Enhancements

* Confluent Control Center for monitoring
* CloudWatch alarms (CPU, disk, Kafka lag)
* Schema evolution test:

  ```sql
  ALTER TABLE orders ADD COLUMN currency TEXT;
  ```

---

## Notes

* First Terraform run may require iteration (AMI, package install timing)
* Ensure security groups allow:

  * Kafka (9092)
  * Airflow UI (8080)
  * Trino (8080)
* Use SSH to validate service health on instances

---

## Outcome

A fully reproducible pipeline demonstrating:

* Infrastructure as Code (Terraform)
* CDC ingestion (Debezium + Kafka)
* Stream processing (Airflow)
* Data lake table format (Iceberg)
* Query layer (Trino)
