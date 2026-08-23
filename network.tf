# ─────────────────────────────────────────────────────────────────────────────
# Hetzner Cloud Private Network Configuration
# Provides a fast, isolated 10.0.1.0/24 subnet for inter-node communication.
# ─────────────────────────────────────────────────────────────────────────────

resource "hcloud_network" "k3s_network" {
  name     = "k3s-private-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "k3s_subnet" {
  network_id   = hcloud_network.k3s_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
