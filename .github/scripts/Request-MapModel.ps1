# This script was written in PowerShell 7.3.0-preview.3

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true, Position = 0)]
  [ValidatePattern("[0-9]+")][ValidateNotNullOrEmpty()]
  [string] $MAP,

  [Parameter(Mandatory = $false, Position = 1)]
  [string] $PATCH,

  [Parameter(Mandatory = $false, Position = 2)]
  [string] $RS
)

Write-Verbose "Checking PowerShell version"
If ($PSVersionTable.PSVersion.Major -ne 7) { Throw "This script requires PowerShell 7.0 or later." }

Write-Verbose "Setting up stuff for API interactions."

# $BhopModelsID = 357810123
# $SurfModelsID = 357809318

# Is nullable
class RobloxError {
  [int]    $code
  [string] $message
}

# Asset Delivery Roblox API response
# This has more properties, but we only need these
class ADRoblox {
  # Is nullable
  [string]        $location
  [RobloxError[]] $errors
}

class PIRoblox {
  # Errors
  [int]           $code   # 500
  [string]        $message # "InternalServerError"
  [RobloxError[]] $errors # code is always 400

  [string]        $Name
  # https://developer.roblox.com/en-us/api-reference/enum/AssetType
  [int]           $AssetTypeId
}

# Inventory Roblox API response
class IRoblox {
  # Errors
  [RobloxError] $errors

  [string]      $previousPageCursor
  [string]      $nextPageCursor
  [int]         $AssetTypeId
  [IRobloxData] $data
}

class IRobloxData {
  [int64]       $assetId
  [string]      $name # Ends with .rbxmx sometimes
  [string]      $assetType # "Model"
  [string]      $created # This format: 2017-12-07T01:42:06.237Z
}

Write-Verbose "Verifying asset type"
Write-Verbose "Invoking the Marketplace Product Info API: /marketplace/productinfo?assetId=$MAP"
[PIRoblox] $PIRes = Invoke-RestMethod -Uri "https://api.roblox.com/marketplace/productinfo?assetId=$MAP" -Method "Get" -ContentType "application/json"

Write-Verbose "Reading the API response"

Throw "API returned following error(s): $($null -ne $PIRes.code ? "$($PIRes.message) ($($PIRes.code))" : "$($PIRes.errors | ForEach-Object { "$($_.message) ($($_.code)) " })")"

# Asset Details
If ($PIRes.AssetTypeId -ne 10) {
  Throw "Asset type is not a Roblox Model."
}

Write-Verbose "Invoking the Asset Delivery Roblox API: /v1/assetId/$MAP"
[ADRoblox] $ADres = Invoke-RestMethod -Uri "https://assetdelivery.roblox.com/v1/assetId/$MAP" -Method "Get" -ContentType "application/json"

Write-Verbose "Reading the API response"

# Location is not found, assume error
If ([string]::IsNullOrEmpty($ADres.location)) {
  Throw ($null -eq $ADres.errors) ? "Unknown API Error = $ADres" :
  ([string]::IsNullOrEmpty($DisplayError) ?
  "Unknown API Error.^r^n$(ConvertTo-Json $ADres)" : $DisplayError)
}
Else {
  Write-Verbose "Resource found"
  If ($null -eq $PATCH) {
    # BTW, you can find the exact model url by combining the <Creator.Id> and <Name> objects from
    # api.roblox.com/marketplace/productinfo?assetId=INSERT_ASSET_ID
    # And format appropriate objects as:
    # https://www.roblox.com/library/INSERT_CREATOR_ID/INSERT_ASSET_NAME
    Write-Host "Download the asset at $ADres.location" -ForegroundColor "Green"
    Exit 0
  }
}

Write-Verbose "Next step: Patching the asset"

# Write-Verbose "But first, let's make sure this hasn't been done already"

# Write-Verbose "Invoking the Inventory Roblox API: /v2/users/357809318/inventory?assetTypes=Model&limit=100&sortOrder=Asc"

# [IRoblox] $Ires = Invoke-RestMethod -Uri "https://inventory.roblox.com/v2/users/357810123/inventory?assetTypes=Model&limit=100&sortOrder=Asc" -Method "Get" -ContentType "application/json"

# Write-Verbose "Reading the API response"

# If ($null -ne $Ires.errors) {
#   Throw "API returned an error: $($Ires.errors | ForEach-Object { "$($_.message) ($($_.code)) " })"
# }

# Write-Verbose "Looping through data..."

# ForEach ($dat in $Ires.data) {
#   If ($dat.name -match "") {}
# }

# Write-Verbose "Ok, haven't done this, continuing"

Write-Verbose "Validating patch path"
If (!((Test-Path $PATCH -PathType Leaf) -and ($PATCH -match ".+\.(patch|diff)"))) {
  Throw "Patch path is invalid"
}

Write-Verbose "Preparing tmp folder"
mkdir tmp
Set-Location "tmp"

Write-Verbose "Downloading Roblox resource from $ADres.location"
Invoke-WebRequest -Uri $ADres.location -OutFile "model.rbxm" # Always downloads in binary format 

Write-Verbose "Verifying rbx-util presence"
If (Test-Path -Path ".\.github\bin\rbx-util.exe" -PathType "Leaf") {
  Write-Verbose "rbx-util found"
}
Else {
  .\.github\scripts\Compile-RbxUtil.ps1
}

Write-Verbose "Invoking rbx-util with arguments: convert model.rbxm model.rbxmx"
.\.github\bin\rbx-util.exe "convert model.rbxm model.rbxmx"
# Test-Path "tmp/model.rbxmx" -PathType "Leaf"

Write-Verbose "Applying patch to model.rbxmx"
git.exe "apply $PATCH"

Write-Verbose "Transforming XML to binary format for upload"
.\.github\bin\rbx-util.exe "convert model.rbxmx model.rbxm"

Write-Verbose "Uploading to Asset Delivery"
$urlparams = "json=1&assetid=0&type=Model&genreTypeId=1&name=$($PIRes.Name + "_")&ispublic=true&allowComments=false"
Invoke-RestMethod -Uri ("https://data.roblox.com/Data/Upload.ashx?$urlparams" + $urlparams) -Method "Post" -ContentType "application/xml" -Headers @{
  "X-CSRF-TOKEN" = $RS
} -Body (Get-Content "model.rbxmx")

Write-Host ""
