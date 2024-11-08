output "VPCOutput" {
  description = "Show the info of VPC."
  value       = module.designedModule.VPCName
}

output "PublicSubnetOutput" {
  description = "Show the info of Public Subnets."
  value       = module.designedModule.PublicSubnet
}

output "PrivateSubnetOutput" {
  description = "Show the info of Private Subnets."
  value       = module.designedModule.PrivateSubnet
}

output "IGWOutput" {
  description = "Show the info of Internet Gateway."
  value       = module.designedModule.IGWName
}

output "RouteTableOutput" {
  description = "Show the info of Route Table."
  value       = module.designedModule.RouteTableName
}

output "AssociateRouteTableOutput" {
  description = "Show the info of Associate Route Table."
  value       = module.designedModule.AssociateRouteTableName
}

output "InstancesOutput" {
  description = "Show the info of EC2 instances."
  value       = module.designedModule.InstancesName
}

output "S3BucketOutput" {
  description = "Show the info of S3 Buckets."
  value       = module.designedModule.S3BucketName
}
