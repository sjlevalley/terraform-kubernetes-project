# Output values for the Kubernetes cluster instances

output "jumpbox_public_ip" {
  description = "Public IP address of the jumpbox (administration host)"
  value       = aws_instance.jumpbox.public_ip
}

output "jumpbox_private_ip" {
  description = "Private IP address of the jumpbox"
  value       = aws_instance.jumpbox.private_ip
}

output "server_public_ip" {
  description = "Public IP address of the Kubernetes server (control plane)"
  value       = aws_instance.server.public_ip
}

output "server_private_ip" {
  description = "Private IP address of the Kubernetes server"
  value       = aws_instance.server.private_ip
}

output "node_0_public_ip" {
  description = "Public IP address of node-0 (worker node)"
  value       = aws_instance.node_0.public_ip
}

output "node_0_private_ip" {
  description = "Private IP address of node-0"
  value       = aws_instance.node_0.private_ip
}

output "node_1_public_ip" {
  description = "Public IP address of node-1 (worker node)"
  value       = aws_instance.node_1.public_ip
}

output "node_1_private_ip" {
  description = "Private IP address of node-1"
  value       = aws_instance.node_1.private_ip
}

output "fqdns" {
  description = "Fully qualified domain names for all instances"
  value = {
    jumpbox = "jumpbox.kubernetes.local"
    server  = "server.kubernetes.local"
    node-0  = "node-0.kubernetes.local"
    node-1  = "node-1.kubernetes.local"
  }
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
