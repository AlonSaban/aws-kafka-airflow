resource "aws_security_group" "public" {
  name        = "${var.project_name}-${var.environment}-public-sg"
  description = "Security group for public-facing resources"
  vpc_id      = var.vpc_id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-${var.environment}-database-sg"
  description = "Security group for the PostgreSQL source database"
  vpc_id      = var.vpc_id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-database-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_security_group" "kafka" {
  name        = "${var.project_name}-${var.environment}-kafka-sg"
  description = "Security group for the Kafka, Schema Registry, and Connect host"
  vpc_id      = var.vpc_id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-kafka-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_security_group" "airflow" {
  name        = "${var.project_name}-${var.environment}-airflow-sg"
  description = "Security group for the Airflow host"
  vpc_id      = var.vpc_id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-airflow-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_security_group" "trino" {
  name        = "${var.project_name}-${var.environment}-trino-sg"
  description = "Security group for the Trino host"
  vpc_id      = var.vpc_id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-trino-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_vpc_security_group_ingress_rule" "database_postgres_from_kafka" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.kafka.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow PostgreSQL access from the Kafka Connect host"
}

resource "aws_vpc_security_group_ingress_rule" "kafka_broker_from_airflow" {
  security_group_id            = aws_security_group.kafka.id
  referenced_security_group_id = aws_security_group.airflow.id
  from_port                    = 9092
  to_port                      = 9092
  ip_protocol                  = "tcp"
  description                  = "Allow Airflow to consume CDC events from Kafka"
}
