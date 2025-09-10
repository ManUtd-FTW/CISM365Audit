function Connect-CISM365Services {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string[]] $Services = @(),

        # Accept common splatted parameters so callers that use @connParams do not cause a parameter-binding error.
        [Parameter(Mandatory=$false)]
        [string] $Tenant,

        [Parameter(Mandatory=$false)]
        [string] $TenantId,

        [Parameter(Mandatory=$false)]
        [string] $TenantDomain,

        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential] $Credential,

        # Some callers pass ErrorOnFailure in their splat; accept it so parameter binding doesn't fail.
        [Parameter(Mandatory=$false)]
        [switch] $ErrorOnFailure
    )

    # Keep behaviour minimal and lean:
    # - Map a loose set of service identifiers to canonical names
    # - If 'Graph' is requested, attempt Connect-MgGraph (interactive) only if cmdlets exist and no context is present
    # - If 'ExchangeOnline' is requested, attempt Connect-ExchangeOnline (interactive) only if module exists and no session is present
    # - For other services, do not attempt automatic connection; emit verbose guidance
    # - Do not throw unless ErrorOnFailure is set; otherwise warn and continue

    $canonical = @{
        'GRAPH'             = 'Graph'
        'MICROSOFTGRAPH'    = 'Graph'
        'EXCHANGEONLINE'    = 'ExchangeOnline'
        'EXO'               = 'ExchangeOnline'
        'ADMIN'             = 'AdminCenter'
        'ADMINCENTER'       = 'AdminCenter'
        'CONDITIONALACCESS' = 'ConditionalAccess'
        'CONDITIONAL'       = 'ConditionalAccess'
        'SHAREPOINT'        = 'SharePoint'
        'TEAMS'             = 'Teams'
        'COMPLIANCE'        = 'Compliance'
    }

    if (-not $Services -or $Services.Count -eq 0) {
        Write-Verbose "Connect-CISM365Services: No services requested; nothing to do."
        return $null
    }

    $requested = $Services | ForEach-Object { ($_ -as [string]).Trim() } | Where-Object { $_ -ne '' } | Select-Object -Unique
    $mapped = @()

    foreach ($r in $requested) {
        $key = $r.ToUpperInvariant()
        if ($canonical.ContainsKey($key)) {
            $mapped += $canonical[$key]
        } else {
            $found = $canonical.Keys | Where-Object { $_ -like "*$key*" -or $key -like "*$_*" }
            if ($found -and $found.Count -gt 0) {
                $mapped += $canonical[$found[0]]
            } else {
                Write-Verbose "Connect-CISM365Services: Unknown service '$r' requested; it will be treated as manual. Ensure a session is present for this service."
            }
        }
    }

    $mapped = $mapped | Select-Object -Unique

    if ($mapped.Count -eq 0) {
        Write-Verbose "Connect-CISM365Services: No supported services to connect after mapping; exiting."
        return $null
    }

    Write-Verbose ("Connect-CISM365Services: Services to ensure connection for: {0}" -f ($mapped -join ', '))
    if ($Tenant) { Write-Verbose ("Connect-CISM365Services: Tenant (splat) provided: {0}" -f $Tenant) }
    if ($TenantId) { Write-Verbose ("Connect-CISM365Services: TenantId (splat) provided: {0}" -f $TenantId) }
    if ($TenantDomain) { Write-Verbose ("Connect-CISM365Services: TenantDomain (splat) provided: {0}" -f $TenantDomain) }
    if ($PSBoundParameters.ContainsKey('ErrorOnFailure') -and $ErrorOnFailure) { Write-Verbose "Connect-CISM365Services: ErrorOnFailure is set; failures will be thrown." }

    # Helper: failure handling
    function Handle-Failure {
        param($Message, $ErrRecord)
        $errText = if ($ErrRecord -and $ErrRecord.Exception) { $ErrRecord.Exception.Message } else { $ErrRecord.ToString() }
        if ($PSBoundParameters.ContainsKey('ErrorOnFailure') -and $ErrorOnFailure) {
            throw [System.Exception]::new(("{0}: {1}" -f $Message, $errText))
        } else {
            Write-Warning ("{0}: {1}" -f $Message, $errText)
        }
    }

    # Auto-connect Graph when requested and possible
    if ($mapped -contains 'Graph') {
        try {
            if (-not (Get-Command -Name Get-MgContext -ErrorAction SilentlyContinue)) {
                Write-Verbose "Connect-CISM365Services: Microsoft.Graph SDK cmdlets not available; skipping Graph auto-connect."
            } else {
                $ctx = Get-MgContext -ErrorAction SilentlyContinue
                if (-not $ctx) {
                    Write-Verbose "Connect-CISM365Services: No active Microsoft Graph context detected. Attempting Connect-MgGraph (interactive)."
                    try {
                        if ($PSBoundParameters.ContainsKey('Credential')) {
                            Connect-MgGraph -Credential $Credential -ErrorAction Stop
                        } elseif ($PSBoundParameters.ContainsKey('TenantId')) {
                            Connect-MgGraph -TenantId $TenantId -ErrorAction Stop
                        } elseif ($PSBoundParameters.ContainsKey('TenantDomain')) {
                            Connect-MgGraph -Tenant $TenantDomain -ErrorAction Stop
                        } elseif ($PSBoundParameters.ContainsKey('Tenant')) {
                            Connect-MgGraph -Tenant $Tenant -ErrorAction Stop
                        } else {
                            Connect-MgGraph -ErrorAction Stop
                        }
                        Write-Verbose "Connect-CISM365Services: Connect-MgGraph succeeded."
                    } catch {
                        Handle-Failure "Connect-CISM365Services: Connect-MgGraph failed or was cancelled" $_
                    }
                } else {
                    Write-Verbose "Connect-CISM365Services: Existing Microsoft Graph context detected."
                }
            }
        } catch {
            Handle-Failure "Connect-CISM365Services: Unexpected error when checking/connecting Graph" $_
        }
    }

    # Auto-connect ExchangeOnline when requested and possible
    if ($mapped -contains 'ExchangeOnline') {
        try {
            if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
                Write-Verbose "Connect-CISM365Services: ExchangeOnlineManagement module not available; skipping ExchangeOnline auto-connect."
            } else {
                $exoSession = Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
                    ($_.ConfigurationName -and ($_.ConfigurationName -match 'Microsoft.Exchange')) -or
                    ($_.ConnectionUri -and ($_.ConnectionUri -match 'exchange'))
                }
                if (-not $exoSession) {
                    Write-Verbose "Connect-CISM365Services: No active Exchange Online session detected. Attempting Connect-ExchangeOnline (interactive)."
                    try {
                        if ($PSBoundParameters.ContainsKey('Credential')) {
                            Connect-ExchangeOnline -Credential $Credential -ShowBanner:$false -ErrorAction Stop
                        } elseif ($PSBoundParameters.ContainsKey('TenantId')) {
                            Connect-ExchangeOnline -TenantId $TenantId -ShowBanner:$false -ErrorAction Stop
                        } elseif ($PSBoundParameters.ContainsKey('TenantDomain')) {
                            Connect-ExchangeOnline -Organization $TenantDomain -ShowBanner:$false -ErrorAction Stop
                        } elseif ($PSBoundParameters.ContainsKey('Tenant')) {
                            Connect-ExchangeOnline -Organization $Tenant -ShowBanner:$false -ErrorAction Stop
                        } else {
                            Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
                        }
                        Write-Verbose "Connect-CISM365Services: Connect-ExchangeOnline succeeded."
                    } catch {
                        Handle-Failure "Connect-CISM365Services: Connect-ExchangeOnline failed or was cancelled" $_
                    }
                } else {
                    Write-Verbose "Connect-CISM365Services: Existing Exchange Online session detected."
                }
            }
        } catch {
            Handle-Failure "Connect-CISM365Services: Unexpected error when checking/connecting ExchangeOnline" $_
        }
    }

    # Other services: instruct operator (lean approach; avoid adding more auto-connect complexity)
    $others = $mapped | Where-Object { $_ -notin @('Graph','ExchangeOnline') }
    foreach ($svc in $others) {
        Write-Verbose "Connect-CISM365Services: Automatic connection for '$svc' is not implemented. Ensure an active session exists for this service before running automated checks."
    }

    return $null
}