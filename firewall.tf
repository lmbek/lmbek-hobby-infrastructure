# ─────────────────────────────────────────────────────────────────────────────
# Hetzner Cloud Firewall Configuration
# Restricts public access to SSH, HTTP, HTTPS and secures internal traffic.
# ─────────────────────────────────────────────────────────────────────────────

resource "hcloud_firewall" "k3s_firewall" {
  name = "k3s-cluster-firewall"

  # SSH Administration (Restricted or Public per var.allowed_ssh_ips)
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = var.allowed_ssh_ips
    description = "Allow SSH management from authorized IP ranges"
  }

  # Public HTTP Traffic (Traefik Ingress)
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow HTTP public web traffic"
  }

  # Public HTTPS Traffic (Traefik Ingress)
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow HTTPS secure public web traffic"
  }

  # Allow the K3s API from the private subnet.
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [
      "10.0.1.0/24"
    ]
    description = "Allow the internal K3s API"
  }

  # Allow kubelet metrics and exec/log traffic from the private subnet.
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "10250"
    source_ips = [
      "10.0.1.0/24"
    ]
    description = "Allow internal kubelet traffic"
  }

  # Allow Flannel VXLAN encapsulation between nodes.
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "8472"
    source_ips = [
      "10.0.1.0/24"
    ]
    description = "Allow internal Flannel VXLAN traffic"
  }
}
