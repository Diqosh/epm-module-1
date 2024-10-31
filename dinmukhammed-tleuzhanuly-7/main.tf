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
  rg_name      = join("-", ["rg", var.app, var.environment, var.location, var.suffix])
  sa_name      = join("", ["sa", var.app, var.environment, var.location, var.suffix])
  sc_container = join("-", ["sc", var.app, var.environment, var.location, var.suffix])
  sb_container = join("-", ["sb", var.app, var.environment, var.location, var.suffix])
  cdn_profile  = join("-", ["cdnp", var.app, var.environment, var.location, var.suffix])
  cdn_endpoint = join("-", ["cdne", var.app, var.environment, var.location, var.suffix])
  vnet_name    = join("-", ["vnet", var.app, var.environment, var.location, var.suffix])
  subnet_name  = join("-", ["subnet", var.app, var.environment, var.location, var.suffix])
  nic_name     = join("-", ["nic", var.app, var.environment, var.location, var.suffix])
  vm_name      = join("-", ["vm", var.app, var.environment, var.location, var.suffix])
}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "main" {
  name                  = local.sc_container
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "main" {
  name                   = local.sb_container
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.main.name
  type                   = "Block"
  source                 = "./static_files/test.txt"
}

resource "azurerm_cdn_profile" "main" {
  name                = local.cdn_profile
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "main" {
  name                = local.cdn_endpoint
  profile_name        = azurerm_cdn_profile.main.name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  origin {
    name      = "storageorigin"
    host_name = "${azurerm_storage_account.main.name}.blob.core.windows.net"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = local.nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}


resource "azurerm_virtual_machine" "main" {
  name                  = local.vm_name
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "example-osdisk-${var.suffix}-06"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vm-${var.suffix}-06"
    admin_username = "adminuser"
    admin_password = "Password123!"
    custom_data = templatefile("${path.module}/cloud-init.tpl", {
      storage_account_name = azurerm_storage_account.main.name
      container_name       = azurerm_storage_container.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
    })
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_public_ip" "main" {
  name                = join("-", ["pip", var.app, var.environment, var.location, var.suffix])
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "main" {
  name                = join("-", ["rsv", var.app, var.environment, var.location, var.suffix])
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  soft_delete_enabled = true
}

# Backup Policy
resource "azurerm_backup_policy_vm" "daily" {
  name                = join("-", ["daily-backup-policy", var.app, var.environment, var.location, var.suffix])
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

# Protect VM with Backup
resource "azurerm_backup_protected_vm" "main" {
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_virtual_machine.main.id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}


