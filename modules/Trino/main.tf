data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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

data "aws_iam_policy_document" "s3tables_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3tables:*"
    ]
    resources = [
      var.s3tables_bucket_arn,
      var.s3tables_table_arn
    ]
  }
}

resource "aws_iam_role" "trino" {
  name               = "${var.project_name}-${var.environment}-trino-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-trino-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.trino.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "s3tables_access" {
  name   = "${var.project_name}-${var.environment}-trino-s3tables-access"
  role   = aws_iam_role.trino.id
  policy = data.aws_iam_policy_document.s3tables_access.json
}

resource "aws_iam_instance_profile" "trino" {
  name = "${var.project_name}-${var.environment}-trino-profile"
  role = aws_iam_role.trino.name
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.trino.name

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    aws_region          = var.aws_region
    namespace           = var.s3tables_namespace
    s3tables_bucket_arn = var.s3tables_bucket_arn
    table_name          = var.s3tables_table_name
    trino_version       = var.trino_version
  })

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
    Name        = "${var.project_name}-${var.environment}-trino"
    Environment = var.environment
    Terraform   = "true"
    Role        = "trino"
  }
}
