variable "hcloud_token" {
  description = "Hetzner Cloud API Token. Obtain from https://console.hetzner.cloud (Security -> API Tokens with Read & Write permissions)."
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name assigned to the single K3s server."
  type        = string
  default     = "lmbek-k3s"
}

variable "server_type" {
  description = "Deprecated compatibility alias for server_size."
  type        = string
  default     = "cx23"
}

variable "server_size" {
  description = "Provider-specific VPS size; defaults to the legacy server_type value when null."
  type        = string
  default     = null
  nullable    = true
}

variable "server_location" {
  description = "Deprecated compatibility alias for server_region."
  type        = string
  default     = "fsn1"
}

variable "server_region" {
  description = "Provider-specific server region; defaults to the legacy server_location value when null."
  type        = string
  default     = null
  nullable    = true
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

  validation {
    condition     = length(var.allowed_ssh_ips) > 0 && !contains(var.allowed_ssh_ips, "0.0.0.0/0") && !contains(var.allowed_ssh_ips, "::/0")
    error_message = "allowed_ssh_ips must contain trusted CIDRs and must not expose SSH to the whole internet."
  }
}

variable "admin_username" {
  description = "Non-root operating-system account used only for emergency administration."
  type        = string
  default     = "k3sadmin"
}

variable "domain" {
  description = "Public application hostname."
  type        = string
}

variable "letsencrypt_email" {
  description = "Email used for Let's Encrypt expiry and account notices."
  type        = string
}

variable "github_repository_url" {
  description = "HTTPS URL of the platform repository that owns the self-hosted deployment runner."
  type        = string
  default     = "https://github.com/lmbek/lmbek-hobby-platform"
}

variable "github_runner_token" {
  description = "Short-lived, single-use GitHub Actions runner registration token. It expires after one hour."
  type        = string
  sensitive   = true
}

variable "github_runner_version" {
  description = "Pinned GitHub Actions runner version."
  type        = string
  default     = "2.328.0"
}

variable "github_runner_sha256" {
  description = "SHA-256 checksum for the pinned Linux x64 GitHub Actions runner archive."
  type        = string
  default     = "01066fad3a2893e63e6ca880ae3a1fad5bf9329d60e77ee15f2b97c148c3cd4e"
}

variable "k3s_version" {
  description = "Pinned K3s release installed by cloud-init."
  type        = string
  default     = "v1.36.4+k3s1"
}
