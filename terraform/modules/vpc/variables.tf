# The main VPC CIDR block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Public subnet CIDRs
variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

# Private application subnet CIDRs
variable "private_app_subnets" {
  description = "List of private application subnet CIDR blocks"
  type        = list(string)
}

# Private database subnet CIDRs
variable "private_db_subnets" {
  description = "List of private database subnet CIDR blocks"
  type        = list(string)
}
