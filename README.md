# Hetzner infrastructure

This Terraform stack creates one Hetzner server and one firewall. Cloud-init installs
K3s, cert-manager, and Argo CD; Argo CD continuously reconciles the platform repository.

## Apply from your local machine

```bash
cp terraform.tfvars.example terraform.tfvars
# Fill in the token, SSH key, and allowed SSH CIDRs. Keep terraform.tfvars local.

terraform init
terraform fmt -check
terraform validate
terraform plan
# Review the plan carefully, especially any server replacement.
terraform apply
```

Never make manual changes on the production server. Change Terraform, cloud-init, or
the platform manifests in Git and apply from your local environment.

## DNS and TLS

After apply, get the server address:

```bash
terraform output -raw ingress_target_ip
```

Create exactly these DNS records at your provider:

```text
@            A  <ingress_target_ip>
```

Only the frontend is public. Do not add wildcard records. cert-manager obtains trusted
Let's Encrypt certificates for `lmbek.dk` and `staging.lmbek.dk`; DNS must resolve
publicly and ports `80` and `443` must remain open.

Verify from your local machine after DNS propagation:

```bash
terraform output
curl --fail --show-error --head https://lmbek.dk
curl --fail --show-error --head https://staging.lmbek.dk
```

The first certificate can take several minutes. Inspect the certificate from your
machine with `curl -Iv https://lmbek.dk`; never SSH to inspect production.

## Change workflow

1. Change Terraform, cloud-init, or Kubernetes YAML in its own repository.
2. Open a pull request and wait for its validation workflow to pass.
3. Merge the pull request to `main`.
4. For Terraform changes, run `terraform plan` and apply it locally only after review.
5. For platform changes, Argo CD automatically reconciles `main`; no manual `kubectl`
   or server command is needed.

Service image changes are automated after a one-time `PLATFORM_REPOSITORY_TOKEN`
secret is configured in each service repository and the platform repository. GitHub
Actions publishes the tested image, updates and merges staging, waits for the public
staging health endpoint, and promotes the exact immutable digest to production. It
does not access Terraform, SSH, Kubernetes credentials, or production servers.

## Important migration note

The simplification from two nodes to one removes the worker, private network, and
optional load balancer resources. The changed immutable cloud-init also replaces the
existing K3s server. Review the plan and apply only when replacement is intended; then
update DNS if `ingress_target_ip` changes.

Destroy all cloud resources with `terraform destroy`.
