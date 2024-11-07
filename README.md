## terraform module which named as "designedModule" for aws cloud platform

## Overview

This is sample example of manually designed terraform module. This module is responsible for the creation of 1 VPC in which
4 subnets (2 are public and 2 are private subnets) consist. It provides internet gateway to VPC for internet access.
It also has two route table, first one for public subnets via route table association resource and second one  for private
subnets. It also creates 2 s3 buckets in which 1 has enabled versioning feature.

The module also creates 2 instances in public subnet which has access of s3 bucket via IAM role.

## Features

- Creates VPC with specified CIDR ip address.
- Creates 4 subnets (2 public & 2 private).
- Creates an internet gateway (IGW) for VPC.
- Set up route table for public subnets.
- Creates 2 ec2 instances.
- Creates single key with private and public to ssh access of ec2 instance
- Creates Securities group with own designed rule for access of ec2 instance.
- Creates 2 s3 buckets. 

## Usage

```
module "designedModule" {
  source = "./Module/Infra"

  environment = "Test"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "ModuledVPC"
  }

  subnet_config = {
    #key={cidr, az}
    public_subnet-1 = {
      name                    = "public_subnet-1"
      cidr_block              = "10.0.0.0/24"
      az                      = "us-east-1a"
      map_public_ip_on_launch = true
      public                  = true
    }
    public_subnet-2 = {
      name                    = "public_subnet-2"
      cidr_block              = "10.0.2.0/24"
      az                      = "us-east-1b"
      map_public_ip_on_launch = true
      public                  = true
    }

    private_subnet-1 = {
      name                    = "private_subnet-1"
      cidr_block              = "10.0.1.0/24"
      az                      = "us-east-1c"
      map_public_ip_on_launch = false
      public                  = false
    }

    private_subnet-2 = {
      name                    = "private_subnet-2"
      cidr_block              = "10.0.3.0/24"
      az                      = "us-east-1d"
      map_public_ip_on_launch = false
      public                  = false
    }
  }

  instance_config = {
    instance1 = {
      ami_id                      = "ami-0866a3c8686eaeeba"
      instance_type               = "t2.micro"
      quantity                    = 1
      associate_public_ip_address = true
      user_data_file              = "./Module/Infra/script1.sh"
    }

    instance2 = {
      ami_id                      = "ami-005fc0f236362e99f"
      instance_type               = "t2.micro"
      quantity                    = 1
      associate_public_ip_address = true
      user_data_file              = "./Module/Infra/script2.sh"
    }
  }

  s3_config = {
    moduled_bucket_1 = {
      bucket_name = "moduled-bucket-1"
      acl         = "private"
      versioning  = false
    }

    moduled_bucket_2 = {
      bucket_name = "moduled-bucket-2"
      acl         = "private"
      versioning  = true
    }
  }
}

```