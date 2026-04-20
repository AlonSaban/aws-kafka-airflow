resource "aws_security_group" "public" {
  name        = "${var.project_name}-${var.environment}-public-sg"
  description = "Security group for public-facing resources"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

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

  ingress {
    description = "Allow Kafka broker traffic from the VPC"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "Allow Schema Registry traffic from the VPC"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "Allow Kafka Connect REST traffic from the VPC"
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

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

  ingress {
    description = "Allow Airflow web UI from the VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

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

resource "aws_vpc_security_group_ingress_rule" "database_postgres_from_kafka" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.kafka.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow PostgreSQL access from the Kafka Connect host"
}
