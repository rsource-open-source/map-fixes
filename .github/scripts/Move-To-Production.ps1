$list = 'staging', 'production'
$L = Get-Location
ForEach ($f in $list) {
    Get-ChildItem -Path "staging" -Filter *.diff |
    ForEach-Object {
        Move-Item -Path $_.DirectoryName -Destination "$L\production"
    }
}
