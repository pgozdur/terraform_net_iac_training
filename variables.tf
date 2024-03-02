variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.xlarge"
}

variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "terraform-ec2-key"
}
