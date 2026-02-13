terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# SSH key pair (uses your local public key file path from variables.tf)
#esource "aws_key_pair" "devops_key" 
# key_name   = var.key_name
# public_key = file(var.public_key_path)
#

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# All subnets in the default VPC (NOTE: no vpc_id argument, we use filter)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for SSH + app ports
resource "aws_security_group" "poc_sg" {
  name        = "poc-microservices-sg"
  description = "Allow SSH and app/http traffic"
  vpc_id      = data.aws_vpc.default.id

  # SSH from your IP (set in variables.tf)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # HTTP (80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App ports (5001–5003)
  ingress {
    from_port   = 5001
    to_port     = 5003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Postgres (5432) – open for demo, tighten later if needed
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Latest Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 instance for Docker + docker-compose stack
resource "aws_instance" "poc_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Pick the first subnet from the default VPC
  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [aws_security_group.poc_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "poc-microservices-ec2"
  }
}
