variable "name" {
  description = "Environment name, used in resource names and tags (e.g., prod, dev, staging)"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zone names to create subnets in"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets — must have one per AZ"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets — must have one per AZ"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Create a NAT Gateway for private subnet internet egress (adds ~$32/mo)"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch"
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Days to retain flow logs in CloudWatch (only used if enable_flow_logs = true)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
