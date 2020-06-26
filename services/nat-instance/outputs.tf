output "public_ip" {
  value       = aws_instance.nat-instance.public_ip
  description = "The public IP of the server"
}

output "bastion_fqdn" {
  value       = var.bastion_fqdn
  description = "The gateway hostname for this environment"
}