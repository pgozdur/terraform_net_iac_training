output "instance_external_dns" {
  value = { for i, instance in aws_instance.lab_instance : instance.tags["Name"] => instance.public_dns }
  description = "The external DNS names of the EC2 instances"
}

output "instance_tags" {
  value = [for instance in aws_instance.lab_instance : instance.tags["Name"]]
  description = "The tags of the EC2 instances"
}

output "instance_public_ips" {
  value = { for instance in aws_instance.lab_instance : instance.tags["Name"] => instance.public_ip => instance }
  description = "The public IP addresses of the EC2 instances"
}

output "ssh_commands" {
  value = [for instance in aws_instance.lab_instance : instance.tags["Name"] "ssh -i ${path.module}/${var.key_name} ubuntu@${instance.public_ip}"]
  description = "Commands to SSH into each EC2 instance. Ensure your private key permissions are set correctly."
}
