# VPC — A VPC (Virtual Private Cloud) is your own isolated network inside AWS.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Public subnet — internet accessible, for resources like web servers
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# Private subnet — no direct internet access, for databases and internal services
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

# Security group — virtual firewall, controls inbound and outbound traffic per resource
# Principle of least privilege: only allow specific ports from specific IPs
resource "aws_security_group" "web" {
  vpc_id = aws_vpc.main.id
  description = "Web server security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
    description = "allow inbound http traffic to device ip"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
    description = "allow inbound ssh traffic to device ip"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow outbound https traffic"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  # no ingress or egress rules — blocks all traffic
}

resource "aws_flow_log" "main_vpc_flow_log"{
    iam_role_arn         = aws_iam_role.ec2_role.arn
    log_destination      = aws_cloudwatch_log_group.vpc_logs.arn
    log_destination_type = "cloud-watch-logs"
    traffic_type         = "ALL"
    vpc_id               = aws_vpc.main.id

}

# CloudWatch log group — destination for VPC flow logs, encrypted at rest with KMS
resource "aws_cloudwatch_log_group" "vpc_logs"{
    name              = "vpc_logs"
    retention_in_days = 365
    kms_key_id        = aws_kms_key.cloudwatch.arn
}

# KMS key — manages encryption for CloudWatch logs, key rotation enabled
resource "aws_kms_key" "cloudwatch" {
  description             = "KMS key for CloudWatch log group encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}