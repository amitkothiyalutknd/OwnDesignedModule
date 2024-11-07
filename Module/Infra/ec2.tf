resource "aws_instance" "Instances" {
  depends_on                  = [aws_route_table_association.AssoRouteTable]
  for_each                    = var.instance_config
  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type
  user_data                   = file(each.value.user_data_file)
  key_name                    = aws_key_pair.EC2Keys.key_name
  associate_public_ip_address = each.value.associate_public_ip_address
  security_groups             = [aws_security_group.SG.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  subnet_id = element(local.PublicSubnets, index(keys(var.instance_config), each.key))
  # subnet_id = element(local.PublicSubnets, length(var.instance_config).index)

  tags = {
    Name = each.key
  }
}

resource "aws_key_pair" "EC2Keys" {
  key_name   = "${var.environment}-EC2Keys"
  public_key = file("E:/TerraformDetailedWorkshop/OwnDesignedModule/terrainstance.pub")
}

locals {
  # Filter public subnets (those with map_public_ip_on_launch = true)
  # PublicSubnets = [for key, value in var.subnet_config : value.subnet_id if value.public == true]
  PublicSubnets = [for subnet in aws_subnet.Subnets : subnet.id if subnet.map_public_ip_on_launch == true]
}

output "public_subnet_ids" {
  value       = local.PublicSubnets
  description = "List of IDs of the recently created public subnets"
}

locals {
  instances = {
    #key={} if public is true in subnet_config
    for key, config in var.instance_config : key => config
  }
}
