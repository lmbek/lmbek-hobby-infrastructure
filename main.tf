locals {
  effective_server_size   = coalesce(var.server_size, var.server_type)
  effective_server_region = coalesce(var.server_region, var.server_location)
}

resource "hcloud_ssh_key" "admin_key" {
  name       = "${var.server_name}-admin"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "k3s_master" {
  name        = var.server_name
  image       = var.server_image
  server_type = local.effective_server_size
  location    = local.effective_server_region
  ssh_keys    = [hcloud_ssh_key.admin_key.id]
  user_data = templatefile("${path.module}/cloud-init/k3s.yaml.tftpl", {
    admin_username        = var.admin_username
    allowed_ssh_commands  = join("\n", [for cidr in var.allowed_ssh_ips : "  - ufw allow from ${cidr} to any port 22 proto tcp"])
    domain                = var.domain
    github_repository_url = var.github_repository_url
    github_runner_sha256  = var.github_runner_sha256
    github_runner_token   = var.github_runner_token
    github_runner_version = var.github_runner_version
    k3s_version           = var.k3s_version
    letsencrypt_email     = var.letsencrypt_email
    server_name           = var.server_name
    ssh_public_key        = var.ssh_public_key
  })
  firewall_ids = [hcloud_firewall.k3s_firewall.id]

  labels = {
    project    = "lmbek-hobby"
    managed-by = "terraform"
  }
}
