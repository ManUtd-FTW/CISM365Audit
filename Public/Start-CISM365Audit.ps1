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
    if (-not $catalog -or $catalog.Count -eq 0) {
        Write-Warning "No controls selected or discovered. Nothing to audit."
        return @()
    }

    # --- Sort the catalog by control Id in ascending, numeric-aware order ---
    # This pads each numeric segment of the Id so "1.2.10" sorts after "1.2.2".
    $catalog = $catalog | Sort-Object -Property @{
        Expression = {
            try {
                if (-not $_.Id) { return '' }
                ($_.Id -split '[^0-9]+' | Where-Object { $_ -ne '' } |
                    ForEach-Object { [int]$_ } |
                    ForEach-Object { $_.ToString('D4') }) -join '.'
            } catch {
                # Fallback to raw Id if anything unexpected appears
                $_.Id
            }
        }
    }
    Write-Verbose ("Sorted {0} controls by Id for deterministic reporting." -f $catalog.Count)

    # --- Connect to required services unless -NoConnect ---
    if (-not $NoConnect) {
        # Aggregate requested services from the catalog (flatten and dedupe)
        $servicesNeeded = $catalog |
            ForEach-Object { if ($_.Services) { $_.Services } } |
            Where-Object { $_ } |
            ForEach-Object { ($_ -as [string]).Trim() } |
            Select-Object -Unique

        if ($servicesNeeded -and $servicesNeeded.Count -gt 0) {
            # Build connection parameters compatible with Connect-CISM365Services
            $connParams = @{
                Services     = $servicesNeeded
                ErrorOnFailure = $true
            }
            if ($tenantId)     { $connParams['TenantId']   = $tenantId }
            if ($tenantDomain) { $connParams['TenantDomain'] = $tenantDomain }

            # Note: Connect-CISM365Services currently accepts Tenant/TenantId/TenantDomain/Credential/ErrorOnFailure.
            # We do not pass DeviceCode unless Connect-CISM365Services exposes that parameter.
            Write-Verbose ("Start-CISM365Audit: Ensuring sessions for services: {0}" -f ($servicesNeeded -join ', '))
            $null = Connect-CISM365Services @connParams
        } else {
            Write-Verbose "Start-CISM365Audit: No services required by selected controls."
        }
    } else {
        Write-Verbose "Start-CISM365Audit: Skipping service connection per -NoConnect."
    }

    # --- Execute controls ---
    $results = foreach ($ctrl in $catalog) {
        Write-Verbose ("Evaluating control {0}: {1}" -f $ctrl.Id, $ctrl.Name)
        try {
            # Controls provide an Audit scriptblock. If Audit is not a ScriptBlock, treat as MANUAL descriptor.
            if ($null -eq $ctrl.Audit) {
                $raw = [PSCustomObject]@{
                    Status = 'MANUAL'
                    Findings = 'No Audit scriptblock provided.'
                }
            } elseif ($ctrl.Audit -is [scriptblock]) {
                $raw = & $ctrl.Audit
            } else {
                $raw = $ctrl.Audit
            }
        } catch {
            Write-Warning ("Control {0} threw during Audit invocation: {1}" -f $ctrl.Id, $_.Exception.Message)
            $raw = [PSCustomObject]@{
                Status = 'ERROR'
                Findings = "Control audit threw an exception: $($_.Exception.Message)"
            }
        }

        # Normalize raw result into predictable fields (Status as string, Findings, Remediation, References)
        $statusText = $null
        $findings = $null
        $remediation = $null
        $references = $null

        if ($null -eq $raw) {
            $statusText = 'ERROR'
            $findings = 'Audit returned no result.'
        } elseif ($raw -is [string]) {
            $statusText = $raw
        } elseif ($raw -is [hashtable] -or $raw -is [PSCustomObject]) {
            # Accept both hashtable and PSCustomObject
            $statusText = ($raw.Status -as [string])
            $findings    = if ($raw.PSObject.Properties.Match('Findings')) { $raw.Findings } else { $raw['Findings'] }
            $remediation = if ($raw.PSObject.Properties.Match('Remediation')) { $raw.Remediation } else { $raw['Remediation'] }
            $references  = if ($raw.PSObject.Properties.Match('References')) { $raw.References } else { $raw['References'] }
        } else {
            # Unknown type — convert to string
            $statusText = ($raw | Out-String).Trim()
        }

        # Ensure Status is uppercase brief token where possible (preserve trailing message)
        if ($statusText) {
            $statusText = ($statusText -as [string]).Trim()
        } else {
            $statusText = 'ERROR'
        }

        [pscustomobject]@{
            Id          = $ctrl.Id
            Name        = $ctrl.Name
            Description = $ctrl.Description
            Rationale   = $ctrl.Rationale
            References  = $ctrl.References
            Profile     = $ctrl.Profile
            Automated   = $ctrl.Automated
            Status      = $statusText
            Findings    = $findings
            Remediation = $remediation
            RawResult   = $raw
        }
    }

    # --- Prepare summary counts ---
    $summary = [ordered]@{
        PASS        = ($results | Where-Object { $_.Status -match '^(?i:PASS)' }).Count
        FAIL        = ($results | Where-Object { $_.Status -match '^(?i:FAIL)' }).Count
        MANUAL      = ($results | Where-Object { $_.Status -match '^(?i:MANUAL)' }).Count
        ERROR       = ($results | Where-Object { $_.Status -match '^(?i:ERROR)' }).Count
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

    return $results
}