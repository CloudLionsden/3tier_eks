# Output the VPC ID so other modules can reference it
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# Output the private application subnets
output "private_subnet_ids" {
  description = "List of private subnet IDs for apps and databases"
  value = [
    aws_subnet.app1.id,
    aws_subnet.app2.id
  ]
}

# Optional: output public subnets too if needed
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]
}
