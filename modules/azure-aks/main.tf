# Resource group
data "azurerm_resource_group" "rsc_group" {
  name = var.rsc_group_name
}

# AKS cluster
resource "azurerm_kubernetes_cluster" "kube" {
  name       = var.aks_cluster_name
  dns_prefix = var.aks_cluster_name

  location            = data.azurerm_resource_group.rsc_group.location
  resource_group_name = data.azurerm_resource_group.rsc_group.name

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Default node pool is constant, and only used for operation. Auto scaling is disabled.
  default_node_pool {
    name                 = "opspool"
    vm_size              = var.ops_node_vm_size
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
    temporary_name_for_rotation = "tmpnodepool1"
    auto_scaling_enabled = false
    node_count           = var.ops_node_count
    upgrade_settings {
      max_surge = "10%"
    }
  }

  auto_scaler_profile {
    scale_down_utilization_threshold = 0.4
    max_graceful_termination_sec     = 600
    scale_down_delay_after_add       = "20m"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = var.connect_nat ? "userAssignedNATGateway" : "loadBalancer"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

  # Blob storage config
  storage_profile {
    blob_driver_enabled = var.use_blob_storage
  }
}

# https://developer.hashicorp.com/terraform/language/expressions/for
# Define multiple node pools at once.
resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each             = { for pool in var.node_pools : pool.name => pool if pool.enabled }
  name                 = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kube.id
  vm_size              = each.value.vm_size
  vnet_subnet_id       = azurerm_subnet.aks_subnet.id
  node_count           = each.value.node_count
  auto_scaling_enabled = each.value.auto_scaling_enabled
  node_labels          = each.value.node_labels
  node_taints          = each.value.node_taints

  min_count = each.value.min_count
  max_count = each.value.max_count

  temporary_name_for_rotation = "${each.value.name}r"
  lifecycle {
    create_before_destroy = true
  }
}

# Public IP for ingress.
resource "azurerm_public_ip" "ingress_ip" {
  name                = "${var.aks_cluster_name}-ingress-ip"
  allocation_method   = "Static"
  sku                 = "Standard"
  location            = data.azurerm_resource_group.rsc_group.location
  resource_group_name = data.azurerm_resource_group.rsc_group.name
}

# Get current client configuration. (to get tenant id)
data "azurerm_client_config" "current" {}

# Network configuration for AKS.
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.aks_cluster_name}-vnet"
  location            = data.azurerm_resource_group.rsc_group.location
  resource_group_name = data.azurerm_resource_group.rsc_group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.aks_cluster_name}-subnet"
  resource_group_name  = data.azurerm_resource_group.rsc_group.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
} 

resource "azurerm_role_assignment" "aks_network_contributor" {
  principal_id                     = azurerm_kubernetes_cluster.kube.identity[0].principal_id
  scope                            = data.azurerm_resource_group.rsc_group.id
  role_definition_name             = "Network Contributor"
  skip_service_principal_aad_check = true
}

# NAT gateway configuration.
# 1. Get existing NAT gateway if it exists.
# 2. Create the association between the subnet and the NAT gateway. (When connect_nat is true)

# https://stackoverflow.com/a/41870148
data "azurerm_nat_gateway" "existing_nat_gateway" {
  count = var.connect_nat ? 1 : 0
  name                = var.nat_gateway_name
  resource_group_name = data.azurerm_resource_group.rsc_group.name
}

resource "azurerm_subnet_nat_gateway_association" "aks_subnet_nat_association" {
  count          = var.connect_nat ? 1 : 0
  subnet_id      = azurerm_subnet.aks_subnet.id
  nat_gateway_id = data.azurerm_nat_gateway.existing_nat_gateway[0].id
}