variable "traffic_manager" {
  description = "Traffic Manager configuration"
  type = object({
    name               = string
    resource_group_idx = number
    endpoints = list(object({
      name              = string
      type              = string
      target            = string
      weight            = number
      app_service_id    = number
      endpoint_location = string
    }))
  })
}

variable "resource_groups" {
  description = "List of resource groups"
  type = map(object({
    name     = string
    location = string
  }))
}

variable "app_services" {
  description = "List of App Services with their resource group and service plan indices"
  type = list(object({
    id   = string
    name = string
  }))
}
