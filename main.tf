# VPC
resource "aws_vpc" "lab_network" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "lab_network"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.lab_network.id
}

# Subnet
resource "aws_subnet" "lab_subnet" {
  vpc_id                  = aws_vpc.lab_network.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Route Table
resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.lab_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "lab_subnet_association" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_route_table.id
}

# Security Group
resource "aws_security_group" "lab_sg" {
  vpc_id = aws_vpc.lab_network.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SSH Key Pair
resource "aws_key_pair" "deployer_key" {
  key_name   = var.key_name
  public_key = file("${path.module}/${var.key_name}.pub")
}

# EC2 Instances
resource "aws_instance" "lab_instance" {
  count         = 14
  ami           = "ami-123456" # Replace with the actual AMI ID for Ubuntu 22.04 in Frankfurt
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer_key.key_name
  subnet_id     = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  tags = {
    Name = "student_${count.index + 1}"
  }

  user_data = <<-EOF
                #!/bin/bash
                hostnamectl set-hostname "student_${count.index + 1}"
                echo "127.0.0.1 student_${count.index + 1}" >> /etc/hosts
                sudo apt-get update
                sudo apt install -y python3.10-venv
                sudo apt-get install -y docker-compose
                EOF
}
