output "web_app_url" {
  value = azurerm_linux_web_app.main.default_hostname
}
