$app_path = Split-Path -path $PSScriptRoot -Parent

$chrome = Join-Path $app_path "ChromeSetup.exe"

Start-Process -FilePath $chrome -ArgumentList "/silent /norestart" -Verb RunAs
