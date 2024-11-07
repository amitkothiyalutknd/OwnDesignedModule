output "VPCName" {
  value = aws_vpc.VPC.id
}

locals {
  #To format the subnet IDs which may be multiples in format of subnet_name = {id=, az=}
  public_subnet_output = {
    for key, config in local.public_subnet : key => {
      subnet_id = aws_subnet.Subnets[key].id
      az        = aws_subnet.Subnets[key].availability_zone
    }
  }

  private_subnet_output = {
    for key, config in local.private_subnet : key => {
      subnet_id = aws_subnet.Subnets[key].id
      az        = aws_subnet.Subnets[key].availability_zone
    }
  }
}

output "PublicSubnet" {
  value = local.private_subnet_output
}

output "PrivateSubnet" {
  value = local.private_subnet_output
}

output "IGWName" {
  value = aws_internet_gateway.IGW
}

output "RouteTableName" {
  value = aws_route_table.RoutTable
}

output "AssociateRouteTableName" {
  value = aws_route_table_association.AssoRouteTable
}

locals {
  #To format the subnet IDs which may be multiples in format of subnet_name = {id=, az=}
  ec2_output = {
    for key, config in local.instances : key => {
      inst = aws_instance.Instances[key].id
    }
  }
}

output "InstancesName" {
  value = local.ec2_output
}

locals {
  #To format the subnet IDs which may be multiples in format of subnet_name = {id=, az=}
  s3_output = {
    for key, config in local.s3buckets : key => {
      inst = aws_s3_bucket.S3Bucket[key].id
    }
  }
}

output "S3BucketName" {
  value = local.s3_output
}

