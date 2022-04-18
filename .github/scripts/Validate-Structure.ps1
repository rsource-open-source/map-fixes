$ExpectedFolders = 'staging', 'production', '.github'
$ExpectedFiles = '.gitignore', '.gitattributes', 'staging\keepalive', 'production\keepalive', 'README.md'
$ExpectedFileRegex = "(.+\.(patch|diff)|keepalive)"

Get-ChildItem -Attributes "Directory" -Name | ForEach-Object {
  If (!($_ -in $ExpectedFolders)) { Throw "Unexpected folder: $_, expected folders: $ExpectedFolders"} }

Get-ChildItem -Attributes "Archive" -Name | ForEach-Object {
  If (!($_ -in $ExpectedFiles)) { Throw "Unexpected file: $_, expected files: $ExpectedFiles"} }

Get-ChildItem $ExpectedFolders[0,1] -Name | ForEach-Object {
    If ($_ -notmatch $ExpectedFileRegex) { Throw "Unexpected file: $_, expected file RegEx: $ExpectedFileRegex" }
}
