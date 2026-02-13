terraform {
  backend "s3" {
    bucket         = "poc-microservices-tfstate-ttnar-2026"
    key            = "poc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "poc-microservices-tf-lock"
    encrypt        = true
  }
}
