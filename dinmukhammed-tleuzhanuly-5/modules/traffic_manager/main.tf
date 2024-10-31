resource "azurerm_traffic_manager_profile" "traffic_manager" {
  name                   = var.traffic_manager.name
  resource_group_name    = var.resource_groups[var.traffic_manager.resource_group_idx].name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = var.traffic_manager.name
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "traffic_manager_endpoints" {
  for_each           = { for endpoint in var.traffic_manager.endpoints : endpoint.name => endpoint }
  name               = each.value.name
  profile_id         = azurerm_traffic_manager_profile.traffic_manager.id
  weight             = each.value.weight
  target_resource_id = var.app_services[each.value.app_service_id].id
}
