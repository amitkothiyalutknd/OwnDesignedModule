resource "aws_vpc" "VPC" {
  cidr_block = var.vpc_config.cidr_block
  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_subnet" "Subnets" {
  depends_on = [aws_vpc.VPC]
  vpc_id     = aws_vpc.VPC.id
  for_each   = var.subnet_config #key={cidr, az} each.key each.value 

  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = each.key
  }
}

locals {
  public_subnet = {
    #key={} if public is true in subnet_config
    for key, config in var.subnet_config : key => config if config.public
  }
  private_subnet = {
    #key={} if public is false in subnet_config
    for key, config in var.subnet_config : key => config if !config.public
  }
}

#Internete Gateway, if there is alteast one public subnet
resource "aws_internet_gateway" "IGW" {
  depends_on = [aws_vpc.VPC]
  vpc_id     = aws_vpc.VPC.id
  count      = length(local.public_subnet) > 0 ? 1 : 0
  tags = {
    Name = "ModuledIGW"
  }
}

#Routing table
resource "aws_route_table" "RoutTable" {
  count      = length(local.public_subnet) > 0 ? 1 : 0
  depends_on = [aws_internet_gateway.IGW]
  vpc_id     = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW[0].id
  }

  tags = {
    Name = "ModuledRoutTable"
  }
}

resource "aws_route_table_association" "AssoRouteTable" {
  depends_on     = [aws_route_table.RoutTable]
  for_each       = local.public_subnet #public_subnet={} private_subnet={}
  subnet_id      = aws_subnet.Subnets[each.key].id
  route_table_id = aws_route_table.RoutTable[0].id
}
