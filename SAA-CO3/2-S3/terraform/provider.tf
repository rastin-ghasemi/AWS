terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.10.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

# https://registry.terraform.io/providers/hashicorp/aws/latest
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket