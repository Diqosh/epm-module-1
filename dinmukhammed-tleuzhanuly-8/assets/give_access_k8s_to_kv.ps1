$myResourceGroup = "rg-hm8-dev-westus-002"
$myAKSCluster = "aks-hm8-dev-westus-002"
$kvname = "kv-hm8-dev-westus-002-6"
$tenantId = "b41b72d0-4e9f-4c26-8a69-f949f367c91d"

# az aks create --name $myAKSCluster --resource-group $myResourceGroup --enable-addons azure-keyvault-secrets-provider --enable-oidc-issuer --enable-workload-identity --generate-ssh-keys
# az aks enable-addons --addons azure-keyvault-secrets-provider --name $myAKSCluster --resource-group $myResourceGroup

$objectId = az aks show --resource-group $myResourceGroup --name $myAKSCluster --query addonProfiles.azureKeyvaultSecretsProvider.identity.objectId -o tsv
$objectId
$clientId = az aks show --resource-group $myResourceGroup --name $myAKSCluster --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv

az keyvault set-policy --name $kvname --key-permissions get --object-id $objectId
az keyvault set-policy --name $kvname --secret-permissions get --spn $clientId
