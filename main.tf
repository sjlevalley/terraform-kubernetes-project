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

# Data source to get the latest Debian 12 (bookworm) AMI
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian Cloud Team

  filter {
    name   = "name"
    values = ["debian-12-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
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

# Create a security group for Kubernetes cluster
resource "aws_security_group" "k8s_cluster" {
  name_prefix = "k8s-cluster-sg"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Kubernetes API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API server"
  }

  # etcd server client API
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
    description = "etcd server client API"
  }

  # Kubelet API
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
    description = "Kubelet API"
  }

  # kube-scheduler
  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    self        = true
    description = "kube-scheduler"
  }

  # kube-controller-manager
  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    self        = true
    description = "kube-controller-manager"
  }

  # kube-proxy
  ingress {
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    self        = true
    description = "kube-proxy"
  }

  # NodePort services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort Services"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "k8s-cluster-sg"
  }
}

# Create a key pair for SSH access
resource "aws_key_pair" "k8s-key" {
  key_name   = "k8s-key"
  public_key = file("${path.module}/ssh/k8s-key.pub")
}

# Jumpbox - Administration host (1 vCPU, 512MB RAM, 10GB storage)
resource "aws_instance" "jumpbox" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"  # 1 vCPU, 1GB RAM (closest to 512MB requirement)
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  key_name               = aws_key_pair.k8s-key.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 10  # 10GB storage requirement
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y curl wget vim
              EOF

  tags = {
    Name = "jumpbox"
    Role = "administration"
  }
}

# Server - Kubernetes control plane (1 vCPU, 2GB RAM, 20GB storage)
resource "aws_instance" "server" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.small"  # 1 vCPU, 2GB RAM
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  key_name               = aws_key_pair.k8s-key.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20  # 20GB storage requirement
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y curl wget vim
              EOF

  tags = {
    Name = "server"
    Role = "kubernetes-control-plane"
  }
}

# Node-0 - Kubernetes worker node (1 vCPU, 2GB RAM, 20GB storage)
resource "aws_instance" "node_0" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.small"  # 1 vCPU, 2GB RAM
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  key_name               = aws_key_pair.k8s-key.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20  # 20GB storage requirement
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y curl wget vim
              EOF

  tags = {
    Name = "node-0"
    Role = "kubernetes-worker"
  }
}

# Node-1 - Kubernetes worker node (1 vCPU, 2GB RAM, 20GB storage)
resource "aws_instance" "node_1" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.small"  # 1 vCPU, 2GB RAM
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  key_name               = aws_key_pair.k8s-key.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20  # 20GB storage requirement
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y curl wget vim
              EOF

  tags = {
    Name = "node-1"
    Role = "kubernetes-worker"
  }
}




# Output values for the Kubernetes cluster instances

output "jumpbox_public_ip" {
  description = "Public IP address of the jumpbox (administration host)"
  value       = aws_instance.jumpbox.public_ip
}

output "server_public_ip" {
  description = "Public IP address of the Kubernetes server (control plane)"
  value       = aws_instance.server.public_ip
}

output "node_0_public_ip" {
  description = "Public IP address of node-0 (worker node)"
  value       = aws_instance.node_0.public_ip
}

output "node_1_public_ip" {
  description = "Public IP address of node-1 (worker node)"
  value       = aws_instance.node_1.public_ip
}

output "cluster_info" {
  description = "Kubernetes cluster information"
  value = {
    jumpbox_ip = aws_instance.jumpbox.public_ip
    server_ip  = aws_instance.server.public_ip
    node_0_ip  = aws_instance.node_0.public_ip
    node_1_ip  = aws_instance.node_1.public_ip
    ssh_key    = "k8s-key"
  }
}


