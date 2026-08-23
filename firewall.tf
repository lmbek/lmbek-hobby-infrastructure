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

  # Allow all intra-cluster TCP traffic on private subnet (including internal K3s API 6443)
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "1-65535"
    source_ips = [
      "10.0.0.0/16"
    ]
    description = "Allow all internal TCP across private network (K3s API, Flannel, kubelet)"
  }

  # Allow all intra-cluster UDP traffic (Flannel VXLAN / WireGuard)
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "1-65535"
    source_ips = [
      "10.0.0.0/16"
    ]
    description = "Allow all internal UDP pod network traffic"
  }
}
