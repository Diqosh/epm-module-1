output "app_services" {
  value = [
    for app in azurerm_linux_web_app.main : {
      id   = app.id
      name = app.name
    }
  ]
}
