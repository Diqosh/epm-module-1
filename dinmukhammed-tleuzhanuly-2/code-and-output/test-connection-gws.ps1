$suffixes = @("08", "09")

for ($i = 0; $i -lt $suffixes.Length; $i++) {
    $suffix = $suffixes[$i]
    Get-AzVirtualNetworkGatewayConnection -Name "VNet2VNet-$suffix" -ResourceGroupName "rg-hm2-westeurope-$suffix"
}

