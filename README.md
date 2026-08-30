# Minimal secure K3s infrastructure

This Terraform stack creates one Ubuntu 24.04 Hetzner server and one cloud firewall. Cloud-init fully configures automatic security updates, key-only non-root SSH, UFW, pinned K3s, bundled Traefik with Let's Encrypt, a restricted `production` namespace, and one outbound-only GitHub Actions deployment runner.

## Security model

- Public inbound ports: TCP 80/443 and TCP 22 only from `allowed_ssh_ips`.
- TCP 6443 is not in either firewall. CD reaches K3s only at `127.0.0.1` from the runner on the server.
- The runner's Kubernetes identity is a namespaced Role, not `cluster-admin`; it cannot read Secrets or access other namespaces.
- PRs build on GitHub-hosted runners. The production runner is referenced only by the trusted scheduled/manual platform deployment workflow.
- `github_runner_token` is a single-use registration token that expires after one hour. It is not a deployment token.
- `terraform.tfvars` and Terraform state are sensitive local artifacts. Keep them mode `0600`, never commit them, and use an encrypted remote backend if the stack is shared.

## Prerequisites

- Terraform 1.5 or newer
- GitHub CLI authenticated as a platform repository administrator
- Hetzner Cloud read/write API token
- An Ed25519 SSH public key
- A trusted public source CIDR, normally your current address with `/32`
- A domain whose DNS you control

## GitHub setup

1. Enable Actions in all service, docs, IaC, and platform repositories.
2. In service/docs repository rulesets, require the CI workflow before merging `main`.
3. In the platform repository, allow `contents: write` and `packages: read` for workflows. If a ruleset protects `main`, add the GitHub Actions app as a narrowly scoped bypass actor because CD records resolved image digests directly in Git before applying them.
4. Create the platform `production` environment, allow only `main`, and optionally add reviewers. Reviewers trade full automation for manual approval.
5. Make the four GHCR packages public or grant `lmbek-hobby-platform` Actions read access to each package. Packages are `lmbek-hobby-web-frontend`, `lmbek-hobby-placeholder1-service`, `lmbek-hobby-placeholder2-service`, and `lmbek-hobby-docs`.
6. Do not add kubeconfig, SSH, Hetzner, or long-lived PAT secrets to service workflows.

Create a runner token immediately before apply:

```bash
gh api --method POST \
  repos/lmbek/lmbek-hobby-platform/actions/runners/registration-token \
  --jq .token
```

## Provision

```bash
cp terraform.tfvars.example terraform.tfvars
chmod 600 terraform.tfvars
# Fill every placeholder. Never use 0.0.0.0/0 or ::/0 for allowed_ssh_ips.

terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Cloud-init is immutable bootstrap input. Changes to it can replace the server; always review the plan. The provider is currently Hetzner because this project explicitly selected it, while generic inputs use `server_name`, `server_size`, `server_region`, `ssh_public_key`, and `domain`.

Get the DNS target:

```bash
terraform output -raw ingress_target_ip
```

Create an `A` record for `domain` pointing to that IPv4 address. Do not expose 6443 or create an API DNS record. Let's Encrypt HTTP-01 requires public DNS plus ports 80 and 443; initial issuance can take several minutes.

## Verify

In GitHub, verify the platform runner named after `server_name` is online and has the `k3s-production` label. Run the platform `Deploy production` workflow after all four `production` image tags exist.

From your machine:

```bash
curl --fail --show-error --head https://lmbek.dk
```

For emergency diagnostics only:

```bash
terraform output -raw admin_ssh_command
kubectl get nodes
kubectl get pods -A
kubectl get ingress -A
```

The application log contract is stdout/stderr, so use `kubectl -n production logs deployment/<name>` and `kubectl -n production describe pod <pod>`.

## CI/CD flow

1. A pull request runs formatting/vet/tests or docs build, dependency scanning, container build, and Trivy.
2. A successful `main` push publishes `sha-<full-git-sha>` and the `production` discovery tag to GHCR.
3. Every five minutes, platform CD resolves each discovery tag to its immutable digest.
4. CD commits changed digests, applies Kustomize locally, waits for all rolling updates, and checks public health.
5. Any failed scan, push, apply, rollout, or health check fails the workflow.

The blocking vulnerability policy is fixable `HIGH` and `CRITICAL` findings. Unfixed findings remain visible but do not block; any exception should be documented and time-bounded.

## Rollback, secrets, and backups

```bash
kubectl -n production rollout undo deployment/<name>
kubectl -n production rollout status deployment/<name> --timeout=180s
```

Revert the platform digest commit after emergency rollback. Kubernetes retains five ReplicaSets, and GHCR retains SHA-addressable images according to package retention settings.

Runtime secret values must be created out-of-band as Kubernetes Secrets and referenced by workloads; commit only placeholder examples. The deployer intentionally cannot read Secrets.

Terraform and manifests reproduce infrastructure and deployments but do not back up data. Database-native or managed backups and off-server copies are required. Destroying this server destroys K3s local volumes.

## Destroy

```bash
terraform plan -destroy
terraform destroy
```