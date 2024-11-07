variable "vpc_config" {
  description = "To get the CIDR and Name of VPC from user"
  type = object({
    cidr_block = string
    name       = string
  })
  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "Invalid CIDR Format - ${var.vpc_config.cidr_block}"
  }
}

variable "subnet_config" {
  # sub1={cidr=.. az=..} sub2={} sub3={}
  description = "Get the CIDR and AZ for the subnets"
  type = map(object({
    name                    = string
    cidr_block              = string
    az                      = string
    map_public_ip_on_launch = optional(bool, false)
    public                  = optional(bool, false)
  }))
  validation {
    # sub1={cidr=} sub2={cidr=..}, [true, true, false]
    condition     = alltrue([for config in var.subnet_config : can(cidrnetmask(config.cidr_block))])
    error_message = "Invalid CIDR Format"
  }
}

variable "instance_config" {
  description = "This is configuration of Instances."
  type = map(object({
    ami_id                      = string
    instance_type               = string
    quantity                    = number
    associate_public_ip_address = bool
    user_data_file              = string
  }))
}

variable "s3_config" {
  description = "S3 Bucket Configuration"
  type = map(object({
    bucket_name = string
    versioning  = bool
  }))
}

variable "environment" {
  description = "This is environment Name"
  type        = string
}

