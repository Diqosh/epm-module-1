data "http" "my_ip" {
  url = "https://api.ipify.org?format=text"
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  network_profile {
    network_plugin    = "azure"
    outbound_type     = "userDefinedRouting"
    load_balancer_sku = "standard"
  }

  api_server_access_profile {
    authorized_ip_ranges = [data.http.my_ip.response_body, var.fw_public_ip]
  }


  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = var.subnet_id
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  tags = var.tags
}

resource "null_resource" "secret" {
  triggers = {
    dockerfile_content = filemd5("${path.module}/assets/service.yaml")
  }

  provisioner "local-exec" {
    command = <<EOT
      az aks get-credentials --resource-group ${var.resource_group_name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing
      kubectl delete secret myregistrykey --ignore-not-found
      kubectl create secret docker-registry myregistrykey --docker-server=${var.acr_login_server} --docker-username=${var.acr_admin_username} --docker-password=${var.acr_admin_password} --docker-email=example@example.com
      kubectl apply -f ${path.module}/assets/deployment.yaml
      kubectl apply -f ${path.module}/assets/service.yaml
    EOT

    environment = {
      ACR_LOGIN_SERVER   = var.acr_login_server
      ACR_ADMIN_USERNAME = var.acr_admin_username
      ACR_ADMIN_PASSWORD = var.acr_admin_password
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]

}

resource "azurerm_role_assignment" "aks_network_contributor" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = var.vnet_id
}
