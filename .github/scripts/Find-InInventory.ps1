[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true, Position = 0)]
  [ValidatePattern("[0-9]+")][ValidateNotNullOrEmpty()]
  [string] $ID,

  [Parameter(Mandatory = $true, Position = 1)]
  [ValidatePattern("bhop|surf")][ValidateNotNullOrEmpty()]
  [string] $GAME,

  [Parameter(Mandatory = $false, Position = 2)]
  [switch] $DOWNLOADSTR = $false
)

$BhopModelsID = 357810123
$SurfModelsID = 357809318

# Is nullable, across all APIs
class RobloxError {
  [int]    $code
  [string] $message
}

class IRoblox {
  # Errors
  [RobloxError] $errors

  [string]      $previousPageCursor
  [string]      $nextPageCursor
  [int]         $AssetTypeId
  [IRobloxData] $data
}

class IRobloxData {
  [string] $assetId # Sometimes can be ######## (retard roblox)
  [string] $name # Ends with .rbxmx sometimes
  [string] $assetType # "Model"
  [string] $created # This format: 2017-12-07T01:42:06.237Z
}

class ADRoblox {
  [string] $location
}

[IRoblox] $res = Invoke-RestMethod -Uri "https://inventory.roblox.com/v2/users/$($GAME -eq "bhop" ? $BhopModelsID : $SurfModelsID)/inventory?assetTypes=Model&limit=100&sortOrder=Asc" -ContentType "application/json"

If ($null -ne $res.errors) {
  Throw $res.errors | ConvertTo-Json
}

$Map = $res.data | Select-Object -Property assetId | Where-Object { $_.ToString() -eq $ID }

If (!$Map) {
  Throw "No map found with ID: $ID" # on first page anyways
}

If (($DOWNLOADSTR -eq $true) -and ($null -ne $j)) {
  [ADRoblox] $DS = Invoke-RestMethod -Uri "https://assetdelivery.roblox.com/v1/assetId/$ID"  -Method "Get" -ContentType "application/json"
}

# "Found ${ID}: $Map, download directly at ${DS.location} or get it at https://www.roblox.com/"