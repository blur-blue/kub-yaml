
#----valiables-----#
$ACRname = "aspacr"
$RGname = "aks-win"
$VNetName = "aks-vnet"
$AKSname = "win-closed-aks"
$ContainerName = "nameform:v1"
$NodeNum = 1
$Pass = "Passw@rd1234"
$RootID = "azureadmin"
$WinNodeName = "npwin"
$VMsize = "Standard_B2s"
#----valiables-----#

write-host "> Login to Azure..."
az login

#----checking preview module installation-----#
write-host "> check installation az preview extension..."
az extension add --name aks-preview
az feature register --name WindowsPreview `
   --namespace Microsoft.ContainerService
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/WindowsPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService
 
az extension add --name aks-preview
az feature register --name WindowsPreview `
--namespace Microsoft.ContainerService
az aks install-cli
#----checking preview module installation-----#


Write-Host "> Login to Azure Container Regestry..."
az acr login --name $ACRname

Write-Host "> Check ACR Container List..."
az acr repository list --nam $ACRname --output table


Write-Host "<-----Start Creating AKS Cluster----->"
write-host ">(1/5) Create Vnet for AKS"
az network vnet create -g $RGname -n $VnetName --address-prefix 10.0.0.0/16 --subnet-name akssubnet --subnet-prefix 10.0.0.0/24
$subID = (az network vnet subnet list -g $RGname --vnet-name $VNetName --query "[0].id" --output tsv)

Write-host ">(2/5) Creating AKS. It needs about 5 minutes or more..."
az aks create `
   --resource-group $RGname --name $AKSname --node-count $NodeNum `
   --enable-addons monitoring --kubernetes-version 1.15.5 `
   --generate-ssh-keys --windows-admin-password $Pass `
   --windows-admin-username $RootID `
   --vnet-subnet-id $subID `
   --docker-bridge-address 172.17.0.1/16 `
   --dns-service-ip 10.1.0.10 `
   --service-cidr 10.1.0.0/24 `
   --vm-set-type VirtualMachineScaleSets `
   --load-balancer-sku standard `
   --network-plugin azure
Write-Host "> Finished Creating AKS Cluster..."

Write-Host ">(3/5) Start Adding AKS Windows Node"
Write-host "> It needs about 5 minutes or more..."
az aks nodepool add `
   --resource-group $RGname --cluster-name $AKSname `
   --os-type Windows --name $WinNodeName `
   --node-count $NodeNum --kubernetes-version 1.15.5 `
   --node-vm-size $VMsize
Write-Host "> Finished Adding AKS Windows Node..."

Write-Host ">(4/5) Integration ACR and AKS..."
az aks update -n $AKSname -g $RGname --attach-acr $ACRname

Write-Host ">(5/5) Setting Kube_config to using Azure Container Resources..."
az aks get-credentials --resource-group $RGname --name $AKSname

Write-Host "> Finished Setting up. use ---> kubectl apply"

