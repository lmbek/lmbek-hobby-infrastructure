resource "hcloud_ssh_key" "admin_key" {
  name       = "lmbek-hobby-admin"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "k3s_master" {
  name         = "lmbek-k3s"
  image        = var.server_image
  server_type  = var.server_type
  location     = var.server_location
  ssh_keys     = [hcloud_ssh_key.admin_key.id]
  user_data    = file("${path.module}/../servers/cloud-init.yaml")
  firewall_ids = [hcloud_firewall.k3s_firewall.id]

  labels = {
    project    = "lmbek-hobby"
    managed-by = "terraform"
  }
}
