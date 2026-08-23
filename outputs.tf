output "master_public_ip" {
  description = "Public IPv4 address of the K3s Master node"
  value       = hcloud_server.k3s_master.ipv4_address
}

output "master_private_ip" {
  description = "Private IPv4 address of the K3s Master node"
  value       = local.master_private_ip
}

output "worker_public_ip" {
  description = "Public IPv4 address of the K3s Worker node"
  value       = hcloud_server.k3s_worker.ipv4_address
}

output "worker_private_ip" {
  description = "Private IPv4 address of the K3s Worker node"
  value       = local.worker_private_ip
}

output "ssh_master_command" {
  description = "Command to connect via SSH to the Master node"
  value       = "ssh root@${hcloud_server.k3s_master.ipv4_address}"
}

output "ssh_worker_command" {
  description = "Command to connect via SSH to the Worker node"
  value       = "ssh root@${hcloud_server.k3s_worker.ipv4_address}"
}

output "kubeconfig_command" {
  description = "Command to download kubeconfig from Master node"
  value       = "ssh root@${hcloud_server.k3s_master.ipv4_address} 'cat /etc/rancher/k3s/k3s.yaml' | sed 's/127.0.0.1/${hcloud_server.k3s_master.ipv4_address}/g' > ~/.kube/config-k3s-hetzner"
}

output "k3s_cluster_token" {
  description = "Shared cluster token for K3s nodes"
  value       = local.actual_cluster_token
  sensitive   = true
}

output "load_balancer_ip" {
  description = "Public IPv4 address of the Load Balancer (or empty if disabled)"
  value       = var.enable_load_balancer ? hcloud_load_balancer.cluster_lb[0].ipv4 : ""
}

output "ingress_target_ip" {
  description = "Target public IP for DNS A records (Load Balancer IP if enabled, otherwise Master Node IP)"
  value       = var.enable_load_balancer ? hcloud_load_balancer.cluster_lb[0].ipv4 : hcloud_server.k3s_master.ipv4_address
}

output "production_url" {
  description = "Production frontpage URL (Placeholder 1 application)"
  value       = "https://${var.domain_name}"
}

output "staging_url" {
  description = "Staging frontpage URL (Placeholder 1 application)"
  value       = "https://staging.${var.domain_name}"
}

output "placeholder1_url" {
  description = "Placeholder 1 application URL"
  value       = "https://placeholder1.${var.domain_name}"
}

output "placeholder2_url" {
  description = "Placeholder 2 application URL"
  value       = "https://placeholder2.${var.domain_name}"
}

output "docs_url" {
  description = "Documentation portal URL"
  value       = "https://docs.${var.domain_name}"
}

output "web_frontend_url" {
  description = "Web frontend website URL"
  value       = "https://web.${var.domain_name}"
}
