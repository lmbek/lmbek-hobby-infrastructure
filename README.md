# Hetzner Cloud Infrastructure as Code (IaC)

Declarative Terraform infrastructure that provisions **2 cheap Hetzner Cloud VPS servers** (`cx23` / ~€3.79/month each), a private network (`10.0.1.0/24`), and a cloud firewall for running a lightweight 2-node K3s Kubernetes cluster with ArgoCD GitOps.

---

## 📦 Prerequisites: Installing Terraform

Before running Terraform, ensure it is installed on your local machine:

- **Ubuntu / Linux (Snap - Recommended)**:
  ```bash
  sudo snap install --classic terraform
  ```
  *(Note: The `--classic` flag is required by Snap for developer tool confinement).*

- **Ubuntu / Debian (Official APT Repository)**:
  ```bash
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ```

- **macOS (Homebrew)**:
  ```bash
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  ```

- **Windows**:
  ```powershell
  winget install HashiCorp.Terraform
  # or: choco install terraform
  ```

---

## 🔑 Where to Put Your Hetzner API Key

You have two simple options to supply your Hetzner Cloud API token:

### Option A: `terraform.tfvars` (Recommended & Simple)
1. In this directory (`git-repositories/infrastructure/iac`), copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Open `terraform.tfvars` and paste your token:
   ```hcl
   hcloud_token = "your-hetzner-api-token-here"
   ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." # Optional
   ```
> **Security Note:** `terraform.tfvars` is listed in `.gitignore`. Your API token will **never** be committed to Git.

### Option B: Environment Variable
Alternatively, export the token directly in your terminal:
```bash
export HCLOUD_TOKEN="your-hetzner-api-token-here"
```

---

## 🚀 One-Time Server Setup (2 Minutes)

Run Terraform from `git-repositories/infrastructure/iac`:

```bash
# 1. Initialize Terraform and download providers
terraform init

# 2. Preview the infrastructure plan
terraform plan

# 3. Provision the 2 servers, private network, and firewall
terraform apply
```

---

## 🏗️ What Gets Provisioned

```
┌─────────────────────────────────────────────────────────────┐
│                 Hetzner Cloud Project                       │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │        Cloud Firewall: Ports 22, 80, 443            │   │
│   └──────────────────────────┬──────────────────────────┘   │
│                              │                              │
│   ┌──────────────────────────┴──────────────────────────┐   │
│   │        Private Cloud Network: 10.0.1.0/24           │   │
│   │                                                     │   │
│   │   ┌──────────────────────┐  ┌───────────────────┐   │   │
│   │   │ Server 1: k3s-master │  │ Server 2: worker  │   │   │
│   │   │ (Private: 10.0.1.10) │  │ (Priv: 10.0.1.11) │   │   │
│   │   │ - K3s Control Plane  │  │ - Workload Pods   │   │   │
│   │   │ - Traefik Ingress    │  │                   │   │   │
│   │   │ - ArgoCD GitOps      │  │                   │   │   │
│   │   └──────────────────────┘  └───────────────────┘   │   │
│   └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

1. **`k3s-master` (`10.0.1.10`)**: Server 1 running K3s server, Traefik Ingress, cert-manager, and ArgoCD controller.
2. **`k3s-worker` (`10.0.1.11`)**: Server 2 automatically joining the cluster over the private network.
3. **Private Network (`10.0.1.0/24`)**: Fast and secure inter-node communication. The K3s Kubernetes API (port 6443) is bound strictly to the private network and never exposed to the public internet.
4. **Cloud Firewall**: Allows SSH (22), HTTP (80), HTTPS (443), and isolates internal cluster communication.
5. **Optional Hetzner Load Balancer (`lb11`)**: High-availability edge proxy routing HTTP (80) and HTTPS (443) traffic across master and worker nodes.

---

## 🌐 Load Balancers, Proxies & Best Practice URLs

| URL / Host | Target Workload | Environment / Namespace | TLS Certificate |
|---|---|---|---|
| `https://example.com` | Placeholder 1 Application (Frontpage) | `production` | Automatic Let's Encrypt Production SSL |
| `https://staging.example.com` | Placeholder 1 Application (Frontpage) | `staging` | Automatic Let's Encrypt Staging/Prod SSL |
| `https://placeholder1.example.com` | Placeholder 1 Microservice | `production` | Automatic Let's Encrypt Production SSL |
| `https://placeholder2.example.com` | Placeholder 2 Microservice | `production` | Automatic Let's Encrypt Production SSL |
| `https://docs.example.com` | Architecture & Tech Docs | `production` | Automatic Let's Encrypt Production SSL |
| `https://web.example.com` | Web Frontend Developer Profile | `production` | Automatic Let's Encrypt Production SSL |

### Setting Up DNS A Records:
Point your domain DNS `A` records to the output `ingress_target_ip` (which points to the Load Balancer IP if enabled, or Master Server IP):
```dns
example.com.          A   <ingress_target_ip>
*.example.com.        A   <ingress_target_ip>
staging.example.com.  A   <ingress_target_ip>
docs.example.com.     A   <ingress_target_ip>
```

---

## 📥 Connecting & Managing Your Cluster

After `terraform apply` finishes, outputs provide ready-to-run commands:

```bash
# 1. SSH into the Master node:
ssh root@<master-ip>

# 2. Wait for background cloud-init to complete (1-2 minutes on initial boot):
cloud-init status --wait

# 3. Check cluster nodes (KUBECONFIG is set to /etc/rancher/k3s/k3s.yaml):
kubectl get nodes -o wide

# Troubleshooting: If kubectl gives "connection refused to localhost:8080", run:
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

---

## 🔄 Updating Server Provisioning

Whenever you want to modify variables (e.g. server specifications, firewall rules, domain names, or locations):

1. Edit `terraform.tfvars` or `variables.tf`.
2. Preview changes:
   ```bash
   terraform plan
   ```
3. Apply changes:
   ```bash
   terraform apply
   ```
*Terraform will automatically update resources in-place or plan node replacements if machine-level attributes are modified.*

---

## 🛑 Shutting Down & Destroying Infrastructure

When you want to shut down servers and stop billing:

```bash
# Permanently terminate servers, network, firewall, and load balancers:
terraform destroy
```
