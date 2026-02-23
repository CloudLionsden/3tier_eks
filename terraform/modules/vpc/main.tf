data "aws_availability_zones" "available" {}

# ------------------------
# VPC
# ------------------------
# This creates the main Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr              # Your chosen IP range
  enable_dns_support   = true                       # Required for AWS services
  enable_dns_hostnames = true                       # Needed for ALB/EKS DNS names
  tags = { Name = "3tier-vpc" }
}

# ------------------------
# Internet Gateway (Public access)
# ------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "3tier-igw" }
}

# ------------------------
# Public Subnets (for ALB / NAT Gateway)
# ------------------------
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[0]
  map_public_ip_on_launch = true                    # Assign public IP automatically
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = { Name = "public-1" }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[1]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = { Name = "public-2" }
}

# ------------------------
# Private App Subnets (for EKS nodes)
# ------------------------
resource "aws_subnet" "app1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_app_subnets[0]
  map_public_ip_on_launch = false                   # Private subnet
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = { Name = "app-1" }
}

resource "aws_subnet" "app2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_app_subnets[1]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = { Name = "app-2" }
}

# ------------------------
# Private DB Subnets (for RDS)
# ------------------------
resource "aws_subnet" "db1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_db_subnets[0]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = { Name = "db-1" }
}

resource "aws_subnet" "db2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_db_subnets[1]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = { Name = "db-2" }
}

# ------------------------
# NAT Gateway (for private subnets Internet access)
# ------------------------
# Elastic IP for NAT
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway in public subnet 1
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id
  tags          = { Name = "nat-gateway" }
}

# ------------------------
# Route Tables
# ------------------------

# Public route table → Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# Private App route table → NAT Gateway
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = { Name = "app-rt" }
}

resource "aws_route_table_association" "app1_assoc" {
  subnet_id      = aws_subnet.app1.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "app2_assoc" {
  subnet_id      = aws_subnet.app2.id
  route_table_id = aws_route_table.private_app.id
}

# Private DB route table → NAT Gateway (optional)
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = { Name = "db-rt" }
}

resource "aws_route_table_association" "db1_assoc" {
  subnet_id      = aws_subnet.db1.id
  route_table_id = aws_route_table.private_db.id
}

resource "aws_route_table_association" "db2_assoc" {
  subnet_id      = aws_subnet.db2.id
  route_table_id = aws_route_table.private_db.id
}
