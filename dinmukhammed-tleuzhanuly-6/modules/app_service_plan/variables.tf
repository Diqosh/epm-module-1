# Define your variables
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure location where resources will be created"
  type        = string
}

variable "app" {
  description = "App name for handle name convesion"
  type        = string
}

variable "environment" {
  description = "App name for handle name convesion"
  type        = string
}

variable "suffix" {
  description = "Suffix name for handle name convesion, example: 001"
  type        = string
}

variable "app_service_plan_sku" {
  description = "The SKU for the App Service Plan"
  type        = string
}

variable "connection_string" {
  description = "Connection string for the Azure SQL Database created."
  sensitive   = true
  type        = string
}

