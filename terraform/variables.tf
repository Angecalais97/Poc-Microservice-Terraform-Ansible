variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "key_name" {
  type        = string
  description = "Name for the EC2 key pair"
  default     = "vault-key"
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key file"
  default     = "C:/Users/ttnar/Downloads/vault-key.pem"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "CIDR allowed to SSH (your IP)"
  # Replace with your real IP + /32
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.small"
}
