# Create VPC
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Create subnets
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# Create a route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id
}

# Create an internet gateway route
resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.example.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

# Associate the route table with the subnet
resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.example.id
}

resource "aws_security_group" "example" {
  vpc_id      = aws_vpc.example.id
  name        = "example-security-group"
  description = "Example Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432 # Allow PostgreSQL connections
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = -1 # Allow all traffic using the ICMP protocol
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }

  lifecycle {
    ignore_changes = [
      name,
      vpc_id,
      description
    ]
  }
}

# resource "aws_security_group_rule" "example_http_ingress" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.example.id
# }

# resource "aws_security_group_rule" "example_https_ingress" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.example.id
# }

# Create DB parameter group
resource "aws_db_parameter_group" "example" {
  name        = "example-db-parameter-group"
  family      = "postgres12"
  description = "Example DB parameter group"

  lifecycle {
    ignore_changes = [
      name,
      description,
      family
    ]
  }
}

# Create DB subnet group
resource "aws_db_subnet_group" "example" {
  name        = "example-db-subnet-group"
  description = "Example DB subnet group"
  subnet_ids  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  lifecycle {
    ignore_changes = [
      name,
      subnet_ids,
      description
    ]
  }
}
