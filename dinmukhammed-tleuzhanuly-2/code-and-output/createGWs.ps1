$locationName = "westeurope"

function Create-VirtualNetworkAndGateway {
    param (
      [string] $suffix,
      [string] $AddressPrefix,
      [string] $GatewaySubnetAddressPrefix
    )
  
    # Create resource group
    $resourceGroupName = "rg-hm2-westeurope-$suffix"
    $RG1 = New-AzResourceGroup -Name $resourceGroupName -Location $locationName
    Write-Host "Created resource group: $resourceGroupName"
  
    # Create virtual network subnet
    $GMSubnet = New-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix $GatewaySubnetAddressPrefix
  
    $virtualNetworkName = "vnet-hm2-westeurope-$suffix"
    New-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $RG1.ResourceGroupName -Location $locationName -AddressPrefix $AddressPrefix -Subnet $GMSubnet
    Write-Host "Created virtual network: $virtualNetworkName"
  
    # Get virtual network and subnet
    $vnet1 = Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $RG1.ResourceGroupName
    $gwSubnet1 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1
  
    # Create public IP address
    $pip1Name = "pip-hm2-westeurope-$suffix"
    $pip1 = New-AzPublicIpAddress -Name $pip1Name -ResourceGroupName $RG1.ResourceGroupName -Location $locationName -AllocationMethod Static -Sku Standard
    Write-Host "Created public IP address: $pip1Name"
  
    # Create virtual network gateway IP config
    $gwipconf1Name = "gwipconf-hm2-westeurope-$suffix"
    $gwipconf1 = New-AzVirtualNetworkGatewayIpConfig -Name $gwipconf1Name -Subnet $gwSubnet1 -PublicIpAddress $pip1
  
    # Create virtual network gateway 
    $gwName = "gw-hm2-westeurope-$suffix"
    New-AzVirtualNetworkGateway -Name $gwName -ResourceGroupName $RG1.ResourceGroupName -Location $locationName -IpConfigurations $gwipconf1 -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw2 -VpnGatewayGeneration "Generation2"

    Write-Host "Created virtual network gateway '$gwName'"

    return $resourceGroupName
  }
  
  $resourceGroup1 = Create-VirtualNetworkAndGateway -suffix "11" -AddressPrefix "10.0.0.0/16" -GatewaySubnetAddressPrefix "10.0.255.0/27"
  
  $resourceGroup2 = Create-VirtualNetworkAndGateway -suffix "12" -AddressPrefix "10.1.0.0/16" -GatewaySubnetAddressPrefix "10.1.255.0/27"
    