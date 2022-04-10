$L = Get-Location
Get-ChildItem -Path "$L/staging" -Filter *.diff |
ForEach-Object {
    Write-Host $_
}
