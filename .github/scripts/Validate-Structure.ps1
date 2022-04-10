If (! Test-Path -Path staging         -PathType Container) { exit 1 }
If (! Test-Path -Path production      -PathType Container) { exit 1 }
If (! Test-Path -Path .github         -PathType Container) { exit 1 }
If (! Test-Path -Path staging/keepalive    -PathType Leaf) { exit 1 }
If (! Test-Path -Path production/keepalive -PathType Leaf) { exit 1 }

$list = 'staging', 'production'

Foreach ($f in $list) {
    Get-ChildItem -Path $f -Exclude keepalive |
    ForEach-Object {
        If ($_.Mode -eq "d----")      { exit 1 }
        If ($_.Extension -ne ".diff") { exit 1 }
    }
}
