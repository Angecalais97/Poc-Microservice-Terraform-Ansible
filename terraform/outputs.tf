output "ec2_public_ip" {
  description = "Public IP of the POC EC2 instance"
  value       = aws_instance.poc_ec2.public_ip
}
