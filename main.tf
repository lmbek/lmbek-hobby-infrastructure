# ─────────────────────────────────────────────────────────────────────────────
# Hetzner Cloud 2-Node K3s Cluster Provisioning (Master + Worker)
# ─────────────────────────────────────────────────────────────────────────────

resource "random_password" "cluster_token" {
  length  = 32
  special = false
}

locals {
  actual_cluster_token = var.k3s_cluster_token != "" ? var.k3s_cluster_token : random_password.cluster_token.result
  master_private_ip    = "10.0.1.10"
  worker_private_ip    = "10.0.1.11"
}

resource "hcloud_ssh_key" "admin_key" {
  count      = var.ssh_public_key != "" ? 1 : 0
  name       = var.ssh_key_name
  public_key = var.ssh_public_key
}

# ── Cloud-Init Templates ─────────────────────────────────────────────────────

data "cloudinit_config" "master_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/../servers/cloud-init-master.yaml", {
      cluster_token      = local.actual_cluster_token
      master_private_ip  = local.master_private_ip
      ssh_public_key     = var.ssh_public_key
    })
  }
}

data "cloudinit_config" "worker_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/../servers/cloud-init-worker.yaml", {
      cluster_token      = local.actual_cluster_token
      master_private_ip  = local.master_private_ip
      worker_private_ip  = local.worker_private_ip
      ssh_public_key     = var.ssh_public_key
    })
  }
}

# ── Server 1: K3s Master (Control Plane & ArgoCD) ────────────────────────────

resource "hcloud_server" "k3s_master" {
  name         = "k3s-master"
  image        = var.server_image
  server_type  = var.server_type
  location     = var.server_location
  ssh_keys     = var.ssh_public_key != "" ? [hcloud_ssh_key.admin_key[0].id] : []
  user_data    = data.cloudinit_config.master_config.rendered
  firewall_ids = [hcloud_firewall.k3s_firewall.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    role        = "master"
    cluster     = "k3s-cluster"
    environment = var.environment
  }
}

resource "hcloud_server_network" "master_network" {
  server_id  = hcloud_server.k3s_master.id
  network_id = hcloud_network.k3s_network.id
  ip         = local.master_private_ip
  depends_on = [hcloud_network_subnet.k3s_subnet]
}

# ── Server 2: K3s Worker (Workloads & Pods) ──────────────────────────────────

resource "hcloud_server" "k3s_worker" {
  name         = "k3s-worker"
  image        = var.server_image
  server_type  = var.server_type
  location     = var.server_location
  ssh_keys     = var.ssh_public_key != "" ? [hcloud_ssh_key.admin_key[0].id] : []
  user_data    = data.cloudinit_config.worker_config.rendered
  firewall_ids = [hcloud_firewall.k3s_firewall.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    role        = "worker"
    cluster     = "k3s-cluster"
    environment = var.environment
  }

  depends_on = [hcloud_server_network.master_network]
}

resource "hcloud_server_network" "worker_network" {
  server_id  = hcloud_server.k3s_worker.id
  network_id = hcloud_network.k3s_network.id
  ip         = local.worker_private_ip
  depends_on = [hcloud_network_subnet.k3s_subnet]
}
