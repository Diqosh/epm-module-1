variable "app_services" {
  description = "List of app services"
  type = list(object({
    name                 = string
    resource_group_idx   = number
    app_service_plan_idx = number
    student_ip           = string
  }))
}

variable "resource_groups" {
  description = "List of resource groups"
  type = map(object({
    name     = string
    location = string
  }))
}

variable "app_service_plans" {
  description = "List of app service plans"
  type = map(object({
    name = string
    id   = string
  }))
}
