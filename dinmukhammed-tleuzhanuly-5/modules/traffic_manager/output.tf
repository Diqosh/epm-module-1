output "traffic_manager_profile" {
  value = azurerm_traffic_manager_profile.traffic_manager
}

output "traffic_manager_endpoints" {
  value = azurerm_traffic_manager_azure_endpoint.traffic_manager_endpoints
}
