terraform {
  required_version = "1.8.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.109.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = true
}

locals {
  rg_name = join("-", ["rg", var.app, var.environment, var.location, var.suffix])
}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
}

module "sql_server_db" {
  source = "modules/sql"

  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  app                       = var.app
  environment               = var.environment
  suffix                    = var.suffix
  sql_server_admin_username = var.sql_server_admin_username
  sql_server_admin_password = module.key_vault.sql_server_admin_password
  allowed_ips               = var.allowed_ips
}

module "app_service" {
  source = "modules/app_service_plan"

  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  app                  = var.app
  environment          = var.environment
  suffix               = var.suffix
  app_service_plan_sku = var.app_service_plan_sku
  connection_string    = module.sql_server_db.connection_string
}

module "web_app" {
  source = "modules/webapp"

  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  app                   = var.app
  environment           = var.environment
  suffix                = var.suffix
  app_service_plan_sku  = var.app_service_plan_sku
  connection_string     = module.sql_server_db.connection_string
  service_plan_location = module.app_service.service_plan_location
  service_plan_id       = module.app_service.service_plan_id
}

module "key_vault" {
  source = "modules/KeyVault"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  app                 = var.app
  environment         = var.environment
  suffix              = var.suffix
  secret_name         = var.secret_name
}




