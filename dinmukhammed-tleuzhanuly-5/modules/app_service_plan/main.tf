resource "azurerm_service_plan" "app_service_plans" {
  for_each            = { for idx, asp in var.app_service_plans : idx => asp }
  name                = each.value.name
  location            = var.resource_groups[each.value.resource_group_idx].location
  resource_group_name = var.resource_groups[each.value.resource_group_idx].name
  worker_count        = each.value.worker_count
  os_type             = "Linux"
  sku_name            = each.value.sku
}
