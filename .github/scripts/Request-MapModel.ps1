Function Request-MapModel {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true, Position  = 0)] [string]$ROSEC,
    [Parameter(Mandatory = $true, Position  = 1)]
    [ValidatePattern("[0-9]+")]                   [string]$MAP,
    [Parameter(Mandatory = $false, Position = 2)] [string]$PATCH
  )

  Write-Verbose "Invoking the Asset Delivery Roblox API: /v1/assetId/$Map"
  $res = Invoke-RestMethod -Uri "https://assetdelivery.roblox.com/v1/assetId/${FoundMap}" -Method "Get" -Headers "Accept: application/json"

  Write-Verbose "Checking for errors returned from the API"
}

  # First, look for the map model in the strafesnet account
  # OR grab it from the api via id and get the model

  # then download the model and patch with said diff
  # then upload it
}
