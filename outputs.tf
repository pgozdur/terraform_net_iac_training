output "instance_external_dns" {
  value = { for i, instance in aws_instance.lab_instance : instance.tags["Name"] => instance.public_dns }
  description = "The external DNS names of the EC2 instances"
}

output "instance_tags" {
  value = [for instance in aws_instance.lab_instance : instance.tags["Name"]]
  description = "The tags (e.g., student_1) of the EC2 instances"
}

output "instance_public_ips" {
  value = { for instance in aws_instance.lab_instance : instance.tags["Name"] => instance.public_ip }
  description = "The public IP addresses of the EC2 instances"
}

output "ssh_commands" {
  value = [for instance in aws_instance.lab_instance : "ssh -i terraform-ec2-key ubuntu@${instance.public_ip}"]
  description = "Commands to SSH into each EC2 instance. Assumes key terraform-ec2-key in current folder"
}
