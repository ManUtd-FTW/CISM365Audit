# CISM365Audit.psm1

# Directly dot-source Public scripts in *this* scope
Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' -File |
    Sort-Object Name |
    ForEach-Object { . $_.FullName }

# Dot-source Private scripts in *this* scope
Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' -File |
    Sort-Object Name |
    ForEach-Object { . $_.FullName }