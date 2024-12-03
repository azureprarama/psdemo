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