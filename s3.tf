resource "aws_s3_bucket" "S3Bucket" {
  depends_on = [aws_subnet.Subnets]
  for_each   = var.s3_config
  bucket     = each.value.bucket_name

  versioning {
    enabled = each.value.versioning
  }

  tags = {
    Name = each.key
  }
}

locals {
  s3buckets = {
    #key={} if public is true in subnet_config
    for key, config in var.s3_config : key => config
  }
}

