resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
  tags                = var.tags
}

resource "null_resource" "docker_build_push" {
  triggers = {
    dockerfile_content = filemd5("${path.root}/app/frontend/Dockerfile")
  }

  provisioner "local-exec" {
    command     = <<EOT
      az acr login --name ${azurerm_container_registry.acr.name} --username ${azurerm_container_registry.acr.admin_username} --password ${azurerm_container_registry.acr.admin_password}
      az acr build --registry ${azurerm_container_registry.acr.name} --image myapp:latest --file ./app/frontend/Dockerfile ./app/frontend
    EOT
  }
}
