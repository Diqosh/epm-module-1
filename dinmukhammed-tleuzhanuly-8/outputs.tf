output "container_ipv4_address" {
  value = azurerm_container_group.aci.ip_address
}


output "login_server" {
  value = azurerm_container_registry.acr.login_server
}
