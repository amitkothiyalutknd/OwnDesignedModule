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

resource "aws_instance" "Instances" {
  depends_on                  = [aws_route_table_association.AssoRouteTable]
  for_each                    = var.instance_config
  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type
  user_data                   = file(each.value.user_data_file) # Script written in seperate shell file for this instances.
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
  public_key = file("./terrainstance.pub")
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

# Create IAM Role for EC2
resource "aws_iam_role" "s3_full_access_role" {
  name = "s3-full-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com" # This allows EC2 instances to assume this role
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

# Create IAM Policy to Allow Full S3 Access
resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "S3FullAccessPolicy"
  description = "Policy granting full access to a specific S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      #   {
      #     Action   = "s3:CreateBucket"
      #     Effect   = "Allow"
      #     Resource = "arn:aws:s3:::*" # Allows Only creation of any bucket
      #   },
      #   {
      #     Action   = "s3:ListAllMyBuckets" # Allows Only Access of any bucket
      #     Effect   = "Allow"
      #     Resource = "*"
      #   },
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*" # Allows any action to perform with any bucket
        #     Resource = [
        #       "arn:aws:s3:::moduled-bucket-1",
        #       "arn:aws:s3:::moduled-bucket-1/*",
        #       "arn:aws:s3:::moduled-bucket-2",
        #       "arn:aws:s3:::moduled-bucket-2/*"
        #   ]
      }
    ]
  })
}

# Create EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile-for-s3"
  role = aws_iam_role.s3_full_access_role.name
}

# Attach the S3 Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "attach_s3_full_access_policy" {
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
  role       = aws_iam_role.s3_full_access_role.name
}

resource "aws_security_group" "SG" {
  description = "This is Configuration of SG."
  name        = "${var.environment}-SG"

  tags = {
    Name = "${var.environment}-SG."
  }
  vpc_id = aws_vpc.VPC.id #Interpolation
  #Incoming traffic
  ingress {
    description = "This is for accessing of ssh."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #0.0.0.0/0 means all IP addresses
  }

  ingress {
    description = "This is for accessing of HTTP."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #0.0.0.0/0 means all IP addresses
  }

  ingress {
    description = "This is for accessing of HTTPS."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #0.0.0.0/0 means all IP addresses
  }

  #Outgoing traffic
  egress {
    description = "This is for outgoing internet traffic."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

