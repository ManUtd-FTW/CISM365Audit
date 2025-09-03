function Connect-CISM365Services {
<#
.SYNOPSIS
Connects to Microsoft 365 admin services (Graph, Exchange Online, Teams, SharePoint Online, Compliance).

.DESCRIPTION
- Optionally installs required modules via PSResourceGet (Install-PSResource) unless -NoInstall is specified.
- Connects to selected services and returns a per-service status object (Connected/Details/Error).
- Honors your preference to prompt for the SharePoint admin short name when it cannot be inferred.
- Optional -ErrorOnFailure switch to fail fast if any requested connection fails.

.PARAMETER Services
One or more of: Graph, ExchangeOnline, Teams, SharePoint, Compliance. Default: all.

.PARAMETER TenantId
Azure AD tenant ID (GUID). Used by Graph/Teams if provided.

.PARAMETER TenantDomain
Primary domain (e.g., contoso.onmicrosoft.com). Used by Exchange Online (Organization) and to infer SPO short name.

.PARAMETER SharePointAdminShortName
Short name for SharePoint Admin Center URL (e.g., "contoso" => https://contoso-admin.sharepoint.com).

.PARAMETER Cloud
Microsoft cloud: Global, USGov, USGovHigh, USGovDoD, China. Default: Global.

.PARAMETER GraphScopes
Delegated scopes for Microsoft Graph. Defaults are read-only for auditing.

.PARAMETER DeviceCode
Use device-code/embedded browser where supported (Graph: -UseDeviceCode; EXO: approximated with -UseWebLogin).

.PARAMETER NoInstall
Skip PSResourceGet install checks (assumes modules are already available).

.PARAMETER ForceReauth
Disconnect targeted services first, then reconnect.

.PARAMETER Quiet
Suppresses Write-Host prompts (uses Write-Verbose instead).

.PARAMETER ErrorOnFailure
Throw a terminating error if any requested service fails to connect.

.OUTPUTS
PSCustomObject
A structured object with properties for each service (Graph/ExchangeOnline/Teams/SharePoint/Compliance).

.EXAMPLE
Connect-CISM365Services -Verbose

.EXAMPLE
Connect-CISM365Services -Services Graph,ExchangeOnline,SharePoint -TenantDomain contoso.onmicrosoft.com -Verbose

.EXAMPLE
Connect-CISM365Services -TenantId '00000000-0000-0000-0000-000000000000' -DeviceCode -Verbose
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [Parameter()]
    [ValidateSet('Graph','ExchangeOnline','Teams','SharePoint','Compliance')]
    [string[]]$Services = @('Graph','ExchangeOnline','Teams','SharePoint','Compliance'),

    [Parameter()] [string]$TenantId,
    [Parameter()] [string]$TenantDomain,
    [Parameter()] [string]$SharePointAdminShortName,

    [Parameter()]
    [ValidateSet('Global','USGov','USGovHigh','USGovDoD','China')]
    [string]$Cloud = 'Global',

    [Parameter()]
    [string[]]$GraphScopes = @(
        'Directory.Read.All',
        'AuditLog.Read.All',
        'Reports.Read.All',
        'Policy.Read.All',
        'RoleManagement.Read.Directory',
        'User.Read.All',
        'SecurityEvents.Read.All'
    ),

    [Parameter()] [switch]$DeviceCode,
    [Parameter()] [switch]$NoInstall,
    [Parameter()] [switch]$ForceReauth,
    [Parameter()] [switch]$Quiet,
    [Parameter()] [switch]$ErrorOnFailure
)

begin {
    # Collect connection results in memory; convert to PSCustomObject when returning.
    $result = [ordered]@{
        Graph          = [ordered]@{ Connected = $false; Details = $null; Error = $null }
        ExchangeOnline = [ordered]@{ Connected = $false; Details = $null; Error = $null }
        Teams          = [ordered]@{ Connected = $false; Details = $null; Error = $null }
        SharePoint     = [ordered]@{ Connected = $false; Details = $null; Error = $null }
        Compliance     = [ordered]@{ Connected = $false; Details = $null; Error = $null }
    }

    function Write-Info([string]$Message) {
        if (-not $Quiet) { Write-Host $Message -ForegroundColor Cyan }
    }

    function Ensure-Module {
        param(
            [Parameter(Mandatory)] [string]$Name,
            [string]$MinimumVersion
        )
        if (-not $NoInstall) {
            if (-not (Get-Command Install-PSResource -ErrorAction SilentlyContinue)) {
                throw "Install-PSResource (PSResourceGet) is not available. Install 'Microsoft.PowerShell.PSResourceGet' or use -NoInstall."
            }
            $installed = Get-Module -ListAvailable $Name | Sort-Object Version -Descending | Select-Object -First 1
            $needsInstall = $true
            if ($installed) {
                if ($MinimumVersion) {
                    if ($installed.Version -ge ([version]$MinimumVersion)) { $needsInstall = $false }
                } else { $needsInstall = $false }
            }
            if ($needsInstall) {
                Write-Verbose "Installing module $Name (min: $MinimumVersion)."
                try {
                    Install-PSResource -Name $Name -Scope CurrentUser -TrustRepository -Quiet -ErrorAction Stop
                } catch {
                    throw "Failed to install module ${Name}: $($_.Exception.Message)"
                }
            }
        } else {
            Write-Verbose "NoInstall set: skipping install check for $Name."
        }

        try {
            if ($MinimumVersion) {
                Import-Module $Name -MinimumVersion $MinimumVersion -ErrorAction Stop | Out-Null
            } else {
                Import-Module $Name -ErrorAction Stop | Out-Null
            }
            Write-Verbose "Imported module $Name."
        } catch {
            throw "Failed to import module ${Name}: $($_.Exception.Message)"
        }
    }

    function Infer-SPShortName {
        param([string]$TenantDomain)
        # If domain is *.onmicrosoft.com, return the leftmost label as short name (e.g., "contoso")
        if ($TenantDomain -and $TenantDomain -match '^[^.]+\.onmicrosoft\.com$') {
            return ($TenantDomain -split '\.')[0]
        }
        return $null
    }
}

process {
    if ($ForceReauth.IsPresent -and $PSCmdlet.ShouldProcess("All target services","Force re-auth (disconnect then connect)")) {
        try { Disconnect-CISM365Services -Services $Services -ErrorAction SilentlyContinue | Out-Null } catch { }
    }

    # --- Microsoft Graph ---
    if ($Services -contains 'Graph' -and $PSCmdlet.ShouldProcess("Microsoft Graph", "Connect")) {
        try {
            Ensure-Module -Name Microsoft.Graph -MinimumVersion '2.4.0'
            $graphParams = @{
                Scopes      = $GraphScopes
                ErrorAction = 'Stop'
            }
            if ($TenantId) { $graphParams['TenantId']       = $TenantId }
            if ($DeviceCode) { $graphParams['UseDeviceCode'] = $true }
            if ($Cloud -and $Cloud -ne 'Global') { $graphParams['Environment'] = $Cloud }

            Write-Verbose ("Connecting to Microsoft Graph with scopes: {0}" -f ($GraphScopes -join ', '))
            Connect-MgGraph @graphParams | Out-Null
            $ctx = Get-MgContext

            $result.Graph.Connected = $true
            $result.Graph.Details   = [ordered]@{
                Account  = $ctx.Account
                TenantId = $ctx.TenantId
                Scopes   = ($ctx.Scopes -join ', ')
                Cloud    = $Cloud
            }
        } catch {
            $result.Graph.Error = $_.Exception.Message
            Write-Verbose "Graph connection failed: $($result.Graph.Error)"
        }
    }

    # --- Exchange Online ---
    if ($Services -contains 'ExchangeOnline' -and $PSCmdlet.ShouldProcess("Exchange Online", "Connect")) {
        try {
            Ensure-Module -Name ExchangeOnlineManagement -MinimumVersion '3.2.0'
            $exoParams = @{
                ShowBanner      = $false
                ErrorAction     = 'Stop'
                TrackPerformance= $false
            }
            if ($TenantDomain) { $exoParams['Organization'] = $TenantDomain }
            if ($DeviceCode)   { $exoParams['UseWebLogin']  = $true } # best available approximation

            Write-Verbose "Connecting to Exchange Online…"
            Connect-ExchangeOnline @exoParams

            # Basic connection info
            $conn = $null; try { $conn = Get-ConnectionInformation -ErrorAction SilentlyContinue } catch {}
            $connectedAs = $null; if ($conn) { $connectedAs = $conn.UserPrincipalName }

            $result.ExchangeOnline.Connected = $true
            $result.ExchangeOnline.Details   = [ordered]@{
                Organization = $TenantDomain
                ConnectedAs  = $connectedAs
            }
        } catch {
            $result.ExchangeOnline.Error = $_.Exception.Message
            Write-Verbose "Exchange Online connection failed: $($result.ExchangeOnline.Error)"
        }
    }

    # --- Microsoft Teams ---
    if ($Services -contains 'Teams' -and $PSCmdlet.ShouldProcess("Microsoft Teams", "Connect")) {
        try {
            Ensure-Module -Name MicrosoftTeams -MinimumVersion '5.0.0'
            $teamsParams = @{ ErrorAction = 'Stop' }
            if ($TenantId)    { $teamsParams['TenantId']               = $TenantId }
            if ($DeviceCode)  { $teamsParams['UseDeviceAuthentication'] = $true }

            Write-Verbose "Connecting to Microsoft Teams…"
            $login = Connect-MicrosoftTeams @teamsParams

            $result.Teams.Connected = $true
            $result.Teams.Details   = [ordered]@{
                Account  = $login.Account
                TenantId = $login.TenantId
            }
        } catch {
            $result.Teams.Error = $_.Exception.Message
            Write-Verbose "Teams connection failed: $($result.Teams.Error)"
        }
    }

    # --- SharePoint Online (Admin) ---
    if ($Services -contains 'SharePoint' -and $PSCmdlet.ShouldProcess("SharePoint Online", "Connect")) {
        try {
            Ensure-Module -Name Microsoft.Online.SharePoint.PowerShell -MinimumVersion '16.0.24914.12000'

            if (-not $SharePointAdminShortName) {
                # Try to infer from contoso.onmicrosoft.com; otherwise prompt (per your preference)
                $inferred = Infer-SPShortName -TenantDomain $TenantDomain
                if ($inferred) {
                    $SharePointAdminShortName = $inferred
                } else {
                    $SharePointAdminShortName = Read-Host "Enter SharePoint Online tenant short name (e.g., contoso)"
                }
            }

            $spoUrl = "https://$SharePointAdminShortName-admin.sharepoint.com"
            Write-Verbose "Connecting to SharePoint Online Admin Center: $spoUrl"
            Connect-SPOService -Url $spoUrl -ErrorAction Stop

            $result.SharePoint.Connected = $true
            $result.SharePoint.Details   = [ordered]@{ AdminUrl = $spoUrl }
        } catch {
            $result.SharePoint.Error = $_.Exception.Message
            Write-Verbose "SharePoint Online connection failed: $($result.SharePoint.Error)"
        }
    }

    # --- Compliance (Security & Compliance / IPPSSession) ---
    if ($Services -contains 'Compliance' -and $PSCmdlet.ShouldProcess("Compliance (Security & Compliance)", "Connect")) {
        try {
            # Uses ExchangeOnlineManagement module
            Ensure-Module -Name ExchangeOnlineManagement -MinimumVersion '3.2.0'

            # Avoid creating duplicate IPPSSession if one already exists
            $existingIPP = $null
            try {
                $existingIPP = Get-PSSession | Where-Object {
                    $_.ConfigurationName -eq 'Microsoft.Exchange' -and
                    $_.ComputerName -like '*.compliance.protection.outlook.com*'
                }
            } catch {}

            if ($existingIPP) {
                Write-Verbose "An IPPSSession already exists; reusing."
            } else {
                Write-Verbose "Connecting to Compliance (Connect-IPPSSession)…"
                Connect-IPPSSession -ErrorAction Stop | Out-Null
            }

            $result.Compliance.Connected = $true
            $result.Compliance.Details   = [ordered]@{ Session = 'IPPSSession' }
        } catch {
            $result.Compliance.Error = $_.Exception.Message
            Write-Verbose "Compliance connection failed: $($result.Compliance.Error)"
        }
    }

    # Optional strict behavior: fail if any of the requested services failed to connect
    if ($ErrorOnFailure) {
    $failed = foreach ($svc in $Services) {
        if (-not $result[$svc].Connected) { "${svc}: $($result[$svc].Error)" }
    }
    if ($failed) {
        throw "One or more connections failed: $(($failed -join '; '))"
    }
}


    return [PSCustomObject]$result
}
}
