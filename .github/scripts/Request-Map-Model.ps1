Function Request-Map-Model {
  Param(
    [Parameter(Mandatory = $true , Position = 0)] [string]$ROBLOSECURITY,
    [Parameter(Mandatory = $true , Position = 1)] [string]$APIKEY,
    [Parameter(Mandatory = $false, Position = 3)] [string]$MAP,
    [Parameter(Mandatory = $false, Position = 4)] [string]$PATCH
  )
  process {
    # Validation Process
    ForEach ($thing in $ROBLOSECURITY, $APIKEY, $MAP, $PATCH) {
      If ([string]::IsNullOrEmpty($thing)) { exit 1; } }

    $FoundMap = ""
    If ($MAP -imatch "ID: ?[0-9]+") {
     
      $res = Invoke-RestMethod -Method Get -Uri
      "https://api.strafes.net/v1/map/${FoundMap}?api-key=${APIKEY}"
      
      # Error
      If ($res["message"] -ne $null) {
        If ($res["message"] -match
        "(No API key found in request|Invalid authentication credentials)") {
          Write-Error $res["message"] -TargetObject $res -Category AuthenticationError
        }
      }

      # On this resource, the API would only return an array if it is an error      
      If ($res.GetType().ToString().Name -ne "Object[]") {
        [System.Management.Automation.ErrorCategory]$Category = ^
        [System.Management.Automation.ErrorCategory]::NotSpecified
        
        $res | ForEach {
          $msg = $_.message
          
          # Auth Error
          If ($msg -eq "unable to auth") {
            $Category = ^
            [System.Management.Automation.ErrorCategory]::AuthenticationError }

          # Rate Limited
          If ($msg -eq "api limit exceeded") {
            $Category = [System.Management.Automation.ErrorCategory]::QuotaExceeded }
        
        }

        Write-Error "API Error" -TargetObject $res -Category 
        exit 1
      } # An error occured.


    } else {}

    # First, look for the map model in the strafesnet account
    # OR grab it from the api via id and get the model

    # then download the model and patch with said diff
    # then upload it using tarmac

  }
}
