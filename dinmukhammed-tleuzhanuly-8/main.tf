terraform {
  required_version = "1.8.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.109.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = true
}


data "azurerm_client_config" "current" {}

locals {
  resource_prefix = "${var.app}-${var.environment}-${var.location}-${var.suffix}"
  tags = {
    Environment = var.environment
    Application = var.app
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.resource_prefix}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_redis_cache" "redis" {
  name                = "redis-${local.resource_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = true
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

resource "azurerm_container_registry" "acr" {
  name                = replace("cr${local.resource_prefix}", "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
  tags                = local.tags
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-${local.resource_prefix}-6"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices" # Allow trusted Azure services to bypass the firewall
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate"
    ]

    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]

    storage_permissions = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
    ]
  }
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update",
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}

resource "azurerm_key_vault_secret" "redis_password" {
  name         = "redis-password"
  value        = azurerm_redis_cache.redis.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "redis_url" {
  name         = "redis-url"
  value        = azurerm_redis_cache.redis.hostname
  key_vault_id = azurerm_key_vault.kv.id
}

# Data resource to get ACR admin credentials
data "azurerm_container_registry" "acr" {
  name                = azurerm_container_registry.acr.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "null_resource" "docker_build_push" {
  triggers = {
    dockerfile_content = filemd5("${path.module}/app/Dockerfile")
  }

  provisioner "local-exec" {
    command = <<EOT
      az acr login --name ${azurerm_container_registry.acr.name} --username ${data.azurerm_container_registry.acr.admin_username} --password ${data.azurerm_container_registry.acr.admin_password}
      az acr build --registry ${data.azurerm_container_registry.acr.name} --image myapp:latest --file ./app/Dockerfile ./app
    EOT
  }

  depends_on = [
    azurerm_container_registry.acr,
  ]
}

resource "random_string" "container_name" {
  length  = 24
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_container_group" "aci" {
  name                = "aci-${local.resource_prefix}-${random_string.container_name.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "aci-${local.resource_prefix}"
  os_type             = "Linux"
  restart_policy      = "Always"

  container {
    name   = "aci-${local.resource_prefix}-${random_string.container_name.result}"
    image  = "${azurerm_container_registry.acr.login_server}/myapp:latest"
    cpu    = "1.0"
    memory = "2"

    ports {
      port     = 80
      protocol = "TCP"
    }

    secure_environment_variables = {
      REDIS_HOST     = azurerm_key_vault_secret.redis_url.value
      REDIS_PASSWORD = azurerm_key_vault_secret.redis_password.value
    }

    environment_variables = {
      CREATOR = "Azure_Container_Instance"
    }

  }

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  depends_on = [
    null_resource.docker_build_push,
  ]

}

resource "azurerm_user_assigned_identity" "uami" {
  name                = "myUserAssignedIdentity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_role_assignment" "uami_kv_access" {
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.kv.id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${local.resource_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${local.resource_prefix}"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami.id]
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  depends_on = [
    null_resource.docker_build_push,
  ]
}

resource "null_resource" "secret" {
  triggers = {
    dockerfile_content = filemd5("${path.module}/assets/service.yaml")
  }

  provisioner "local-exec" {
    command = <<EOT
      kubectl delete secret myregistrykey || true
      kubectl create secret docker-registry myregistrykey --docker-server=${azurerm_container_registry.acr.login_server} --docker-username=${azurerm_container_registry.acr.admin_username} --docker-password=${azurerm_container_registry.acr.admin_password} --docker-email=value
    EOT
  }

  depends_on = [
    azurerm_container_registry.acr,
  ]
}
