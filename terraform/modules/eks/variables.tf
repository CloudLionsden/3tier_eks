############################################
# EKS Cluster Name
############################################
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}


############################################
# Subnets for EKS nodes
############################################
variable "private_subnet_ids" {
  description = "Subnet IDs for EKS cluster"
  type        = list(string)
}

############################################
# REGION
############################################
variable "region" {
  type = string
}
