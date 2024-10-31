variable "app_service_plans" {
  description = "List of app service plans"
  type = list(object({
    name               = string
    resource_group_idx = number
    worker_count       = number
    sku                = string
  }))
}

variable "resource_groups" {
  description = "List of resource groups"
  type = map(object({
    name     = string
    location = string
  }))
}
