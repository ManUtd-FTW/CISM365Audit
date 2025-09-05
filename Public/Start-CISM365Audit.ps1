function Start-CISM365Audit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Tenant,

        [string]$OutputPath = ".\CISM365AuditReport.html",
        [string]$JsonOutputPath,
        [string[]]$IncludeControls,
        [string[]]$ExcludeControls,
        [ValidateSet('L1','L2')]
        [string]$Profile,
        [switch]$NoConnect,
        [ValidateSet('Global','USGov','USGovHigh','USGovDoD','China')]
        [string]$Cloud = 'Global',
        [switch]$DeviceCode
    )

    # --- Resolve TenantId or TenantDomain ---
    $tenantId = $null
    $tenantDomain = $null
    if ($Tenant -match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
        $tenantId = $Tenant
        Write-Verbose "Parsed Tenant as GUID: $tenantId"
    } else {
        $tenantDomain = $Tenant
        Write-Verbose "Parsed Tenant as domain: $tenantDomain"
    }

    # --- Discover the control catalog ---
    $catalogParams = @{
        IncludeControls = $IncludeControls
        ExcludeControls = $ExcludeControls
    }
    if ($Profile) { $catalogParams['Profile'] = $Profile }

    $catalog = Get-CISM365Controls @catalogParams
    if (-not $catalog) {
        Write-Warning "No controls selected or discovered. Nothing to audit."
        return @()
    }

    # --- Connect to required services unless -NoConnect ---
    if (-not $NoConnect) {
        $servicesNeeded = ($catalog.Services | Where-Object { $_ } | Select-Object -Unique)
        if ($servicesNeeded) {
            $connParams = @{
                Services       = $servicesNeeded
                TenantId       = $tenantId
                TenantDomain   = $tenantDomain
                Cloud          = $Cloud
                ErrorOnFailure = $true
                Verbose        = ($VerbosePreference -eq 'Continue')
            }
            if ($DeviceCode) { $connParams['DeviceCode'] = $true }
            $null = Connect-CISM365Services @connParams
        }
    }

    # --- Execute controls ---
    $results = foreach ($ctrl in $catalog) {
        Write-Verbose ("Evaluating control {0}: {1}" -f $ctrl.Id, $ctrl.Name)
        try {
            $status = & $ctrl.Audit
        } catch {
            $status = "ERROR: $($_.Exception.Message)"
            Write-Verbose ("Control {0} threw: {1}" -f $ctrl.Id, ($_ | Out-String))
        }
        [pscustomobject]@{
            Id          = $ctrl.Id
            Name        = $ctrl.Name
            Description = $ctrl.Description
            Rationale   = $ctrl.Rationale
            References  = $ctrl.References
            Profile     = $ctrl.Profile
            Automated   = $ctrl.Automated
            Status      = $status
        }
    }

    # --- Prepare summary counts ---
    $summary = [ordered]@{
        PASS        = ($results | Where-Object { $_.Status -like 'PASS*' }).Count
        FAIL        = ($results | Where-Object { $_.Status -like 'FAIL*' }).Count
        MANUAL      = ($results | Where-Object { $_.Status -like 'MANUAL*' }).Count
        ERROR       = ($results | Where-Object { $_.Status -like 'ERROR*' }).Count
        Total       = $results.Count
        Tenant      = $Tenant
        Cloud       = $Cloud
        GeneratedOn = (Get-Date)
    }

    # --- Write JSON output if requested ---
    if ($JsonOutputPath) {
        $jsonDir = Split-Path $JsonOutputPath -Parent
        if ($jsonDir -and -not (Test-Path $jsonDir)) {
            New-Item -ItemType Directory -Path $jsonDir -Force | Out-Null
        }
        [pscustomobject]@{ Summary = $summary; Results = $results } |
            ConvertTo-Json -Depth 10 |
            Set-Content $JsonOutputPath -Encoding UTF8
        Write-Verbose "JSON results written to: $JsonOutputPath"
    }

    # --- Write HTML output unless skipped ---
    if ($OutputPath) {
        $outDir = Split-Path $OutputPath -Parent
        if ($outDir -and -not (Test-Path $outDir)) {
            New-Item -ItemType Directory -Path $outDir -Force | Out-Null
        }
        New-CISM365HtmlReport -Tenant $Tenant -Results $results -Summary $summary |
            Set-Content $OutputPath -Encoding UTF8
        Write-Verbose "HTML report written to: $OutputPath"
    }

    return ,$results
}