output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.kube.id
  description = "ID of the AKS cluster"
}


// Add if you need more output