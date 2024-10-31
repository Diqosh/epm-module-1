output "sql_server_admin_password" {
  value = azurerm_key_vault_secret.main.value
}
