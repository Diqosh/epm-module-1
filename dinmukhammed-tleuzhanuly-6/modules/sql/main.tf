locals {
  sql_server_name = join("-", ["vm-sql", var.app, var.environment, var.location, var.suffix])
  sql_db_name     = join("-", ["sqldb", var.app, var.environment, var.location, var.suffix])
}


resource "azurerm_mssql_server" "main" {
  name                         = local.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_server_admin_username
  administrator_login_password = var.sql_server_admin_password
}

resource "azurerm_mssql_database" "main" {
  name      = local.sql_db_name
  server_id = azurerm_mssql_server.main.id
}

# Allow connections from specific IPs
resource "azurerm_mssql_firewall_rule" "allowed_ips" {
  for_each         = toset(var.allowed_ips)
  name             = "Allow_${each.value}"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value
  end_ip_address   = each.value
}

# Allow Azure services to access the server
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "Allow_Azure_Services"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


