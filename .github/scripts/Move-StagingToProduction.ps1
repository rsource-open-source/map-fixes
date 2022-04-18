Get-ChildItem "staging" -Filter "*.diff" | Move-Item -Destination "production"
