resource "azurerm_public_ip" "firewall_pip" {
  name                = "pip-afw-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "firewall" {
  name                = "afw-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  threat_intel_mode   = "Alert"
  sku_tier            = "Standard"
  dns_proxy_enabled   = true


  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "example"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  dynamic "rule" {
    for_each = var.firewall_rules

    content {
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_addresses = rule.value.destination_addresses
      destination_ports     = rule.value.destination_ports
      protocols             = rule.value.protocols
    }
  }

}

resource "azurerm_firewall_application_rule_collection" "example" {
  name                = "aksfwar"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name = "testrule"

    source_addresses = [
      "*"
    ]

    # protocol {
    #   port = "443"
    #   type = "Https"
    # }
    # protocol {
    #   port = "80"
    #   type = "Http"
    # }
    fqdn_tags = ["AzureKubernetesService"]
  }
}


resource "azurerm_route_table" "fw_route_table" {
  name                = "fw-route-table-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_route" "default_route" {
  name                   = "default-route"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.fw_route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

resource "azurerm_route" "internet_route" {
  name                = "internet-route"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.fw_route_table.name
  address_prefix      = "${azurerm_public_ip.firewall_pip.ip_address}/32"

  next_hop_type = "Internet"
}

resource "azurerm_subnet_route_table_association" "aks_subnet_route_table" {
  subnet_id      = var.aks_subnet_id
  route_table_id = azurerm_route_table.fw_route_table.id
}

# resource "azurerm_firewall_nat_rule_collection" "example" {
#   name                = "exampleset"
#   azure_firewall_name = azurerm_firewall.firewall.name
#   resource_group_name = var.resource_group_name
#   priority            = 100
#   action              = "Dnat"

#   rule {
#     name                  = "inboundrule"
#     source_addresses      = ["*"]
#     destination_addresses = [azurerm_public_ip.firewall_pip.ip_address]
#     destination_ports     = ["80"]
#     protocols             = ["Any"]
#     translated_address    = "172.171.92.108"
#     translated_port       = "80"
#   }
# }
