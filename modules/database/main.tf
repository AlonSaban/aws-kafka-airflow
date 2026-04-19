data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/${var.environment}/database/password"
  description = "Generated PostgreSQL password for the CDC source database"
  type        = "SecureString"
  value       = random_password.db_password.result

  tags = {
    Name        = "${var.project_name}-${var.environment}-database-password"
    Environment = var.environment
    Terraform   = "true"
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "database" {
  name               = "${var.project_name}-${var.environment}-database-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-database-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.database.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "database" {
  name = "${var.project_name}-${var.environment}-database-profile"
  role = aws_iam_role.database.name
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.database.name

  user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y postgresql postgresql-contrib

    PG_VERSION="$(ls /etc/postgresql | sort -V | tail -n1)"
    PG_CONF="/etc/postgresql/$${PG_VERSION}/main/postgresql.conf"
    PG_HBA="/etc/postgresql/$${PG_VERSION}/main/pg_hba.conf"

    cat > "/etc/postgresql/$${PG_VERSION}/main/conf.d/dataops-cdc.conf" <<'CONF'
    listen_addresses = '*'
    wal_level = logical
    max_wal_senders = 10
    max_replication_slots = 10
    password_encryption = 'scram-sha-256'
    CONF

    sed -i '/# BEGIN DATAOPS MANAGED RULES/,/# END DATAOPS MANAGED RULES/d' "$PG_HBA"
    cat >> "$PG_HBA" <<'HBA'
    # BEGIN DATAOPS MANAGED RULES
    host all all ${var.vpc_cidr_block} scram-sha-256
    host replication ${var.db_username} ${var.vpc_cidr_block} scram-sha-256
    # END DATAOPS MANAGED RULES
    HBA

    systemctl enable postgresql
    systemctl restart postgresql

    sudo -u postgres psql -v ON_ERROR_STOP=1 <<'SQL'
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${var.db_username}') THEN
        CREATE ROLE ${var.db_username} WITH LOGIN PASSWORD '${random_password.db_password.result}' REPLICATION;
      ELSE
        ALTER ROLE ${var.db_username} WITH LOGIN PASSWORD '${random_password.db_password.result}' REPLICATION;
      END IF;
    END
    $$;
    SQL

    sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${var.db_name}'" | grep -q 1 || sudo -u postgres createdb "${var.db_name}"

    sudo -u postgres psql -d "${var.db_name}" -v ON_ERROR_STOP=1 <<'SQL'
    GRANT ALL PRIVILEGES ON DATABASE ${var.db_name} TO ${var.db_username};
    GRANT USAGE, CREATE ON SCHEMA public TO ${var.db_username};

    CREATE TABLE IF NOT EXISTS public.orders (
      id BIGSERIAL PRIMARY KEY,
      customer_name VARCHAR(255) NOT NULL,
      amount NUMERIC(10,2) NOT NULL,
      status VARCHAR(50) NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.orders TO ${var.db_username};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${var.db_username};

    DROP PUBLICATION IF EXISTS debezium_publication;
    CREATE PUBLICATION debezium_publication FOR TABLE public.orders;
    SQL
  EOT

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-database"
    Environment = var.environment
    Terraform   = "true"
    Role        = "database"
  }
}
