## Steps


├── README.md
├── app                                 # redis + flask app
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── assets                              # k8s yaml and scripts
│   ├── deployment.yaml     
│   ├── give_access_k8s_to_kv.ps1
│   ├── pod.yaml
│   ├── secretproviderclass.yaml
│   └── service.yaml
├── backend.tf
├── config
│   └── dev.tfvars
├── main.tf
├── outputs.tf
├── screenshots                                     # my results to show Dzmitry :)
│   ├── Screenshot 2024-07-17 at 00.48.34.png
│   ├── Screenshot 2024-07-17 at 00.48.39.png
│   ├── aci_pip.png
│   └── k8s_pip.png
└── variables.tf

### 1. Configure Kubernetes Cluster

Merge your Kubernetes configuration to connect to your AKS cluster by running:

```sh
az aks get-credentials --resource-group rg-hm8-dev-westus-001 --name myAKSCluster
```


### 2. Addition config

Give access k8s to key vault: ./assets/give_access_k8s_to_kv.ps1

Add space for example for service.yaml i wrote trigger for null_resource.secret to generating registrykey for acces aci to my k8s cluster


### 3. Mount Azure Key Vault Secrets
```sh
kubectl apply -f secretproviderclass.yaml    
```


### 4. Deploy Your Application
```sh
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 5. Check Pod and Service Status
kubectl get pods
kubectl get svc

Note i implement env pass my key vault via deployment


