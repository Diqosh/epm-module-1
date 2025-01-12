locals {
  app_service_plan_name = join("-", ["asp", var.app, var.environment, var.location, var.suffix])
}

resource "azurerm_service_plan" "main" {
  name                = local.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku
}

