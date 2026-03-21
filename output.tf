# Output of the Instance Hostname
output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.app_server.private_dns
}

# Output of the Instance public ip
output "instance_public_ip" {
  description = "Public IP of the Instance"
  value = aws_instance.app_server.public_ip
}

# ID of the EC2 Instance
output "instance_id" {
  description = "ID of the the EC2 Instance"
  value = aws_instance.app_server.id
}

# Output of the Instance Private IP
output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}
