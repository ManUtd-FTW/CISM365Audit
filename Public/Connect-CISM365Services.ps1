function Connect-CISM365Services {
    [CmdletBinding()]
    param(
        [switch] $SkipGraph,
        [switch] $SkipExchangeOnline
    )

    if (-not $SkipGraph) {
        try {
            if (-not (Get-Module Microsoft.Graph -ListAvailable)) {
                Write-Warning "Microsoft.Graph not found. Install it: Install-Module Microsoft.Graph -Scope CurrentUser"
            }
            $scopes = @(
                'Directory.Read.All' # for Global Admin membership
            )
            Connect-MgGraph -Scopes $scopes -NoWelcome -ErrorAction Stop | Out-Null
        } catch {
            throw "Failed to connect to Microsoft Graph. $($_.Exception.Message)"
        }
    }

    if (-not $SkipExchangeOnline) {
        try {
            if (-not (Get-Module ExchangeOnlineManagement -ListAvailable)) {
                Write-Warning "ExchangeOnlineManagement not found. Install it: Install-Module ExchangeOnlineManagement -Scope CurrentUser"
            }
            Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop | Out-Null
        } catch {
            throw "Failed to connect to Exchange Online. $($_.Exception.Message)"
        }
    }
}
