<#
.SYNOPSIS
    Discovers and returns the CISM365 control catalog from Private/Controls.

.DESCRIPTION
    - Dot-sources all files under Private/Controls/Control.*.ps1.
    - Invokes each Get-CISM365Control_* function to retrieve a control descriptor.
    - Supports filtering by IncludeControls, ExcludeControls, and CIS Profile (L1/L2).
    - Returns an array of hashtables with fields: Id, Name, Profile, Automated, Services, Description, Rationale, References, Audit.

.PARAMETER IncludeControls
    Array of control Ids to include (e.g., '1.1.3','2.1.9').

.PARAMETER ExcludeControls
    Array of control Ids to exclude.

.PARAMETER Profile
    Filter by CIS profile ('L1' or 'L2').

.NOTES
    This is an internal/private helper. It is dot-sourced by the module and not exported.

    Expected function signature in each control file:
        function Get-CISM365Control_<IdUnderscore> {
            @{
                Id='x.y.z'; Name='...'; Profile='L1'|'L2'; Automated=$true|$false;
                Services=@('Graph'|'ExchangeOnline'|'Teams'|'SharePoint'|'Compliance');
                Description='...'; Rationale='...'; References=@('https://...');
                Audit={ <scriptblock returning PASS|FAIL|MANUAL|ERROR message> }
            }
        }
#>
function Get-CISM365Controls {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]] $IncludeControls,

        [Parameter()]
        [string[]] $ExcludeControls,

        [Parameter()]
        [ValidateSet('L1','L2')]
        [string]   $Profile
    )

    # Resolve the Controls directory relative to this file
    $controlsPath = Join-Path -Path $PSScriptRoot -ChildPath 'Controls'

    if (-not (Test-Path -LiteralPath $controlsPath)) {
        Write-Verbose "Controls path not found: $controlsPath"
        return @()
    }

    # Dot-source every Control.*.ps1 file so their Get-CISM365Control_* functions are available
    Get-ChildItem -Path $controlsPath -Filter 'Control.*.ps1' -File -ErrorAction SilentlyContinue |
        ForEach-Object {
            try {
                . $_.FullName
                Write-Verbose ("Loaded control file: {0}" -f $_.Name)
            } catch {
                Write-Warning ("Failed to load control file {0}: {1}" -f $_.FullName, $_.Exception.Message)
            }
        }

    # Discover all factory functions that follow the naming pattern and invoke them
    $catalog = @()
    $factories = Get-Command -Name 'Get-CISM365Control_*' -CommandType Function -ErrorAction SilentlyContinue
    foreach ($f in $factories) {
        try {
            $descriptor = & $f.Name
            if ($null -ne $descriptor -and $descriptor.Id -and $descriptor.Audit) {
                $catalog += $descriptor
            } else {
                Write-Warning ("Control factory {0} did not return a valid descriptor." -f $f.Name)
            }
        } catch {
            Write-Warning ("Failed invoking control factory {0}: {1}" -f $f.Name, $_.Exception.Message)
        }
    }

    # Apply optional filters
    if ($Profile) {
        $catalog = $catalog | Where-Object { $_.Profile -eq $Profile }
    }
    if ($IncludeControls -and $IncludeControls.Count -gt 0) {
        $includeSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $IncludeControls | ForEach-Object { [void]$includeSet.Add($_) }
        $catalog = $catalog | Where-Object { $includeSet.Contains($_.Id) }
    }
    if ($ExcludeControls -and $ExcludeControls.Count -gt 0) {
        $excludeSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $ExcludeControls | ForEach-Object { [void]$excludeSet.Add($_) }
        $catalog = $catalog | Where-Object { -not $excludeSet.Contains($_.Id) }
    }

    # Sort by numeric-like Id if possible; otherwise as-is
    try {
    $catalog = $catalog |
        Select-Object *, @{Name='SortKey'; Expression={
            ($_.Id -split '\.') | ForEach-Object { '{0:D4}' -f [int]$_ } -join '.'
        }} |
        Sort-Object -Property SortKey |
        Select-Object * -ExcludeProperty SortKey
} catch {
    # ignore sort errors; return in discovered order
}

    return ,$catalog   # ensure array even if single item
}
