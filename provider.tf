provider "aws" {
  region = local.region
}

terraform {
  backend "s3" {
    bucket = "cicd-babu"
    key    = "terraform.tfstate"
    region = "eu-east-1"
  }
}