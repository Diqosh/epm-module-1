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

variable "sql_server_admin_username" {
  description = "The administrator username for the SQL Server"
  type        = string
}

variable "sql_database_sku_name" {
  description = "The SKU name for the SQL Database"
  type        = string
}

variable "app_service_plan_sku" {
  description = "The SKU for the App Service Plan"
  type        = string
}

variable "secret_name" {
  description = "The name of the Key Vault Secret"
  type        = string
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the SQL Server."
  type        = list(string)
}
