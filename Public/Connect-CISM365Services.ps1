function Connect-CISM365Services {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter()]
        [ValidateSet('Graph','ExchangeOnline')]
        [string[]] $Services = @('Graph','ExchangeOnline'),

        [Parameter()] [string] $TenantId,
        [Parameter()] [string] $TenantDomain,

        [Parameter()]
        [string[]] $GraphScopes = @(
            'Directory.Read.All',
            'Reports.Read.All',
            'RoleManagement.Read.Directory',
            'User.Read.All'
        ),

        [Parameter()] [switch] $DeviceCode,
        [Parameter()] [switch] $NoInstall,
        [Parameter()] [switch] $ForceReauth,
        [Parameter()] [switch] $ErrorOnFailure
    )

    begin {
        $result = [ordered]@{
            Graph          = [ordered]@{ Connected = $false; Details = $null; Error = $null }
            ExchangeOnline = [ordered]@{ Connected = $false; Details = $null; Error = $null }
        }

        function Ensure-Module {
            param(
                [Parameter(Mandatory)][string]$Name,
                [string]$MinimumVersion
            )
        
            # Try import first
            try {
                if ($MinimumVersion) {
                    Import-Module -Name $Name -MinimumVersion $MinimumVersion -ErrorAction Stop | Out-Null
                } else {
                    Import-Module -Name $Name -ErrorAction Stop | Out-Null
                }
                Write-Verbose ("Imported module {0}." -f $Name)
                return
            }
            catch {
                if ($NoInstall) {
                    throw ("Module {0} not available and -NoInstall set." -f $Name)
                }
        
                Write-Verbose ("Module {0} not present; attempting user-scope install." -f $Name)
        
                # Prefer Install-Module (PowerShellGet) with CurrentUser scope
                if (Get-Command -Name Install-Module -ErrorAction SilentlyContinue) {
                    try {
                        Install-Module -Name $Name -Scope CurrentUser -Force -ErrorAction Stop
                        Import-Module -Name $Name -ErrorAction Stop | Out-Null
                        Write-Verbose ("Installed and imported {0} via Install-Module (CurrentUser)." -f $Name)
                        return
                    }
                    catch {
                        Write-Verbose ("Install-Module (CurrentUser) failed for {0}: {1}" -f $Name, $_.Exception.Message)
                    }
                }
        
                # Try PSResource install with CurrentUser scope if available
                if (Get-Command -Name Install-PSResource -ErrorAction SilentlyContinue) {
                    try {
                        Install-PSResource -Name $Name -Scope CurrentUser -TrustRepository -Quiet -ErrorAction Stop
                        Import-Module -Name $Name -ErrorAction Stop | Out-Null
                        Write-Verbose ("Installed and imported {0} via Install-PSResource (CurrentUser)." -f $Name)
                        return
                    }
                    catch {
                        Write-Verbose ("Install-PSResource (CurrentUser) failed for {0}: {1}" -f $Name, $_.Exception.Message)
                    }
                }
        
                # Fallback for Microsoft.Graph submodules: try installing meta-module in user scope
                if ($Name -like 'Microsoft.Graph*') {
                    try {
                        Write-Verbose "Falling back to installing 'Microsoft.Graph' meta-module (CurrentUser)."
                        if (Get-Command -Name Install-Module -ErrorAction SilentlyContinue) {
                            Install-Module -Name 'Microsoft.Graph' -Scope CurrentUser -Force -ErrorAction Stop
                            Import-Module -Name 'Microsoft.Graph' -ErrorAction Stop | Out-Null
                            Write-Verbose "Installed and imported 'Microsoft.Graph' meta-module via Install-Module (CurrentUser)."
                            return
                        }
                        if (Get-Command -Name Install-PSResource -ErrorAction SilentlyContinue) {
                            Install-PSResource -Name 'Microsoft.Graph' -Scope CurrentUser -TrustRepository -Quiet -ErrorAction Stop
                            Import-Module -Name 'Microsoft.Graph' -ErrorAction Stop | Out-Null
                            Write-Verbose "Installed and imported 'Microsoft.Graph' meta-module via Install-PSResource (CurrentUser)."
                            return
                        }
                        throw "No supported installer available to install Microsoft.Graph into CurrentUser scope."
                    }
                    catch {
                        throw ("Failed to install/import {0} or fallback Microsoft.Graph into CurrentUser scope: {1}" -f $Name, $_.Exception.Message)
                    }
                }
        
                # Final failure path with actionable guidance
                throw ("Failed to install/import {0}: {1}. To fix, either run PowerShell as Administrator to allow system installs, pre-install the module, or rerun with -NoInstall and ensure the required modules are available." -f $Name, $_.Exception.Message)
            }
        }

        # Minimal Microsoft Graph submodules used by controls
        $minimalGraphModules = @(
            'Microsoft.Graph.Authentication',
            'Microsoft.Graph.DirectoryRoles',
            'Microsoft.Graph.Identity.SignIns',
            'Microsoft.Graph.Reports'
        )
    }

    process {
        if ($ForceReauth) {
            try { Disconnect-CISM365Services -Services $Services -ErrorAction SilentlyContinue } catch {}
        }

        # GRAPH
        if ($Services -contains 'Graph') {
            try {
                foreach ($m in $minimalGraphModules) { Ensure-Module -Name $m }

                $connectArgs = @{ ErrorAction = 'Stop'; Scopes = $GraphScopes }
                if ($TenantId)   { $connectArgs['TenantId'] = $TenantId }
                if ($DeviceCode) { $connectArgs['UseDeviceCode'] = $true }

                Write-Verbose ("Connecting to Microsoft Graph (Global) with scopes: {0}" -f ($GraphScopes -join ', '))
                Connect-MgGraph @connectArgs | Out-Null

                $ctx = $null
                try { $ctx = Get-MgContext -ErrorAction Stop } catch { $ctx = $null }

                if (-not $ctx) {
                    $result.Graph.Error = 'Get-MgContext returned $null; Graph connection may not have completed.'
                    Write-Warning $result.Graph.Error
                } else {
                    $result.Graph.Connected = $true
                    $result.Graph.Details = [ordered]@{
                        Account  = $ctx.Account
                        TenantId = $ctx.TenantId
                        Scopes   = ($ctx.Scopes -join ', ')
                        Cloud    = 'Global'
                    }
                }
            }
            catch {
                $result.Graph.Error = ($_ | Out-String).Trim()
                Write-Warning ("Graph connection failed: {0}" -f $result.Graph.Error)
            }
        }

        # EXCHANGE ONLINE
        if ($Services -contains 'ExchangeOnline') {
            try {
                Ensure-Module -Name 'ExchangeOnlineManagement'
                $exoArgs = @{ ShowBanner = $false ; ErrorAction = 'Stop' }
                if ($TenantDomain) { $exoArgs['Organization'] = $TenantDomain }
                if ($DeviceCode)   { $exoArgs['UseWebLogin'] = $true }

                Write-Verbose "Connecting to Exchange Online (Global)..."
                Connect-ExchangeOnline @exoArgs

                $conn = $null
                try { $conn = Get-ConnectionInformation -ErrorAction SilentlyContinue } catch {}
                $connectedAs = if ($conn) { $conn.UserPrincipalName } else { $null }

                $result.ExchangeOnline.Connected = $true
                $result.ExchangeOnline.Details = [ordered]@{
                    Organization = $TenantDomain
                    ConnectedAs  = $connectedAs
                }
            }
            catch {
                $result.ExchangeOnline.Error = ($_ | Out-String).Trim()
                Write-Warning ("Exchange Online connection failed: {0}" -f $result.ExchangeOnline.Error)
            }
        }

        # Fail-fast if requested
        if ($ErrorOnFailure) {
            $failed = @()
            foreach ($svc in $Services) {
                if (-not $result[$svc].Connected) {
                    $failed += ("{0}: {1}" -f $svc, ($result[$svc].Error -ne $null ? $result[$svc].Error : 'Unknown error'))
                }
            }
            if ($failed.Count -gt 0) {
                throw ("One or more connections failed: {0}" -f ($failed -join '; '))
            }
        }

        return [PSCustomObject]$result
    }
}