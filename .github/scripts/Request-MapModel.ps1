Function Request-MapModel {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true, Position = 0)] [string]$MAP,
    [Parameter(Mandatory = $false, Position = 1)] [string]$PATCH
  )

  Write-Verbose "Checking map input type"

  If ($MAP -imatch "[0-9]+") {
    Write-Verbose "Identified map input is ID"
    $MAP = [regex]::split($MAP, ": ?")

    Write-Verbose "Invoking the Asset Delivery Roblox API: /v1/assetId/$Map"
    $res = Invoke-RestMethod -Uri "https://assetdelivery.roblox.com/v1/assetId/${FoundMap}" -Method "Get" -Headers "Accept: application/json"

    Write-Verbose "Checking for errors returned from the API"
    If ($res.GetType().Name -eq "PSCustomObject" -and $null -ne $res["message"]) {
      If ($res["message"] -match
        "(No API key found in request|Invalid authentication credentials)") {
        Write-Error $res["message"] -TargetObject $res -Category AuthenticationError
      }
    }
    Else { Write-Verbose "✔ No errors (i think)" }
  }

  # First, look for the map model in the strafesnet account
  # OR grab it from the api via id and get the model

  # then download the model and patch with said diff
  # then upload it
}
