terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "3.6.3"
    # }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

# resource "random_id" "RandomSerial" {
#   byte_length = 6
# }
