############################################
# VPC ID where RDS will be deployed
############################################
variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

############################################
# Private subnet IDs for DB subnet group
############################################
variable "subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}
