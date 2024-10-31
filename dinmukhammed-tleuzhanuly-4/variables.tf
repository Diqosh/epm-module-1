variable "location" {
  type        = string
  description = "The Azure region where resources will be created"
  default     = "eastus"
}

variable "project" {
  type        = string
  description = "Project name or abbreviation"
  default     = "hm4"
}

variable "suffix" {
  type        = string
  description = "Suffix to append to resource names for uniqueness"
  default     = "01"
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "The admin password for the virtual machine"
  type        = string
  sensitive   = true
}
