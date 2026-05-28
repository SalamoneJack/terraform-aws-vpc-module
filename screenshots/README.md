# Deployment Evidence — terraform-aws-vpc-module (simple-vpc example)

**Status:** LIVE in AWS at capture time (destroyed after this screenshot session)
**Captured:** 2026-05-28
**Region:** us-east-1
**Account:** 904474958504

## What This Lab Demonstrates
This repo is primarily a **reusable Terraform module** (`modules/vpc/`), not a standalone deployment. The `examples/simple-vpc/` example proves the module works by consuming it like any real project would. The value is the module's quality, not the size of what gets deployed.

## Module Design Highlights

- **`for_each` over `count`** for subnet creation — avoids index-shift recreation when AZs reorder, a classic terraform footgun
- **AZ ↔ CIDR map locals** via `zipmap`, guarded against empty `*_subnet_cidrs` lists (see [fix in this commit](https://github.com/SalamoneJack/terraform-aws-vpc-module/commit/main))
- **Conditional NAT Gateway** (off by default — `enable_nat_gateway = false` saves ~$32/mo unless explicitly enabled)
- **Optional VPC Flow Logs** built into the module — observability shouldn't be a separate decision
- Tags merged consistently via `local.common_tags` for cost-allocation and ownership

## Deployment Output

Captured from `terraform output` after `apply`:

```
public_subnet_ids = [
  "subnet-0fe4469faeee2bf41",
  "subnet-076cf9eef9e2a89f6",
]
vpc_id = "vpc-06912d18aee4849bd"
```

7 resources created from this single module call: 1 VPC, 1 IGW, 2 public subnets across 2 AZs, 1 route table, 2 route table associations.

## How To Reuse This Module

Drop into any project:

```hcl
module "vpc" {
  source = "git::https://github.com/SalamoneJack/terraform-aws-vpc-module.git//modules/vpc?ref=main"

  name               = "myapp-prod"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  enable_nat_gateway   = true   # ~$32/mo
  enable_flow_logs     = true   # observability baked in

  tags = { Owner = "you", Environment = "prod" }
}
```

The module handles AZ-to-subnet pairing, route tables, and (optionally) NAT egress + flow logs in one block.

## Raw Evidence (this folder)
- `terraform-outputs.txt` — the output above

## Cost
Free (VPC + subnets + IGW + route tables have no per-hour cost). Run as long as you want, or destroy in seconds.
