# Azure AKS Module

This module is a Terraform module for deploying Azure Kubernetes Service (AKS).

## ❗️❗️ Important notes ❗️❗️

1. You need permissions for Azure resources.
2. You need to create a resource group manually.
   - If you want to create a resource group automatically, please change the `azurerm_resource_group` block to the resource group block in the `main.tf` file.
3. NAT Gateway is assumed to exist. If it does not exist, you need to create it.

## Usage

```hcl
module "azure_aks" {
  source = "./path/to/module/azure-aks" # Specify the relative path of the module.
  # Add variables via the terraform.tfvars file or directly from the local variables.
}
```

## Input variables

| Name             | Description                                         | Type         | Default                            | Required |
| ---------------- | --------------------------------------------------- | ------------ | ---------------------------------- | :------: |
| rsc_group_name   | The name of the resource group                      | string       | -                                  |   yes    |
| aks_cluster_name | The name of the AKS cluster                         | string       | -                                  |   yes    |
| subscription_id  | Azure subscription ID                               | string       | -                                  |   yes    |
| ops_node_vm_size | The VM size of the management node pool             | string       | "Standard_D4as_v5"                 |   yes    |
| ops_node_count   | The number of nodes in the management node pool     | number       | 1                                  |   yes    |
| node_pools       | The list of objects defining the node pool settings | list(object) | Refer to the `./variables.tf` file |   yes    |
| connect_nat      | Whether to connect the NAT gateway                  | bool         | false                              |    no    |
| nat_gateway_name | The name of the NAT gateway to connect              | string       | "nat-gateway"                      |    no    |
| use_blob_storage | Whether to use blob storage                         | bool         | false                              |    no    |

### node_pools object structure

```hcl
{
  name                 = string
  vm_size              = string
  node_count           = number
  auto_scaling_enabled = bool
  min_count            = optional(number)
  max_count            = optional(number)
  node_labels          = map(string)
  node_taints          = list(string)
  enabled              = bool
}
```

## Output variables

The output only contains the ID of the AKS cluster.  
If you need more outputs, please add them to the `outputs.tf` file.
