function Connect-CISM365Services {
    [CmdletBinding()]
    param(
        # What to connect (defaults: Graph+EXO for current controls)
        [switch] $Graph,
        [switch] $ExchangeOnline,
        [switch] $Teams,
        [switch] $SharePointOnline,
        [switch] $SecurityCompliance,
        [switch] $All,

        # Tenant & auth
        [string]  $TenantId,                # e.g., GUID or contoso.onmicrosoft.com (Graph accepts both)
        [string]  $Organization,            # e.g., contoso.onmicrosoft.com (EXO/Teams)
        [string]  $SPOAdminUrl,             # e.g., https://contoso-admin.sharepoint.com
        [string]  $UserPrincipalName,       # e.g., admin@contoso.onmicrosoft.com

        # Graph scopes (delegated)
        [string[]] $GraphScopes = @('Directory.Read.All'),

        # Auth style
        [switch]  $UseDeviceCode,
        [switch]  $AppOnly,
        [string]  $ClientId,
        [string]  $CertificateThumbprint,

        # Optional creds (SPO / IPPS user flows if you want non-interactive)
        [System.Management.Automation.PSCredential] $Credential
    )

    # Default selection: Graph + EXO unless user specified services or -All
    if (-not ($Graph -or $ExchangeOnline -or $Teams -or $SharePointOnline -or $SecurityCompliance -or $All)) {
        $Graph = $true; $ExchangeOnline = $true
    }
    if ($All) {
        $Graph = $true; $ExchangeOnline = $true; $Teams = $true; $SharePointOnline = $true; $SecurityCompliance = $true
    }

    $summary = [ordered]@{
        Graph              = 'Skipped'
        ExchangeOnline     = 'Skipped'
        Teams              = 'Skipped'
        SharePointOnline   = 'Skipped'
        SecurityCompliance = 'Skipped'
    }

    # --- Helpers ---------------------------------------------------------------
    function Test-GraphConnected {
        try {
            $ctx = Get-MgContext -ErrorAction Stop
            if (-not $ctx -or $ctx.AuthType -eq 'None') { return $false }

            if ($AppOnly) {
                # Ensure we actually have an app-only context, not delegated
                if ($ctx.AuthType -ne 'AppOnly') { return $false }
                # Optional: if TenantId provided and context exposes TenantId, ensure match
                if ($TenantId -and $ctx.TenantId -and ($ctx.TenantId -ne $TenantId)) { return $false }
                return $true
            }

            # Delegated: ensure all required scopes are present
            if (-not $ctx.Scopes) { return $false }
            if (@($GraphScopes | Where-Object { $_ -notin $ctx.Scopes }).Count -gt 0) { return $false }

            # Optional tenant check if available
            if ($TenantId -and $ctx.TenantId -and ($ctx.TenantId -ne $TenantId)) { return $false }

            return $true
        } catch { return $false }
    }

    function Ensure-Module {
        param([string]$Command, [string]$InstallHint)
        if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
            throw "$InstallHint"
        }
    }

    function Ensure-Org {
        param([string]$Org)
        if (-not $Org) {
            throw "An -Organization (e.g., contoso.onmicrosoft.com) is required to connect to this service."
        }
    }

    function Ensure-SPOAdminUrl {
        param([string]$Org, [string]$AdminUrl)
        if ($AdminUrl) { return $AdminUrl }
        # Derive https://<firstlabel>-admin.sharepoint.com from Org (works for both onmicrosoft.com and custom domains)
        $name = $Org.Split('.')[0]
        if (-not $name) { throw "Unable to derive -SPOAdminUrl from -Organization. Provide -SPOAdminUrl explicitly." }
        return "https://$name-admin.sharepoint.com"
    }

    # --- Graph / Entra ---------------------------------------------------------
    if ($Graph) {
        Ensure-Module -Command 'Connect-MgGraph' -InstallHint "Microsoft.Graph is not available. Install it: Install-Module Microsoft.Graph -Scope CurrentUser"
        if (Test-GraphConnected) {
            Write-Verbose "Graph already connected with required context."
            $summary.Graph = 'AlreadyConnected'
        } else {
            try {
                if ($AppOnly) {
                    if (-not $ClientId -or -not $CertificateThumbprint -or -not $TenantId) {
                        throw "App-only Graph requires -ClientId, -TenantId, and -CertificateThumbprint."
                    }
                    Connect-MgGraph -ClientId $ClientId `
                                    -TenantId $TenantId `
                                    -CertificateThumbprint $CertificateThumbprint `
                                    -NoWelcome -ErrorAction Stop | Out-Null
                } else {
                    $g = @{ Scopes = $GraphScopes; NoWelcome = $true; ErrorAction = 'Stop' }
                    if ($TenantId)     { $g.TenantId      = $TenantId }
                    if ($UseDeviceCode){ $g.UseDeviceCode = $true }
                    Connect-MgGraph @g | Out-Null
                }
                $summary.Graph = 'Connected'
            } catch {
                throw "Failed to connect to Microsoft Graph (Entra). $($_.Exception.Message)"
            }
        }
    }

    # --- Exchange Online -------------------------------------------------------
    if ($ExchangeOnline) {
        Ensure-Module -Command 'Connect-ExchangeOnline' -InstallHint "ExchangeOnlineManagement is not available. Install it: Install-Module ExchangeOnlineManagement -Scope CurrentUser"
        $needConnect = $true
        try {
            $ci = Get-ConnectionInformation -ErrorAction SilentlyContinue
            if ($ci -and $ci.State -eq 'Connected') {
                # Validate same tenant and session liveness
                if ($Organization -and $ci.Organization -and ($ci.Organization -eq $Organization)) {
                    try {
                        $null = Get-OrganizationConfig -ErrorAction Stop
                        $needConnect = $false
                    } catch {
                        $needConnect = $true
                    }
                }
            }
        } catch { $needConnect = $true }

        if (-not $needConnect) {
            Write-Verbose "Exchange Online already connected."
            $summary.ExchangeOnline = 'AlreadyConnected'
        } else {
            Ensure-Org -Org $Organization
            try {
                if ($AppOnly) {
                    if (-not $ClientId -or -not $CertificateThumbprint) {
                        throw "App-only EXO requires -ClientId and -CertificateThumbprint (and -Organization)."
                    }
                    Connect-ExchangeOnline -AppId $ClientId `
                                           -CertificateThumbprint $CertificateThumbprint `
                                           -Organization $Organization `
                                           -ShowBanner:$false -ErrorAction Stop | Out-Null
                } else {
                    Connect-ExchangeOnline -Organization $Organization -ShowBanner:$false -ErrorAction Stop | Out-Null
                }
                $summary.ExchangeOnline = 'Connected'
            } catch {
                throw "Failed to connect to Exchange Online. $($_.Exception.Message)"
            }
        }
    }

    # --- Microsoft Teams (optional) -------------------------------------------
    if ($Teams) {
        Ensure-Module -Command 'Connect-MicrosoftTeams' -InstallHint "MicrosoftTeams is not available. Install it: Install-Module MicrosoftTeams -Scope CurrentUser"
        $teamsConnected = $false
        try {
            # Probe after potential prior connection
            $null = Get-CsTenant -ErrorAction Stop
            $teamsConnected = $true
        } catch {
            $teamsConnected = $false
        }

        if ($teamsConnected) {
            $summary.Teams = 'AlreadyConnected'
        } else {
            # Note: -AccountId expects UPN, not tenant domain.
            try {
                if ($UseDeviceCode) {
                    if ($TenantId) {
                        if ($UserPrincipalName) {
                            Connect-MicrosoftTeams -TenantId $TenantId -AccountId $UserPrincipalName -UseDeviceAuthentication -ErrorAction Stop | Out-Null
                        } else {
                            Connect-MicrosoftTeams -TenantId $TenantId -UseDeviceAuthentication -ErrorAction Stop | Out-Null
                        }
                    } else {
                        if ($UserPrincipalName) {
                            Connect-MicrosoftTeams -AccountId $UserPrincipalName -UseDeviceAuthentication -ErrorAction Stop | Out-Null
                        } else {
                            Connect-MicrosoftTeams -UseDeviceAuthentication -ErrorAction Stop | Out-Null
                        }
                    }
                } else {
                    if ($TenantId) {
                        if ($UserPrincipalName) {
                            Connect-MicrosoftTeams -TenantId $TenantId -AccountId $UserPrincipalName -ErrorAction Stop | Out-Null
                        } else {
                            Connect-MicrosoftTeams -TenantId $TenantId -ErrorAction Stop | Out-Null
                        }
                    } else {
                        if ($UserPrincipalName) {
                            Connect-MicrosoftTeams -AccountId $UserPrincipalName -ErrorAction Stop | Out-Null
                        } else {
                            Connect-MicrosoftTeams -ErrorAction Stop | Out-Null
                        }
                    }
                }
                $summary.Teams = 'Connected'
            } catch {
                throw "Failed to connect to Microsoft Teams. $($_.Exception.Message)"
            }
        }
    }

    # --- SharePoint Online Admin (optional) -----------------------------------
    if ($SharePointOnline) {
        Ensure-Module -Command 'Connect-SPOService' -InstallHint "Microsoft.Online.SharePoint.PowerShell is not available. Install it: Install-Module Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser"
        $spoConnected = $false
        try {
            $null = Get-SPOTenant -ErrorAction Stop
            $spoConnected = $true
        } catch { $spoConnected = $false }

        if ($spoConnected) {
            $summary.SharePointOnline = 'AlreadyConnected'
        } else {
            Ensure-Org -Org $Organization
            $adminUrl = Ensure-SPOAdminUrl -Org $Organization -AdminUrl $SPOAdminUrl
            try {
                if ($Credential) {
                    Connect-SPOService -Url $adminUrl -Credential $Credential -ErrorAction Stop
                } else {
                    Connect-SPOService -Url $adminUrl -ErrorAction Stop
                }
                $summary.SharePointOnline = 'Connected'
            } catch {
                throw "Failed to connect to SharePoint Online Admin ($adminUrl). $($_.Exception.Message)"
            }
        }
    }

    # --- Security & Compliance / Purview (optional) ---------------------------
    if ($SecurityCompliance) {
        Ensure-Module -Command 'Connect-IPPSSession' -InstallHint "ExchangeOnlineManagement (for IPPSSession) is not available. Install it: Install-Module ExchangeOnlineManagement -Scope CurrentUser"

        $sccConnected = $false
        try {
            # If already connected, a simple cmdlet will work
            $null = Get-DlpCompliancePolicy -ErrorAction Stop
            $sccConnected = $true
        } catch { $sccConnected = $false }

        if ($sccConnected) {
            $summary.SecurityCompliance = 'AlreadyConnected'
        } else {
            try {
                if ($AppOnly) {
                    if (-not $ClientId -or -not $CertificateThumbprint -or -not $Organization) {
                        throw "App-only IPPSSession requires -ClientId, -CertificateThumbprint, and -Organization."
                    }
                    Connect-IPPSSession -AppId $ClientId -CertificateThumbprint $CertificateThumbprint -Organization $Organization -ErrorAction Stop | Out-Null
                } else {
                    if ($Credential) {
                        Connect-IPPSSession -UserPrincipalName ($UserPrincipalName ? $UserPrincipalName : $Credential.UserName) -Credential $Credential -ErrorAction Stop | Out-Null
                    } elseif ($UserPrincipalName) {
                        Connect-IPPSSession -UserPrincipalName $UserPrincipalName -ErrorAction Stop | Out-Null
                    } else {
                        # Fully interactive prompt if UPN not provided
                        Connect-IPPSSession -ErrorAction Stop | Out-Null
                    }
                }
                $summary.SecurityCompliance = 'Connected'
            } catch {
                throw "Failed to connect to Security & Compliance. $($_.Exception.Message)"
            }
        }
    }

    [pscustomobject]$summary
}
