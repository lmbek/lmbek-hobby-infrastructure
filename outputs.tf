output "ingress_target_ip" {
  description = "Public IPv4 address for the lmbek.dk DNS A record"
  value       = hcloud_server.k3s_master.ipv4_address
}

output "urls" {
  description = "Public website URL"
  value = {
    production = "https://lmbek.dk"
  }
}
