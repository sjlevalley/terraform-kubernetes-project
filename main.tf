# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"  # Free tier is available in us-east-1
}

# Data source to get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get the default subnet
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1a"
}

# Create a security group
resource "aws_security_group" "main" {
  name_prefix = "k8s-sg"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}

# Create a key pair for SSH access
resource "aws_key_pair" "k8s-key" {
  key_name   = "k8s-key"
  public_key = file("${path.module}/ssh/k8s-key.pub")
}

# Create the EC2 instance (Free tier eligible)
resource "aws_instance" "k8s-instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"  # Free tier eligible
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.k8s-key.key_name

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "Hello from Terraform on Ubuntu 22.04!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "k8s-instance"
  }
}




# Output values for the EC2 instance

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.k8s-instance.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.k8s-instance.id
}


