resource "azurerm_resource_group" "resource_groups" {
  for_each = { for idx, rg in var.resource_groups : idx => rg }
  name     = each.value.name
  location = each.value.location
}
