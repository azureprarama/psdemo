#uma
Param(
    [Parameter (Mandatory = $true)]
    [String]$JSONPath
)

function checkinJSONFile {
    #necesarry Parameters
    param (
        [Parameter (Mandatory = $true)]
        [string]$Path
    )

    if(-not(Test-Path $Path)){
        Write-Output "The File could not be found at path " + $Path
        throw 'The specified JSON Helper File does not exist'
        exit
    } elseif(Test-Path $Path) {
        $inputJson = Get-Content -raw $Path
        $inputRaw = ConvertFrom-Json $inputJson
        return $inputRaw
    }
}

function fillStorageAccountArray {
    $saArray = @()
    $saArray = Get-AzStorageAccount | Select-Object StorageAccountName
    return $saArray
  
  }


  function fillPathArray {
    param (
        [Parameter (Mandatory = $true)]
        [array]$saArray
    )
    
    $pathArray = @()
  
    foreach ($sa in $saArray) {
        $context = New-AzStorageContext -StorageAccountName $sa.StorageAccountName -UseConnectedAccount 
        Write-Host 'StorageAccount: ' $sa.StorageAccountName
        $allContainers = Get-AzStorageContainer -context $context
        $allContainers = $allContainers.name
  
        foreach ($container in $allContainers) {
            $folderPerContainer = $Null

            $folderPerContainer = getRelevantPathes -StorageAccountName $sa.StorageAccountName -container $container

            Write-Host "relevant folders (upper 4 levels):" $sa.StorageAccountName $container  ':'  $folderPerContainer.count;
        
            if ($folderPerContainer) {
                foreach ($folder in $folderPerContainer) {
                    $addpath = $sa.StorageAccountName + '/' + $container + '/' + $folder.Path
                    # limit path to max. four occurences of /
                    $ind = 0
                    for ($i = 0; $i -lt 5; $i++) {
                        $ind = $addpath.IndexOf("/",$ind)
                        if ($ind -lt 0) {
                            $ind = $addpath.Length+1
                            break}
                        $ind=$ind+1
                    }
                    $addpath = $addpath.substring(0, $ind-1)

                    # add to pathArray if not already in
                    $found = 0
                    foreach ($p in $pathArray){
                        if ($p -eq $addpath) {
                            $found = 1
                            break
                        } 
                    }
                    if (!($found)) {
                        $pathArray += $addpath
                    }
                }
            }

        }
    }
    return $pathArray
  }
  

  function getRelevantPathes {
    param (
        [Parameter (Mandatory = $true)]
        [string]$StorageAccountName,
        [Parameter (Mandatory = $true)]
        [string]$Container
    )
  
    $folderPerContainerLevel1 = @();
    $folderPerContainerLevel2 = @();
    $folderPerContainerLevel3 = @();
    $folderPerContainerLevel4 = @();
  
    $context = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount 
  
    $path = '/'
    # Level 1 Folder
    do{
        $folderPerContainerChunk = Get-AzDataLakeGen2ChildItem -Context $context -FileSystem $container -Path $path -ContinuationToken $token  -ErrorAction SilentlyContinue
        $pathChunk = $folderPerContainerChunk | Where-Object {$_.IsDirectory -eq $true} | Select-Object "Path"
        $folderPerContainerLevel1 += $pathChunk 
        if($folderPerContainerChunk.Length -le 0) { Break;}
        $token = $folderPerContainerChunk[$folderPerContainerChunk.Count -1].ContinuationToken;        
  
    } While ($Null -ne $token);
  
    # Level 2 Folder
    foreach($upPath in $folderPerContainerLevel1){
        do{
            $folderPerContainerChunk = Get-AzDataLakeGen2ChildItem -Context $context -FileSystem $container -Path $upPath.Path -ContinuationToken $token 
            $pathChunk = $folderPerContainerChunk | Where-Object {$_.IsDirectory -eq $true} | Select-Object "Path"
            $folderPerContainerLevel2 += $pathChunk 
            if($folderPerContainerChunk.Length -le 0) { Break;}
            $token = $folderPerContainerChunk[$folderPerContainerChunk.Count -1].ContinuationToken;         
        } While ($Null -ne $token);
    }
  
    # Level 3 Folder
    foreach($upPath in $folderPerContainerLevel2){
        do{
            $folderPerContainerChunk = Get-AzDataLakeGen2ChildItem -Context $context -FileSystem $container -Path $upPath.Path -ContinuationToken $token 
            $pathChunk = $folderPerContainerChunk | Where-Object {$_.IsDirectory -eq $true} | Select-Object "Path"
            $folderPerContainerLevel3 += $pathChunk 
            if($folderPerContainerChunk.Length -le 0) { Break;}
            $token = $folderPerContainerChunk[$folderPerContainerChunk.Count -1].ContinuationToken;         
        } While ($Null -ne $token);
    }
  
    # Level 4 Folder
    foreach($upPath in $folderPerContainerLevel2){
        do{
            $folderPerContainerChunk = Get-AzDataLakeGen2ChildItem -Context $context -FileSystem $container -Path $upPath.Path -ContinuationToken $token 
            $pathChunk = $folderPerContainerChunk | Where-Object {$_.IsDirectory -eq $true} | Select-Object "Path"
            $folderPerContainerLevel4 += $pathChunk 
            if($folderPerContainerChunk.Length -le 0) { Break;}
            $token = $folderPerContainerChunk[$folderPerContainerChunk.Count -1].ContinuationToken;         
        } While ($Null -ne $token);
    }

    $folderPerContainer = @();
    $folderPerContainer += $folderPerContainerLevel1 
    $folderPerContainer += $folderPerContainerLevel2 
    $folderPerContainer += $folderPerContainerLevel3
    $folderPerContainer += $folderPerContainerLevel4

    Return $folderPerContainer
  
  }

  
function createContainerAndSubFolders {

    param (
      [Parameter (Mandatory = $true)]
      [array]$row,
      [Parameter (Mandatory = $false)]
      [array]$pathArray
    )
    if(!($pathArray)){$pathArray = @("empty")}
      
    $helperPath = $row.StorageAccountName + '/' + $row.ContainerName + '/' + $row.path
    $helperPath = $helperPath.tolower()
  
    if($pathArray.Contains($helperPath)){
        Write-Host $helperPath already exists...Continuing
        } 
    else {
        $context = New-AzStorageContext -StorageAccountName $row.StorageAccountName -UseConnectedAccount 

        #check if dir exists
        Write-Host "checking if dir exists...."
        $existingDir = Get-AzDataLakeGen2Item -Context $context -FileSystem $row.ContainerName -Path $row.path -ErrorAction 'SilentlyContinue'

        if(!$existingDir){
            Write-Host "dir does not exist... Checking if Container exists with Name " 
            $row.ContainerName
            $parentFolder = Get-AzDatalakeGen2FileSystem -Context $context -Name $row.ContainerName -ErrorAction 'SilentlyContinue'

            if(!$parentFolder){
                $parentFolder = New-AzDatalakeGen2FileSystem -Context $context -Name $row.ContainerName -ErrorAction 'SilentlyContinue'
                New-AzDataLakeGen2Item -Context $context -FileSystem $row.ContainerName -Path $row.path -Directory -ErrorAction 'SilentlyContinue'
                } 
            else {
                Write-Host "Container already exists, continuing with subfolders... $helperPath"
                New-AzDataLakeGen2Item -Context $context -FileSystem $row.ContainerName -Path $row.path -Directory #-ErrorAction 'SilentlyContinue'
                }
        } 
        else {
            Write-Host "Directory Structure already exsits...continuing"
        }  
    }
  }
  

<#
-----------------------------------------------------------------------
MainFunction
-----------------------------------------------------------------------
#>

Write-Output "Starting Script to create Containers and Folders"

# read folder helper file
$jsonContent = checkinJSONFile($JSONPath)
Write-Output "The File from path $JSONPath has been processed"
Write-Output "Handling the following input..."
$jsonContent = $jsonContent.folders
$jsonContent

# fill StorageAccount Array
$storageAccountArray = fillStorageAccountArray 

$pathDeployedArray = fillPathArray $storageAccountArray

foreach($row in $jsonContent){
    createContainerAndSubFolders $row $pathDeployedArray 

    }
