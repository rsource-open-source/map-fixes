Get-ChildItem "staging" | Where-Object { $_.Name -match ".+\.(patch|diff)" } | Move-Item -Destination "production"
