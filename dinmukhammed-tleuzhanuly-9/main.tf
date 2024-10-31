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

module "vnet" {
  source              = "./modules/vnet"
  vnet_name           = "vnet-${local.resource_prefix}"
  address_space       = ["10.42.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnets = {
    aks-subnet          = "10.42.1.0/24"
    AzureFirewallSubnet = "10.42.2.0/24"
  }
}

module "acr" {
  source              = "./modules/acr"
  acr_name            = replace("cr${local.resource_prefix}", "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.tags
}


module "afw" {
  source              = "./modules/afw"
  name_prefix         = local.resource_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.vnet.subnet_ids["AzureFirewallSubnet"]
  aks_subnet_id       = module.vnet.subnet_ids["aks-subnet"]
}


module "aks" {
  source              = "./modules/aks"
  cluster_name        = "aks-${local.resource_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${local.resource_prefix}"
  acr_login_server    = module.acr.acr_login_server
  acr_admin_username  = module.acr.acr_admin_username
  acr_admin_password  = module.acr.acr_admin_password
  fw_public_ip        = module.afw.firewall_public_ip
  subnet_id           = module.vnet.subnet_ids["aks-subnet"]
  vnet_id             = module.vnet.vnet_id
  tags                = local.tags
}

