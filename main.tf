provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "lab_network" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "lab_network"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.lab_network.id
}

resource "aws_subnet" "lab_subnet" {
  vpc_id            = aws_vpc.lab_network.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.lab_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_route_table.id
}

resource "aws_security_group" "lab_sg" {
  vpc_id = aws_vpc.lab_network.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add other ingress rules similarly for ports 443, 8080, 8443

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "lab_instance" {
  count         = 14
  ami           = "ami-123456" # Replace with the correct AMI ID for Ubuntu in Frankfurt
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.lab_subnet.id
  security_groups = [aws_security_group.lab_sg.name]

  tags = {
    Name = "student_${count.index + 1}"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt install -y python3.10-venv
              sudo apt-get install -y 'docker-compose=1.29.2-1'
              EOF
}
