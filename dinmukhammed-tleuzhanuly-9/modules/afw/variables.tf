variable "name_prefix" {
  description = "name_prefix"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "subnet_id"
  type        = string
}

variable "aks_subnet_id" {
  description = "aks_subnet_id"
  type        = string
}

variable "firewall_rules" {
  type = list(object({
    name                  = string
    source_addresses      = list(string)
    destination_addresses = list(string)
    destination_ports     = list(string)
    protocols             = list(string)
  }))

  default = [
    {
      name                  = "Allow-DNS"
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
      protocols             = ["UDP"]
    },
    {
      name                  = "Allow-HTTP"
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["80"]
      protocols             = ["TCP"]
    },
    {
      name                  = "Allow-HTTPS"
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
      protocols             = ["TCP"]
    },
    {
      name                  = "allow-kubernetes-api"
      source_addresses      = ["*"]
      destination_addresses = ["5.34.46.142"] # Replace with the actual IP address of your Kubernetes API server
      destination_ports     = ["443"]
      protocols             = ["TCP"]
    }
  ]
}

