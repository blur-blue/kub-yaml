
#----valiables-----#
$ACRname = "aspacr"
$RGname = "aks-win"
$AKSname = "win-cni-aks"
$ContainerName = "nameform:v1"
$NodeNum = 2
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
Write-host "> It needs about 5 minutes or more..."
az aks create `
   --resource-group $RGname --name $AKSname --node-count $NodeNum `
   --enable-addons monitoring --kubernetes-version 1.15.5 `
   --generate-ssh-keys --windows-admin-password $Pass `
   --windows-admin-username $RootID `
   --vm-set-type VirtualMachineScaleSets `
   --load-balancer-sku standard `
   --network-plugin azure
Write-Host "> Finished Creating AKS Cluster..."

Write-Host "<-----Start Adding AKS Windows Node----->"
Write-host "> It needs about 5 minutes or more..."
az aks nodepool add `
   --resource-group $RGname --cluster-name $AKSname `
   --os-type Windows --name $WinNodeName `
   --node-count $NodeNum --kubernetes-version 1.15.5 `
   --node-vm-size $VMsize
Write-Host "> Finished Adding AKS Windows Node..."

Write-Host "> Integration ACR and AKS..."
az aks update -n $AKSname -g $RGname --attach-acr $ACRname

Write-Host "> Setting Kube_config to using AKS Registry..."
az aks get-credentials --resource-group $RGname --name $AKSname

Write-Host "> Finished Setting up. use ---> kubectl apply"

