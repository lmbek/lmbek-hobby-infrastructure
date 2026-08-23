# ─────────────────────────────────────────────────────────────────────────────
# Hetzner Cloud Load Balancer (Optional Edge Proxy & Traffic Distribution)
# ─────────────────────────────────────────────────────────────────────────────

resource "hcloud_load_balancer" "cluster_lb" {
  count              = var.enable_load_balancer ? 1 : 0
  name               = "lmbek-k3s-load-balancer"
  load_balancer_type = var.load_balancer_type
  location           = var.server_location

  labels = {
    "project"     = "lmbek-hobby-workspace"
    "environment" = var.environment
    "managed-by"  = "terraform"
  }
}

# Attach Load Balancer to the Private Network
resource "hcloud_load_balancer_network" "lb_private_net" {
  count            = var.enable_load_balancer ? 1 : 0
  load_balancer_id = hcloud_load_balancer.cluster_lb[0].id
  network_id       = hcloud_network.k3s_network.id
  ip               = "10.0.1.250"
}

# Target K3s Master and Worker Server Nodes
resource "hcloud_load_balancer_target" "target_master" {
  count            = var.enable_load_balancer ? 1 : 0
  type             = "server"
  load_balancer_id = hcloud_load_balancer.cluster_lb[0].id
  server_id        = hcloud_server.k3s_master.id
  use_private_ip   = true
  depends_on       = [hcloud_load_balancer_network.lb_private_net]
}

resource "hcloud_load_balancer_target" "target_worker" {
  count            = var.enable_load_balancer ? 1 : 0
  type             = "server"
  load_balancer_id = hcloud_load_balancer.cluster_lb[0].id
  server_id        = hcloud_server.k3s_worker.id
  use_private_ip   = true
  depends_on       = [hcloud_load_balancer_network.lb_private_net]
}

# Service 1: HTTP (Port 80) Forwarding with Health Checks
resource "hcloud_load_balancer_service" "http" {
  count            = var.enable_load_balancer ? 1 : 0
  load_balancer_id = hcloud_load_balancer.cluster_lb[0].id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 80
  proxyprotocol    = false

  health_check {
    protocol = "tcp"
    port     = 80
    interval = 10
    timeout  = 3
    retries  = 3
  }
}

# Service 2: HTTPS (Port 443) Forwarding with Traefik TLS Pass-through
resource "hcloud_load_balancer_service" "https" {
  count            = var.enable_load_balancer ? 1 : 0
  load_balancer_id = hcloud_load_balancer.cluster_lb[0].id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443
  proxyprotocol    = false

  health_check {
    protocol = "tcp"
    port     = 443
    interval = 10
    timeout  = 3
    retries  = 3
  }
}
