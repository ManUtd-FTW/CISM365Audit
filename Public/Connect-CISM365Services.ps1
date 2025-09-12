function Connect-CISM365Services {
    [CmdletBinding()]
    param(
        [string[]] $Services,
        [string] $TenantId,
        [string] $TenantDomain,
        [string] $Tenant,
        [switch] $ErrorOnFailure
    )

    $canonical = @{
        'GRAPH'             = 'Graph'
        'MICROSOFTGRAPH'    = 'Graph'
        'EXCHANGEONLINE'    = 'ExchangeOnline'
        'EXO'               = 'ExchangeOnline'
    }

    function Handle-Failure {
        param($Message, $ErrRecord)
        $errText = if ($ErrRecord -and $ErrRecord.Exception) { $ErrRecord.Exception.Message } else { $ErrRecord.ToString() }
        if ($ErrorOnFailure) {
            throw [System.Exception]::new(("{0}: {1}" -f $Message, $errText))
        } else {
            Write-Warning ("{0}: {1}" -f $Message, $errText)
        }
    }

    function Ensure-Module {
        param(
            [string]$ModuleName,
            [string]$InstallName
        )
        if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
            Write-Host "$ModuleName module not found. Attempting to install..."
            try {
                Install-Module -Name $InstallName -Scope CurrentUser -Force -ErrorAction Stop
                Write-Host "Successfully installed $InstallName module."
            } catch {
                Handle-Failure "Connect-CISM365Services: Failed to install $InstallName module. Please install manually with: Install-Module -Name $InstallName -Scope CurrentUser" $_
                return $false
            }
        }
        return $true
    }

    $requested = $Services | ForEach-Object { ($_ -as [string]).Trim() } | Where-Object { $_ -ne '' } | Select-Object -Unique
    $mapped = @()
    foreach ($r in $requested) {
        $key = $r.ToUpperInvariant()
        if ($canonical.ContainsKey($key)) {
            $mapped += $canonical[$key]
        } else {
            Write-Verbose "Unknown or unsupported service '$r' requested; skipping."
        }
    }
    $mapped = $mapped | Select-Object -Unique

    Write-Host "Connecting to: $($mapped -join ', ')"

    foreach ($service in $mapped) {
        switch ($service) {
            "Graph" {
                try {
                    if (Ensure-Module -ModuleName "Microsoft.Graph" -InstallName "Microsoft.Graph") {
                        Import-Module Microsoft.Graph -ErrorAction Stop
                        Write-Host "Connecting to Microsoft Graph..."
                        if ($TenantId) {
                            Connect-MgGraph -TenantId $TenantId -Scopes "User.Read.All","Directory.Read.All" -ErrorAction Stop
                        } elseif ($TenantDomain) {
                            Connect-MgGraph -Tenant $TenantDomain -Scopes "User.Read.All","Directory.Read.All" -ErrorAction Stop
                        } elseif ($Tenant) {
                            Connect-MgGraph -Tenant $Tenant -Scopes "User.Read.All","Directory.Read.All" -ErrorAction Stop
                        } else {
                            Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All" -ErrorAction Stop
                        }
                        Write-Host "Connected to Microsoft Graph."
                    }
                } catch {
                    Handle-Failure "Connect-CISM365Services: Connect-MgGraph failed" $_
                }
            }
            "ExchangeOnline" {
                try {
                    if (Ensure-Module -ModuleName "ExchangeOnlineManagement" -InstallName "ExchangeOnlineManagement") {
                        Import-Module ExchangeOnlineManagement -ErrorAction Stop
                        Write-Host "Connecting to Exchange Online..."
                        if ($TenantId) {
                            Connect-ExchangeOnline -TenantId $TenantId -ShowBanner:$false -ErrorAction Stop
                        } elseif ($TenantDomain) {
                            Connect-ExchangeOnline -Organization $TenantDomain -ShowBanner:$false -ErrorAction Stop
                        } elseif ($Tenant) {
                            Connect-ExchangeOnline -Organization $Tenant -ShowBanner:$false -ErrorAction Stop
                        } else {
                            Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
                        }
                        Write-Host "Connected to Exchange Online."
                    }
                } catch {
                    Handle-Failure "Connect-CISM365Services: Connect-ExchangeOnline failed" $_
                }
            }
            default {
                Write-Verbose "No connector implemented for service: $service"
            }
        }
    }
}