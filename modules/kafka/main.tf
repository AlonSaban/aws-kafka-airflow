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

resource "aws_iam_role" "kafka" {
  name               = "${var.project_name}-${var.environment}-kafka-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-kafka-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.kafka.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "kafka" {
  name = "${var.project_name}-${var.environment}-kafka-profile"
  role = aws_iam_role.kafka.name
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.kafka.name

  user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y openjdk-17-jre-headless wget gpg curl jq

    mkdir -p /etc/apt/keyrings
    wget -qO - https://packages.confluent.io/deb/8.2/archive.key | gpg --dearmor > /etc/apt/keyrings/confluent.gpg

    CP_DIST="$$(lsb_release -cs)"
    cat > /etc/apt/sources.list.d/confluent-platform.sources <<EOF
    Types: deb
    URIs: https://packages.confluent.io/deb/8.2
    Suites: stable
    Components: main
    Architectures: $$(dpkg --print-architecture)
    Signed-By: /etc/apt/keyrings/confluent.gpg

    Types: deb
    URIs: https://packages.confluent.io/clients/deb/
    Suites: $${CP_DIST}
    Components: main
    Architectures: $$(dpkg --print-architecture)
    Signed-By: /etc/apt/keyrings/confluent.gpg
    EOF

    apt-get update
    apt-get install -y confluent-community-2.13

    PRIVATE_IP="$$(hostname -I | awk '{print $1}')"
    CLUSTER_ID="$$(/usr/bin/kafka-storage random-uuid)"

    cat > /etc/kafka/server.properties <<EOF
    process.roles=broker,controller
    node.id=1
    controller.quorum.voters=1@$${PRIVATE_IP}:9093
    listeners=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
    advertised.listeners=PLAINTEXT://$${PRIVATE_IP}:9092
    listener.security.protocol.map=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT
    inter.broker.listener.name=PLAINTEXT
    controller.listener.names=CONTROLLER
    num.network.threads=3
    num.io.threads=8
    socket.send.buffer.bytes=102400
    socket.receive.buffer.bytes=102400
    socket.request.max.bytes=104857600
    log.dirs=/var/lib/kafka/data
    num.partitions=1
    num.recovery.threads.per.data.dir=1
    offsets.topic.replication.factor=1
    transaction.state.log.replication.factor=1
    transaction.state.log.min.isr=1
    auto.create.topics.enable=false
    EOF

    mkdir -p /var/lib/kafka/data
    /usr/bin/kafka-storage format -t "$${CLUSTER_ID}" -c /etc/kafka/server.properties

    cat > /etc/schema-registry/schema-registry.properties <<EOF
    listeners=http://0.0.0.0:8081
    host.name=$${PRIVATE_IP}
    kafkastore.bootstrap.servers=PLAINTEXT://$${PRIVATE_IP}:9092
    EOF

    mkdir -p /usr/share/confluent-hub-components
    cat > /etc/kafka/connect-distributed.properties <<EOF
    bootstrap.servers=$${PRIVATE_IP}:9092
    group.id=${var.project_name}-${var.environment}-connect-cluster
    key.converter=org.apache.kafka.connect.json.JsonConverter
    value.converter=org.apache.kafka.connect.json.JsonConverter
    key.converter.schemas.enable=false
    value.converter.schemas.enable=false
    config.storage.topic=${var.project_name}-${var.environment}-connect-configs
    offset.storage.topic=${var.project_name}-${var.environment}-connect-offsets
    status.storage.topic=${var.project_name}-${var.environment}-connect-status
    config.storage.replication.factor=1
    offset.storage.replication.factor=1
    status.storage.replication.factor=1
    offset.flush.interval.ms=10000
    rest.port=8083
    rest.advertised.host.name=$${PRIVATE_IP}
    plugin.path=/usr/share/java,/usr/share/confluent-hub-components
    EOF

    /usr/bin/confluent connect plugin install --no-prompt debezium/debezium-connector-postgresql:latest

    systemctl enable confluent-kafka
    systemctl enable confluent-schema-registry
    systemctl enable confluent-kafka-connect

    systemctl restart confluent-kafka
    systemctl restart confluent-schema-registry
    systemctl restart confluent-kafka-connect

    /usr/bin/kafka-topics --bootstrap-server "$${PRIVATE_IP}:9092" --create --if-not-exists --topic "${var.topic_name}" --partitions 1 --replication-factor 1
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
    Name        = "${var.project_name}-${var.environment}-kafka"
    Environment = var.environment
    Terraform   = "true"
    Role        = "kafka"
  }
}
