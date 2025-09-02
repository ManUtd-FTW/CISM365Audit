# Dot-source all public/private functions
Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' | ForEach-Object { . $_.FullName }
Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' | ForEach-Object { . $_.FullName }
