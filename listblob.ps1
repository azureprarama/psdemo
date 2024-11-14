$Context = New-AzStorageContext -StorageAccountName spoolstoragetest -UseConnectedAccount
# Get a list of containers in a storage account
Get-AzStorageContainer -context $context
