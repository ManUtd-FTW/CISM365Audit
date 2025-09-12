# CISM365Audit.psm1
# Module bootstrap: load Helpers, then Controls (located under Private\Controls in your repo),
# then Public and Private. All dot-sourcing is defensive so a single failing file won't prevent
# the module from registering exported functions.

# 1) Load helpers (dot-source once, defensive)
$helpersDir = Join-Path $PSScriptRoot 'Helpers'
if (Test-Path $helpersDir) {
    Get-ChildItem -Path $helpersDir -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object {
            try {
                . $_.FullName
            } catch {
                Write-Verbose "Failed to dot-source helper $($_.Name): $($_.Exception.Message)"
            }
        }
}

# 2) Load controls (Controls live under Private\Controls in this repo)
$controlsDir = Join-Path $PSScriptRoot 'Private\Controls'
if (-not (Test-Path $controlsDir)) {
    # fallback for alternate layout
    $controlsDir = Join-Path $PSScriptRoot 'Controls'
}
if (Test-Path $controlsDir) {
    Get-ChildItem -Path $controlsDir -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object {
            try {
                . $_.FullName
            } catch {
                Write-Verbose "Failed to load control file $($_.Name): $($_.Exception.Message)"
            }
        }
} else {
    Write-Verbose "Controls directory not found at either Private\Controls or Controls under $PSScriptRoot"
}

# 3) Directly dot-source Public scripts in *this* scope (as before)
$publicDir = Join-Path $PSScriptRoot 'Public'
if (Test-Path $publicDir) {
    Get-ChildItem -Path $publicDir -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object {
            try {
                . $_.FullName
            } catch {
                Write-Verbose "Failed to load public script $($_.Name): $($_.Exception.Message)"
            }
        }
}

# 4) Dot-source Private scripts in *this* scope (as before), but avoid re-sourcing Private\Controls
$privateDir = Join-Path $PSScriptRoot 'Private'
if (Test-Path $privateDir) {
    Get-ChildItem -Path $privateDir -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object {
            try {
                # skip control files which are in Private\Controls
                if ($_.FullName -like (Join-Path $PSScriptRoot 'Private\Controls\*')) { return }
                . $_.FullName
            } catch {
                Write-Verbose "Failed to load private script $($_.Name): $($_.Exception.Message)"
            }
        }
}