variable "hcloud_token" {
  description = "Hetzner Cloud API Token. Obtain from https://console.hetzner.cloud (Security -> API Tokens with Read & Write permissions)."
  type        = string
  sensitive   = true
}

variable "server_type" {
  description = "Hetzner Cloud VPS server type."
  type        = string
  default     = "cx23"
}

variable "server_location" {
  description = "Hetzner datacenter location."
  type        = string
  default     = "fsn1"
}

variable "server_image" {
  description = "Base operating system image for the servers."
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key" {
  description = "SSH public key content for emergency administrative access."
  type        = string
}

variable "allowed_ssh_ips" {
  description = "CIDR blocks permitted to connect to SSH."
  type        = list(string)
}
