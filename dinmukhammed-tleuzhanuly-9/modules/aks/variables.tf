variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "acr_login_server" {
  description = "acr server name"
  type        = string
}

variable "acr_admin_username" {
  description = "acr admin username"
  type        = string
}

variable "acr_admin_password" {
  description = "acr admin password"
  type        = string
}

variable "fw_public_ip" {
  description = "firewall public ip"
  type        = string
}

variable "subnet_id" {
  description = "subnet_id"
  type        = string
}

variable "vnet_id" {
  description = "vnet_id"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}
