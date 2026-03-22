output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of all private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of all public subnet IDs"
  value       = module.vpc.public_subnets
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "default_security_group_id" {
  description = "Default security group ID of the VPC"
  value       = module.vpc.default_security_group_id
}