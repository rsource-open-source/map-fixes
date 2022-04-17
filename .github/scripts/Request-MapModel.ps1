# This script was written in PowerShell 7.3.0-preview.3

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true, Position = 1)]
  [ValidatePattern("[0-9]+")][ValidateNotNullOrEmpty()]
  [string] $MAP,

  [Parameter(Mandatory = $false, Position = 2)]
  [string] $PATCH,

  [Parameter(Mandatory = $false, Position = 3)]
  [string] $RS
)

Write-Verbose "Checking PowerShell version"
If ($PSVersionTable.PSVersion.Major -ne 7) { Throw "This script requires PowerShell 7.0 or later." }

Write-Verbose "Setting up classes for API responses."

# Is nullable
class ADRobloxError {
  [int]    $code
  [string] $message
}

# Asset Delivery Roblox API response
# This has more properties, but we only need these
class ADRoblox {
  # Is nullable
  [string]          $location
  [ADRobloxError[]] $errors
}

Write-Verbose "Invoking the Asset Delivery Roblox API: /v1/assetId/$MAP"
[ADRoblox]$res = Invoke-RestMethod -Uri "https://assetdelivery.roblox.com/v1/assetId/$MAP" -Method "Get" -ContentType "application/json"

Write-Verbose "Reading the API response"
# Location is not found, assume error
If ([string]::IsNullOrEmpty($res.location)) {
  Throw ($null -eq $res.errors) ? "Unknown API Error = $res" :
  ([string]::IsNullOrEmpty($DisplayError) ?
  "Unknown API Error.^r^n$(ConvertTo-Json $res)" : $DisplayError)
}
Else {
  Write-Verbose "Resource found"
  If ($null -eq $PATCH) {
    Write-Host "Download the asset at $res.location"
    Exit 1
  }

  Write-Verbose "Next step: Patching the asset"

  Write-Verbose "Validating patch path"
  If ((Test-Path $PATCH -PathType Leaf) -and ($PATCH.EndsWith(".patch"))) {
    Write-Verbose "Patch path is valid"
  }
  Else {
    Throw "Patch path is invalid"
  }

  Write-Verbose "Preparing tmp folder"
  mkdir tmp
  Set-Location "tmp"

  Write-Verbose "Downloading Roblox resource from $res.location"
  Invoke-WebRequest -Uri $res.location -OutFile "model.rbxm" # Always downloads in binary format 

  Write-Verbose "Invoking rbx-util with arguments: convert model.rbxm model.rbxmx"
  .\.github\bin\rbx-util.exe "convert model.rbxm model.rbxmx"
  # Test-Path "tmp/model.rbxmx" -PathType "Leaf"

  Write-Verbose "Applying patch to model.rbxmx"
  git.exe "apply $PATCH"
  
  Write-Verbose "Transforming XML to binary format for upload"
  .\.github\bin\rbx-util.exe "convert model.rbxmx model.rbxm"

  Write-Verbose "Uploading to Asset Delivery"
  Invoke-RestMethod -Uri "https://data.roblox.com" # fuck

  Write-Host ""
}
