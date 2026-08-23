variable "hcloud_token" {
  description = "Hetzner Cloud API Token. Obtain from https://console.hetzner.cloud (Security -> API Tokens with Read & Write permissions)."
  type        = string
  sensitive   = true
}

variable "server_type" {
  description = "Hetzner Cloud VPS server type (cx23 for 2 vCPU, 4GB RAM x86 at ~€3.79/mo)."
  type        = string
  default     = "cx23"
}

variable "server_location" {
  description = "Hetzner datacenter location (fsn1 = Falkenstein, nbg1 = Nuremberg, hel1 = Helsinki, ash = Ashburn, hil = Hillsboro)."
  type        = string
  default     = "fsn1"
}

variable "server_image" {
  description = "Base operating system image for the servers."
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key" {
  description = "SSH public key content for administrative login to cluster servers."
  type        = string
  default     = ""
}

variable "allowed_ssh_ips" {
  description = "List of IPv4 and IPv6 CIDR blocks permitted to connect to SSH (port 22). To maximize security, restrict to your specific IP address e.g. [\"203.0.113.10/32\"]."
  type        = list(string)
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
}

variable "ssh_key_name" {
  description = "Name identifier for the SSH key in Hetzner Cloud Console."
  type        = string
  default     = "lmbek-hobby-key"
}

variable "k3s_cluster_token" {
  description = "Shared cluster token for node join. If left empty, a secure random token will be generated automatically."
  type        = string
  default     = ""
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment name (production, staging, etc.)."
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Primary domain name for ingress routing and certificate generation (e.g. example.com or lmbek.local)."
  type        = string
  default     = "lmbek.local"
}

variable "acme_email" {
  description = "Contact email address for Let's Encrypt TLS certificate expiration notices."
  type        = string
  default     = "admin@lmbek.local"
}

variable "enable_load_balancer" {
  description = "Whether to provision a dedicated Hetzner Cloud Load Balancer (lb11) in front of the K3s cluster."
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Hetzner Cloud Load Balancer model type (e.g. lb11 for entry tier)."
  type        = string
  default     = "lb11"
}
