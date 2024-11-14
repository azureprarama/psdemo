$azStorageAccountName = "" # Name of your storage account 
$azStorageAccountKey = "" # Access key for your storage account
$azContainerName = "" # Container name to list your blobs
$azResourceGroupName = "" # Resource group name where storage account lives

$Context = New-AzStorageContext -StorageAccountName $row.StorageAccountName -UseConnectedAccount
# Get a list of containers in a storage account
Get-AzStorageContainer -context $context
