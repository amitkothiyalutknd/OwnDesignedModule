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
