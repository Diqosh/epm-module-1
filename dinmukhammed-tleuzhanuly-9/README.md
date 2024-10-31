
### 1. Configure Kubernetes Cluster

Merge your Kubernetes configuration to connect to your AKS cluster by running:

```sh
 az aks show --resource-group rg-myapp-dev-eastus-001 --name aks-myapp-dev-eastus-001 --query "identityProfile.kubeletidentity.clientId" -o tsv
 ```

### 4. Deploy Your Application
```sh
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 5. Check Pod and Service Status
kubectl get pods
kubectl get svc

https://stackoverflow.com/questions/71005927/how-to-find-aks-external-ip-using-terraform-data-block