$azStorageAccountName = "" # Name of your storage account 
$azStorageAccountKey = "" # Access key for your storage account
$azContainerName = "" # Container name to list your blobs
$azResourceGroupName = "" # Resource group name where storage account lives

$connectionContext = (Get-AzStorageAccount -ResourceGroupName $azResourceGroupName -AccountName $azStorageAccountName).Context
# Get a list of containers in a storage account
Get-AzStorageContainer -Name $azContainerName -Context $connectionContext | Select Name
# Get a list of blobs in a container 
Get-AzStorageBlob -Container $azContainerName -Context $connectionContext | Select Name
