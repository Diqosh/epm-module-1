locals {
  web_app_name = join("-", ["app", var.app, var.environment, var.location, var.suffix])
}


resource "azurerm_linux_web_app" "main" {
  name                = local.web_app_name
  resource_group_name = var.resource_group_name
  location            = var.service_plan_location
  service_plan_id     = var.service_plan_id

  site_config {}

  app_settings = {
    "DATABASE_URL" = var.connection_string
  }
}

