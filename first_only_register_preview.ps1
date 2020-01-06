write-host "> Login to Azure..."
az login

write-host "> check installation az preview extension..."
az extension add --name aks-preview
az feature register --name WindowsPreview `
   --namespace Microsoft.ContainerService

az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/WindowsPreview')].{Name:name,State:properties.state}"
write-host "Please wait about 5 minutes"
