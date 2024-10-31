output "firewall_public_ip" {
  value = azurerm_public_ip.firewall_pip.ip_address
}

output "fw_route_table_id" {
  value = azurerm_route_table.fw_route_table.id
}
