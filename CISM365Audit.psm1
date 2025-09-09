# CISM365Audit.psm1
# Module bootstrap: load Helpers, then Controls (Private\Controls), then Public and other Private scripts.

# 1) Load helpers (dot-source once, defensive)
$helpersDir = Join-Path $PSScriptRoot 'Helpers'
if (Test-Path $helpersDir) {
    Get-ChildItem -Path $helpersDir -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object {
            try { . $_.FullName } catch { Write-Verbose "Failed to dot-source helper $($_.Name): $($_.Exception.Message)" }
        }
}

# 2) Load controls (Controls live under Private\Controls)
$controlsDir = Join-Path $PSScriptRoot 'Private\Controls'
if (-not (Test-Path $controlsDir)) { $controlsDir = Join-Path $PSScriptRoot 'Controls' }
if (Test-Path $controlsDir) {
    Get-ChildItem -Path $controlsDir -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object {
            try { . $_.FullName } catch { Write-Verbose "Failed to load control file $($_.Name): $($_.Exception.Message)" }
        }
} else { Write-Verbose "Controls directory not found at either Private\Controls or Controls under $PSScriptRoot" }

# 3) Directly dot-source Public scripts in *this* scope
$publicDir = Join-Path $PSScriptRoot 'Public'
if (Test-Path $publicDir) {
    Get-ChildItem -Path $publicDir -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object { try { . $_.FullName } catch { Write-Verbose "Failed to load public script $($_.Name): $($_.Exception.Message)" } }
}

# 4) Dot-source Private scripts in *this* scope (skip Private\Controls)
$privateDir = Join-Path $PSScriptRoot 'Private'
if (Test-Path $privateDir) {
    Get-ChildItem -Path $privateDir -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object {
            try {
                if ($_.FullName -like (Join-Path $PSScriptRoot 'Private\Controls\*')) { return }
                . $_.FullName
            } catch { Write-Verbose "Failed to load private script $($_.Name): $($_.Exception.Message)" }
        }
}