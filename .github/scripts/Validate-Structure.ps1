If (!(Test-Path -Path staging         -PathType Container)) { Exit 1 }
If (!(Test-Path -Path production      -PathType Container)) { Exit 1 }
If (!(Test-Path -Path .github         -PathType Container)) { Exit 1 }
If (!(Test-Path -Path staging/keepalive    -PathType Leaf)) { Exit 1 }
If (!(Test-Path -Path .gitattributes      - PathType Leaf)) { Exit 1 }
If (!(Test-Path -Path .gitignore           -PathType Leaf)) { Exit 1 }
If (!(Test-Path -Path production/keepalive -PathType Leaf)) { Exit 1 }

$list = 'staging', 'production'

Foreach ($f in $list) {
    Get-ChildItem -Path $f -Exclude keepalive |
    ForEach-Object {
        If ($_.Mode -eq "d----") { Exit 1 }
        If ($_.Extension -ne ".diff") { Exit 1 }
    }
}
