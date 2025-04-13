variable "rsc_group_name" {
  type = string
  description = "Resource group name (Check it on Azure portal or create it directly.)"
}

variable "aks_cluster_name" {
  type = string
  description = "AKS cluster name"
}

variable "subscription_id" {
  type = string
  description = "Azure subscription ID"
}

variable "ops_node_vm_size" {
  type    = string
  default = "Standard_D4as_v5"
  description = "VM size of the management node pool"
}

variable "ops_node_count" {
  type    = number
  default = 1
  description = "Number of nodes in the management node pool"
}

variable "node_pools" {
  type = list(object({
    name                 = string
    vm_size              = string
    node_count           = number
    auto_scaling_enabled = bool
    min_count            = optional(number)
    max_count            = optional(number)
    node_labels          = map(string)
    node_taints          = list(string)
    enabled              = bool
  }))
  description = "Array of objects defining the node pool settings"
  default = [
    {
      name                 = "cpupool"
      vm_size              = "Standard_D4as_v5"
      node_count           = 1
      auto_scaling_enabled = true
      min_count            = 1
      max_count            = 5
      node_labels = {
        "haulrest.me/node-type" = "cpu"
      }
      node_taints = []
      enabled = true
    },
    {
      name                 = "gpupool"
      vm_size              = "Standard_NC8as_T4_v3"
      node_count           = 1
      auto_scaling_enabled = false
      node_labels = {
        "haulrest.me/node-type" = "gpu"
      }
      node_taints = [
        "haulrest.me/app-type=gpu:NoSchedule"
      ]
      enabled = false
    }
  ]
}

variable "connect_nat" {
  type    = bool
  default = false
  description = "Whether to connect the NAT gateway. The NAT gateway is assumed to exist."
}

variable "nat_gateway_name" {
  type    = string
  default = "nat-gateway"
  description = "The name of the NAT gateway to connect. It is required if the connect_nat variable is true. An error will occur if it does not exist."
}

variable "use_blob_storage" {
  type    = bool
  default = false
  description = "Whether to use blob storage."
}
