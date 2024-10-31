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

variable "secret_name" {
  description = "The name of the Key Vault Secret"
  type        = string
}
