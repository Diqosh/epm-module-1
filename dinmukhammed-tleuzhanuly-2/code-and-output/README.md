## Connecting to Azure Subscription

This document outlines the steps to connect to a specific Azure subscription and configure virtual network gateways.

**Subscription:** da3dbf13-6fdf-4a7b-83ee-aa0c24495f40

**sign in to my sub:**  Connect-AzAccount -Subscription 'da3dbf13-6fdf-4a7b-83ee-aa0c24495f40' -InformationAction Ignore

**Steps:**

1. **Create Virtual Network Resources:**
    - Run the script `createGWs.ps1`. This script likely creates virtual networks, public IP addresses, and network gateways.

2. **Connect Virtual Network Gateways:**
    - Run the script `connectGWs.ps1`. This script presumably establishes connections between the previously created virtual network gateways.

3. **Test Gateway Connections:**
    - Run the script `test-connection-gws.ps1`. This script probably verifies connectivity between the configured virtual network gateways.
