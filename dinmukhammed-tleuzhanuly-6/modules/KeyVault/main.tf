locals {
  key_vault_name = substr(join("-", ["keyv", var.app, var.suffix]), 0, 24)

}
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = local.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "random_password" "main" {
  length  = 16
  special = true
}

resource "azurerm_key_vault_secret" "main" {
  name         = var.secret_name
  value        = random_password.main.result
  key_vault_id = azurerm_key_vault.main.id
}
