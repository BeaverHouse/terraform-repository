# AKS on Azure — Recommended Modules

Curated Terraform modules for running AKS clusters on Azure. Verified active as of 2026-05-01.

## Use AVM (Azure Verified Modules)

Microsoft is consolidating its Terraform module catalog under [**Azure Verified Modules (AVM)**](https://azure.github.io/Azure-Verified-Modules/). The older flat-named modules (`Azure/aks/azurerm`, `Azure/vnet/azurerm`, etc.) are being deprecated through 2026 — use the `avm-res-*` equivalents instead.

AVM modules follow a consistent specification: standard inputs, telemetry, lifecycle policies, and provider version handling. They are the safest default for any new Azure Terraform code.

## Cluster

- **[Azure/avm-res-containerservice-managedcluster/azurerm](https://registry.terraform.io/modules/Azure/avm-res-containerservice-managedcluster/azurerm/latest)** — AKS managed cluster. Replaces the deprecated `Azure/aks/azurerm`.

## Networking

- **[Azure/avm-res-network-virtualnetwork/azurerm](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest)** — VNet. Replaces the deprecated `Azure/vnet/azurerm`.
- **[Azure/avm-res-network-natgateway/azurerm](https://registry.terraform.io/modules/Azure/avm-res-network-natgateway/azurerm/latest)** — NAT Gateway, for deterministic egress IPs (required when external services allowlist by IP).
- **[Azure/avm-res-network-applicationgateway/azurerm](https://registry.terraform.io/modules/Azure/avm-res-network-applicationgateway/azurerm/latest)** — Application Gateway. Use with AGIC for L7 ingress backed by Azure infrastructure.
- **[Azure/avm-res-network-networksecuritygroup/azurerm](https://registry.terraform.io/modules/Azure/avm-res-network-networksecuritygroup/azurerm/latest)** — Network Security Groups.
- **[Azure/avm-res-network-publicipaddress/azurerm](https://registry.terraform.io/modules/Azure/avm-res-network-publicipaddress/azurerm/latest)** — Public IP. Often needed alongside NAT Gateway and AGW.

## Identity / Supporting

- **[Azure/avm-res-managedidentity-userassignedidentity/azurerm](https://registry.terraform.io/modules/Azure/avm-res-managedidentity-userassignedidentity/azurerm/latest)** — User-assigned managed identity for Workload Identity bindings.
- **[Azure/avm-res-keyvault-vault/azurerm](https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm/latest)** — Key Vault, for certificates and secrets feeding into AKS.
- **[Azure/avm-res-containerregistry-registry/azurerm](https://registry.terraform.io/modules/Azure/avm-res-containerregistry-registry/azurerm/latest)** — Azure Container Registry (ACR).

## Add-ons / Workloads

In-cluster components (cert-manager, Velero, etc.) are better installed via Helm charts managed by Argo CD or Flux than as Terraform modules. Most Terraform-wrapped add-on modules I've found are unmaintained or thin wrappers around `helm_release`.

## When to write your own

Almost never. Reach for a custom module only when:

- you have a regulatory requirement to define every resource yourself,
- the AVM module doesn't expose a specific preview feature you need (then prefer contributing upstream), or
- you're wrapping multiple AVM modules into a higher-level abstraction for your org.

Otherwise, the maintenance cost of tracking `azurerm` provider major bumps yourself outweighs whatever flexibility you gain.

## See also

- [Azure Verified Modules — overview](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Terraform module index](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)
- [azurerm provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS official documentation](https://learn.microsoft.com/en-us/azure/aks/)
