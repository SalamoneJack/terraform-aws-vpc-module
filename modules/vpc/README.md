# Module: vpc

Creates a standardized AWS VPC with optional public subnets, private subnets, NAT Gateway, and VPC Flow Logs.

## Usage

```hcl
module "vpc" {
  source = "github.com/SalamoneJack/terraform-aws-vpc-module//modules/vpc"

  name               = "prod"
  cidr_block         = "10.10.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

  enable_nat_gateway = true
  enable_flow_logs   = true

  tags = { Environment = "prod" }
}
```

## Inputs

See [variables.tf](variables.tf) for full descriptions.

| Name | Required | Default |
|------|----------|---------|
| `name` | yes | — |
| `cidr_block` | yes | — |
| `availability_zones` | yes | — |
| `public_subnet_cidrs` | no | `[]` |
| `private_subnet_cidrs` | no | `[]` |
| `enable_nat_gateway` | no | `false` |
| `enable_flow_logs` | no | `false` |
| `tags` | no | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr` | VPC CIDR |
| `public_subnet_ids_list` | List of public subnet IDs |
| `private_subnet_ids_list` | List of private subnet IDs |
| `nat_gateway_id` | NAT Gateway ID (null if not created) |
