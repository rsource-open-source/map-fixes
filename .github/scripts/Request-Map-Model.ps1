Function Request-Map-Model {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true , Position = 0)] [string]$ROBLOSECURITY,
    [Parameter(Mandatory = $true , Position = 1)] [string]$APIKEY,
    [Parameter(Mandatory = $false, Position = 3)] [string]$MAP,
    [Parameter(Mandatory = $false, Position = 4)] [string]$PATCH
  )
  # Validation Process
  ForEach ($thing in $ROBLOSECURITY, $APIKEY, $MAP, $PATCH) {
    If ([string]::IsNullOrEmpty($thing)) { exit 1; } }

  If ($MAP -imatch "ID: ?[0-9]+") {
    Write-Verbose "Identified map input is a map id"
    $MAP = [regex]::split($MAP, ": ?")

    Write-Verbose "Invoking the StrafesNET API: /v1/map/$Map"
    $res = Invoke-RestMethod -Method Get -Uri "https://api.strafes.net/v1/map/${FoundMap}?api-key=$APIKEY"

    Write-Verbose "Checking for errors returned from the API"
    If ($res.GetType().Name -eq "PSCustomObject" -and $res["message"] -ne $null) {
      If ($res["message"] -match
      "(No API key found in request|Invalid authentication credentials)") {
        Write-Error $res["message"] -TargetObject $res -Category AuthenticationError
      }
    } else { Write-Verbose "✔ No errors (i think)" }
  }

  # First, look for the map model in the strafesnet account
  # OR grab it from the api via id and get the model

  # then download the model and patch with said diff
  # then upload it
}
