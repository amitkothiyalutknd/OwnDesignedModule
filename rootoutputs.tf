output "VPCOutput" {
  value = module.designedModule.VPCName
}

output "PublicSubnetOutput" {
  value = module.designedModule.PublicSubnet
}

output "PrivateSubnetOutput" {
  value = module.designedModule.PrivateSubnet
}

output "IGWOutput" {
  value = module.designedModule.IGWName
}

output "RouteTableOutput" {
  value = module.designedModule.RouteTableName
}

output "AssociateRouteTableOutput" {
  value = module.designedModule.AssociateRouteTableName
}

output "InstancesOutput" {
  value = module.designedModule.InstancesName
}

output "S3BucketOutput" {
  value = module.designedModule.S3BucketName
}
