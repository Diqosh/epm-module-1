resource_groups = [
  { name = "rg-hm5-dev-eastus-01", location = "East US" },
  { name = "rg-hm5-dev-westus-01", location = "West US" },
  { name = "rg-hm5-dev-centralus-01", location = "Central US" }
]

app_service_plans = [
  { name = "asp-hm5-dev-eastus-01", sku = "S1", worker_count = 2, resource_group_idx = 0 },
  { name = "asp-hm5-dev-westus-01", sku = "S1", worker_count = 1, resource_group_idx = 1 }
]

app_services = [
  { name = "app-hm5-dev-eastus-01", resource_group_idx = 0, app_service_plan_idx = 0, student_ip = "37.99.41.41/32" },
  { name = "app-hm5-dev-westus-01", resource_group_idx = 1, app_service_plan_idx = 1, student_ip = "37.99.41.41/32" }
]

traffic_manager = {
  name               = "traf-hm5-dev-eastus-01",
  resource_group_idx = 2,
  endpoints = [
    { name = "trafe-hm5-dev-eastus-01", type = "azureEndpoints", target = "hm5-eastus-dev.azurewebsites.net", weight = 1, app_service_id = 0, endpoint_location = "East US" },
    { name = "trafe-hm5-dev-westus-01", type = "azureEndpoints", target = "hm5-westus-dev.azurewebsites.net", weight = 1, app_service_id = 1, endpoint_location = "West US" }
  ]
}
