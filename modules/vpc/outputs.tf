output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "The VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Map of AZ → public subnet ID"
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "public_subnet_ids_list" {
  description = "List of public subnet IDs (for resources expecting a list)"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Map of AZ → private subnet ID"
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
}

output "private_subnet_ids_list" {
  description = "List of private subnet IDs (for resources expecting a list)"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway (null if no public subnets)"
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (null if not created)"
  value       = length(aws_nat_gateway.this) > 0 ? aws_nat_gateway.this[0].id : null
}
