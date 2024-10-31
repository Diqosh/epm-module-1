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

module "resource_groups" {
  source          = "modules/resource_group"
  resource_groups = var.resource_groups
}

module "app_service_plans" {
  source            = "modules/app_service_plan"
  app_service_plans = var.app_service_plans
  resource_groups   = module.resource_groups.resource_groups
}

module "app_services" {
  source            = "modules/app_service"
  app_services      = var.app_services
  resource_groups   = module.resource_groups.resource_groups
  app_service_plans = module.app_service_plans.app_service_plans
}

module "traffic_manager" {
  source          = "modules/traffic_manager"
  traffic_manager = var.traffic_manager
  resource_groups = module.resource_groups.resource_groups
  app_services    = module.app_services.app_services
}
