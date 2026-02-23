##########################################################
# PROVIDER
##########################################################

# Define the AWS provider for this module
# Terraform uses this provider to create all AWS resources
provider "aws" {
  region = var.region
}

module "vpc" {
  source           = "./modules/vpc"
  vpc_cidr         = "10.0.0.0/16"
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  private_db_subnets  = ["10.0.21.0/24", "10.0.22.0/24"]
}

module "eks" {
  source       = "./modules/eks"

  cluster_name         = var.cluster_name
  private_subnet_ids   = module.vpc.private_subnet_ids
  region               = var.region
}


module "rds" {
  source     = "./modules/rds"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}

module "ecr" {
  source = "./modules/ecr"
}
