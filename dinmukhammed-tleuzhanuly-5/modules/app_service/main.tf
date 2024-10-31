resource "azurerm_linux_web_app" "main" {
  for_each = { for idx, service in var.app_services : idx => service }

  name                = each.value.name
  resource_group_name = var.resource_groups[each.value.resource_group_idx].name
  location            = var.resource_groups[each.value.resource_group_idx].location
  service_plan_id     = var.app_service_plans[each.value.app_service_plan_idx].id

  site_config {
    ip_restriction_default_action = "Deny"
    dynamic "ip_restriction" {
      for_each = [
        {
          name        = "Allow-Traffic-Manager"
          action      = "Allow"
          service_tag = "AzureTrafficManager"
          priority    = 100
        },
        {
          name       = "Allow-Student-IP"
          action     = "Allow"
          ip_address = each.value.student_ip
          priority   = 101
        }
      ]
      content {
        name     = ip_restriction.value.name
        action   = ip_restriction.value.action
        priority = ip_restriction.value.priority

        service_tag = lookup(ip_restriction.value, "service_tag", null)
        ip_address  = lookup(ip_restriction.value, "ip_address", null)
      }
    }
  }
}
