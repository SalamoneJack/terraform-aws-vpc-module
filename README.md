# terraform-aws-vpc-module

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazon-aws&logoColor=white)
![Module](https://img.shields.io/badge/Type-Terraform_Module-informational)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

A reusable Terraform module that provisions a standardized AWS VPC with configurable public and private subnets across multiple Availability Zones. Call it once for dev, once for prod — same network topology, different parameters, zero duplication.

> ### Deployed and verified
>
> The `examples/simple-vpc/` example was applied to AWS to verify the module produces clean, correct infrastructure. 7 resources created from a single module call (VPC, IGW, 2 public subnets across 2 AZs, route table, 2 associations). Includes a bug fix where `zipmap` was guarded against empty `*_subnet_cidrs` lists — a footgun discovered during this validation pass.
>
> **Module design notes, deployment output, reuse example:** [`Documentation/`](Documentation/)

## Repository Tour

- **[`modules/vpc/`](modules/vpc/)** — the reusable module itself (the main artifact)
- **[`examples/simple-vpc/`](examples/simple-vpc/)** — single-environment consumer
- **[`examples/prod-dev/`](examples/prod-dev/)** — calling the module twice for two environments
- **[`Documentation/`](Documentation/)** — deployment output + design notes

## The Problem

Copy-pasting VPC Terraform across environments is how configuration drift happens. By the time you have prod, dev, and staging, you have three slightly different VPC definitions that are each right in isolation but collectively inconsistent. Reusable modules solve this: one tested definition, called with different inputs.

This is the platform engineering mindset applied to infrastructure: **build the tool once, use it everywhere.**

## Module Structure



```
terraform-aws-vpc-module/
+-- modules/
|   +-- vpc/
|       +-- main.tf          # Resource definitions
|       +-- variables.tf     # Input parameters
|       +-- outputs.tf       # Exported values
|       +-- README.md        # Module-level docs
+-- examples/
|   +-- simple-vpc/
|   |   +-- main.tf          # Basic single-environment usage
|   +-- prod-dev/
|       +-- main.tf          # Calling the module twice: prod + dev
+-- README.md                # This file
+-- .gitignore
```

## Usage

```hcl
module "prod_vpc" {
  source = "github.com/SalamoneJack/terraform-aws-vpc-module//modules/vpc"

  name              = "prod"
  cidr_block        = "10.10.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
  enable_nat_gateway   = true
  
  tags = {
    Environment = "prod"
    Owner       = "network-team"
  }
}

module "dev_vpc" {
  source = "github.com/SalamoneJack/terraform-aws-vpc-module//modules/vpc"

  name              = "dev"
  cidr_block        = "10.20.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
  enable_nat_gateway   = false   # Save cost in dev
  
  tags = {
    Environment = "dev"
    Owner       = "network-team"
  }
}
```

## Inputs

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `name` | `string` | — | yes | Environment name, used in resource tags and names |
| `cidr_block` | `string` | — | yes | CIDR block for the VPC |
| `availability_zones` | `list(string)` | — | yes | List of AZs to create subnets in |
| `public_subnet_cidrs` | `list(string)` | `[]` | no | CIDR blocks for public subnets (one per AZ) |
| `private_subnet_cidrs` | `list(string)` | `[]` | no | CIDR blocks for private subnets (one per AZ) |
| `enable_nat_gateway` | `bool` | `false` | no | Create a NAT Gateway for private subnet egress |
| `enable_dns_hostnames` | `bool` | `true` | no | Enable DNS hostnames in the VPC |
| `enable_flow_logs` | `bool` | `false` | no | Enable VPC Flow Logs to CloudWatch |
| `tags` | `map(string)` | `{}` | no | Tags to apply to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The VPC ID |
| `vpc_cidr` | The VPC CIDR block |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `internet_gateway_id` | ID of the Internet Gateway |
| `nat_gateway_id` | ID of the NAT Gateway (if created) |

## Examples

### Simple VPC — [`examples/simple-vpc/`](examples/simple-vpc/)

Single VPC with public subnets only. Good for a lab or single-tier application.

### Prod + Dev — [`examples/prod-dev/`](examples/prod-dev/)

Calls the module twice with different parameters to demonstrate configuration consistency across environments. Prod gets NAT Gateway; dev doesn't. Same topology, different cost profile.

## Design Decisions

**Why `for_each` on subnets, not `count`?**  
`count` produces subnet resources indexed by number (`aws_subnet.public[0]`). If you remove the first AZ, Terraform wants to destroy `[0]` and rename `[1]` to `[0]` — causing unnecessary recreation. `for_each` uses stable keys (the AZ name), so removing one AZ only removes that AZ's subnet.

**Why optional NAT Gateway?**  
NAT Gateway costs ~$32/month. Dev environments often don't need private subnet egress. Making it optional lets you save cost where you don't need isolation without creating a separate module definition.

**Why no separate module for each subnet tier?**  
Splitting into vpc-module, public-subnet-module, private-subnet-module is premature abstraction for this use case. The VPC and its subnets are always deployed together; the coupling is intentional.

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5 |
| AWS Provider | ~> 5.0 |

## What I Learned

- The difference between `count` and `for_each` in Terraform isn't just style — it's about stable resource addressing. `for_each` with meaningful keys prevents Terraform from destroying and recreating resources when list order changes
- A module's `outputs.tf` is its API contract. If a caller needs a value, it must be in outputs — internal resource attributes aren't accessible from outside the module
- The `//` in a module source path (`github.com/user/repo//modules/vpc`) is the Terraform convention for "subdirectory within this repo" — it's not a typo
- Writing a module for internal use taught me what "good module design" actually means: minimize required variables, maximize flexibility through optional ones, export everything a caller might need

## Related Projects

This module is used in:
- [aws-ha-web-app](https://github.com/SalamoneJack/aws-ha-web-app) — HA application on top of this VPC pattern
- [aws-multi-vpc-hub-spoke](https://github.com/SalamoneJack/aws-multi-vpc-hub-spoke) — Hub-and-spoke with multiple instances of this module
