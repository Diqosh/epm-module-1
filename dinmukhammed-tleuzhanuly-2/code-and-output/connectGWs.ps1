$locationName = "westeurope"

$suffix1 = "08"
$suffix2 = "09"
$Connection12 = "VNet2VNet-$suffix1" 
$Connection21 = "VNet2VNet-$suffix2"

try {
  $vnet1gw = Get-AzVirtualNetworkGateway -Name "gw-hm2-westeurope-$suffix1" -ResourceGroupName "rg-hm2-westeurope-$suffix1"
  $vnet2gw = Get-AzVirtualNetworkGateway -Name "gw-hm2-westeurope-$suffix2" -ResourceGroupName "rg-hm2-westeurope-$suffix2"
} catch {
  Write-Error "Error retrieving gateways: $_"
  exit
}

New-AzVirtualNetworkGatewayConnection -Name $Connection12 -ResourceGroupName "rg-hm2-westeurope-$suffix1" -VirtualNetworkGateway1 $vnet1gw -VirtualNetworkGateway2 $vnet2gw -Location $locationName -ConnectionType Vnet2Vnet -SharedKey "myKey"

New-AzVirtualNetworkGatewayConnection -Name $Connection21 -ResourceGroupName "rg-hm2-westeurope-$suffix2" -VirtualNetworkGateway1 $vnet2gw -VirtualNetworkGateway2 $vnet1gw -Location $locationName -ConnectionType Vnet2Vnet -SharedKey "myKey"