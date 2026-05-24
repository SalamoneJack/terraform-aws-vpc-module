terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Prod: full setup with private subnets, NAT Gateway, and flow logs
module "prod_vpc" {
  source = "../../modules/vpc"

  name               = "prod"
  cidr_block         = "10.10.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

  enable_nat_gateway      = true
  enable_flow_logs        = true
  flow_log_retention_days = 90

  tags = {
    Environment = "prod"
    CostCenter  = "engineering"
  }
}

# Dev: public subnets only, no NAT Gateway (save ~$32/mo in dev)
module "dev_vpc" {
  source = "../../modules/vpc"

  name               = "dev"
  cidr_block         = "10.20.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]

  enable_nat_gateway = false
  enable_flow_logs   = false

  tags = {
    Environment = "dev"
    CostCenter  = "engineering"
  }
}

output "prod_vpc_id" {
  value = module.prod_vpc.vpc_id
}

output "prod_private_subnets" {
  value = module.prod_vpc.private_subnet_ids_list
}

output "dev_vpc_id" {
  value = module.dev_vpc.vpc_id
}

output "dev_public_subnets" {
  value = module.dev_vpc.public_subnet_ids_list
}
