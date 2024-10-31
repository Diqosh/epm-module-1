variable "resource_groups" {
  description = "List of resource groups with their locations"
  type = list(object({
    name     = string
    location = string
  }))
}

variable "app_service_plans" {
  description = "List of App Service Plans with their SKUs, worker count, and resource group index"
  type = list(object({
    name               = string
    sku                = string
    worker_count       = number
    resource_group_idx = number
  }))
}

variable "app_services" {
  description = "List of App Services with their resource group and service plan indices"
  type = list(object({
    name                 = string
    resource_group_idx   = number
    app_service_plan_idx = number
    student_ip           = string
  }))
}

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
