# Hetzner infrastructure

This Terraform stack creates one Hetzner server and one firewall. Cloud-init installs
K3s, cert-manager, and Argo CD; Argo CD continuously reconciles the platform repository.

## Apply from your local machine

```bash
cp terraform.tfvars.example terraform.tfvars
# Fill in the token, SSH key, and allowed SSH CIDRs.

terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Never make manual changes on the production server. Change Terraform, cloud-init, or
the platform manifests in Git and apply from your local environment.

## DNS and TLS

Point these DNS `A` records to `terraform output -raw ingress_target_ip`:

```text
@            A  <ingress_target_ip>
*            A  <ingress_target_ip>
*.staging    A  <ingress_target_ip>
```

cert-manager obtains trusted Let's Encrypt certificates for production and staging.
DNS must resolve publicly and ports `80` and `443` must remain open.

Verify from your local machine after DNS propagation:

```bash
terraform output
curl --fail --show-error --head https://lmbek.dk
curl --fail --show-error --head https://staging.lmbek.dk
```

## Important migration note

The simplification from two nodes to one removes the worker, private network, and
optional load balancer resources. The changed immutable cloud-init also replaces the
existing K3s server. Review the plan and apply only when replacement is intended; then
update DNS if `ingress_target_ip` changes.

Destroy all cloud resources with `terraform destroy`.
