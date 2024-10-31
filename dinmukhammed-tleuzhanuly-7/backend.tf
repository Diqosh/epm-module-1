
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstat3"
    container_name       = "tfstate"
    key                  = "terraform6.tfstate"
  }
}
