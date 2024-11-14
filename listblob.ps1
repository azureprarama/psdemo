$env:PSModulePath=$env:PSModulePath+";"+"C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell"
Import-Module Az
$Context = New-AzStorageContext -StorageAccountName spoolstoragetest -UseConnectedAccount
# Get a list of containers in a storage account
Get-AzStorageContainer -context $context
