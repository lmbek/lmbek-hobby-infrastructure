output "ingress_target_ip" {
  description = "Public IPv4 address for the application DNS A record"
  value       = hcloud_server.k3s_master.ipv4_address
}

output "urls" {
  description = "Public website URL"
  value = {
    production = "https://${var.domain}"
  }
}

output "admin_ssh_command" {
  description = "Emergency-only SSH command; CI/CD never uses SSH"
  value       = "ssh ${var.admin_username}@${hcloud_server.k3s_master.ipv4_address}"
}
