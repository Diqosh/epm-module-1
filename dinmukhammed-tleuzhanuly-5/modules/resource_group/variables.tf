variable "resource_groups" {
  description = "List of resource groups with their names and locations"
  type = list(object({
    name     = string
    location = string
  }))
}
