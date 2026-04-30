# Notes for using Terraform

## Conventions

- **Pin both Terraform and providers.** `required_version = "~> 1.x"` and `version = "~> 6.0"` per provider. Floating versions break reproducibility silently.
- **Commit `.terraform.lock.hcl`.** It records provider hashes for supply-chain integrity. Only `.terraform/` belongs in `.gitignore`.
- **Always set `provider` explicitly when multiple aliases or accounts exist.** Implicit selection causes silent cross-account writes — one of the most expensive mistakes possible.
- **Prefer typed schema blocks over raw JSON/YAML strings.** When a provider exposes a structured equivalent (`aws_iam_policy_document`, `kubernetes_manifest`, `azurerm_role_definition`, etc.), use it. Type-checked, diffable, and avoids quote-escaping hell. Drop to raw strings only when no schema exists.
- **Remote state is mandatory for anything shared.** S3 + DynamoDB lock, GCS, or Postgres backend. Never `local` for non-toy projects.

## Pitfalls

### "Update in-place" plans with no visible diff

After a provider major upgrade (e.g. AWS 5 → 6), `terraform plan` may show `~ update in-place` with all attributes hidden as unchanged. This is a schema migration, not a real change — the provider re-encodes the resource internally without touching the cloud. Confirm by running `terraform show -json tfplan` and checking that `before` and `after` are identical. Safe to apply; the diff disappears afterward.

### `for_each` over `count` for collections

`count` keys by index — removing the middle element shifts everything and triggers destroy/recreate of unrelated resources. `for_each` keys by string and is stable. Use `count` only for boolean-style conditional creation (`count = var.enabled ? 1 : 0`).

### `lifecycle.create_before_destroy` needs a unique name

Resources with a fixed `name` will collide during the overlap. Either use `name_prefix`, or make `name` derive from a rotating variable (commit hash, timestamp). Without this, the lifecycle rule silently does nothing useful.

### `lifecycle.ignore_changes` is a load-bearing escape hatch

Use it for attributes mutated outside Terraform (autoscaling desired counts, tags injected by cost-allocation tools, secrets rotated by AWS). Don't use it to suppress diffs you haven't understood — that hides real drift.

### Kubernetes auto-scaling

Before enabling cluster autoscaler / Karpenter:

- Every Deployment that matters has a `PodDisruptionBudget`. Scale-down evicts pods; without PDB, traffic drops.
- `Job`/`CronJob` pods block node drain by default. Set `restartPolicy: Never` and a reasonable `activeDeadlineSeconds`.
- VM quota must accommodate **2× peak** during rolling updates. AWS/Azure quota tickets take days.

### Provider-specific

- **AWS**: community modules at [terraform-aws-modules](https://github.com/terraform-aws-modules) are usually solid — but read the source before adopting. They make opinionated choices (e.g. default IAM policies) that may not fit.
- **Azure**: `azurerm` module ecosystem is thinner; expect to write resources directly more often. Provider itself moves fast — pin tightly.
- **GCP**: `google` and `google-beta` are separate providers. Beta features require explicit `google-beta` alias.

## Tooling (2026)

### AI assistants

- **Terraform MCP server** ([hashicorp/terraform-mcp-server](https://github.com/hashicorp/terraform-mcp-server)) gives Claude/Cursor live access to provider docs, module registry, and version metadata. Configure via `.mcp.json`:
  ```json
  {
    "mcpServers": {
      "terraform": {
        "type": "stdio",
        "command": "docker",
        "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server"]
      }
    }
  }
  ```
  Without this, AI tools hallucinate resource arguments from older provider versions.
- For HCP Terraform / Terraform Cloud workflows, the same MCP server exposes workspace and run management when a token is provided.

### OpenTofu

Terraform's open-source fork. Drop-in compatible at the language level for now, but state file format and provider compatibility have started diverging at the edges. Pick one per project; mixing causes lock file churn.

### Linting

- `terraform fmt` and `terraform validate` are table stakes — wire them into pre-commit.
- [`tflint`](https://github.com/terraform-linters/tflint) catches provider-specific anti-patterns (deprecated arguments, invalid instance types).
- [`trivy config`](https://trivy.dev/) or [`checkov`](https://www.checkov.io/) for security scanning. Run in CI.

## State recovery

When `terraform apply` succeeds at the provider but fails to persist state (backend error, network drop), Terraform writes `errored.tfstate` to the working directory.

**Do not re-run apply.** That creates a forked state. Instead:

```bash
terraform state push errored.tfstate
```

after fixing the backend. Keep a backup of `errored.tfstate` until verified.
