function Disconnect-CISM365Services {
<#
.SYNOPSIS
Disconnect from one or more Microsoft 365 admin services.

.PARAMETER Services
One or more of: Graph, ExchangeOnline, Teams, SharePointOnline, Purview, All.
Default: Graph, ExchangeOnline, Teams, SharePointOnline, Purview.

.EXAMPLE
Disconnect-CISM365Services -Services All
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [ValidateSet('Graph','ExchangeOnline','Teams','SharePointOnline','Purview','All')]
    [string[]]$Services = @('Graph','ExchangeOnline','Teams','SharePointOnline','Purview')
)

if ($Services -contains 'All') {
    $Services = @('Graph','ExchangeOnline','Teams','SharePointOnline','Purview')
}

$result = [ordered]@{
    Graph            = 'Skipped'
    ExchangeOnline   = 'Skipped'
    Teams            = 'Skipped'
    SharePointOnline = 'Skipped'
    Purview          = 'Skipped'
}

foreach ($s in $Services) {
    try {
        switch ($s) {
            'Graph' {
                if ($PSCmdlet.ShouldProcess('Microsoft Graph','Disconnect')) {
                    if (Get-Command Disconnect-MgGraph -ErrorAction SilentlyContinue) {
                        Disconnect-MgGraph -ErrorAction SilentlyContinue
                        $result.Graph = 'Disconnected'
                    } else {
                        $result.Graph = 'NotAvailable'
                    }
                }
            }
            'ExchangeOnline' {
                if ($PSCmdlet.ShouldProcess('Exchange Online','Disconnect')) {
                    if (Get-Command Disconnect-ExchangeOnline -ErrorAction SilentlyContinue) {
                        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
                        $result.ExchangeOnline = 'Disconnected'
                    } else {
                        $result.ExchangeOnline = 'NotAvailable'
                    }
                }
            }
            'Teams' {
                if ($PSCmdlet.ShouldProcess('Microsoft Teams','Disconnect')) {
                    if (Get-Command Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue) {
                        Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue
                        $result.Teams = 'Disconnected'
                    } else {
                        $result.Teams = 'NotAvailable'
                    }
                }
            }
            'SharePointOnline' {
                if ($PSCmdlet.ShouldProcess('SharePoint Online','Disconnect')) {
                    if (Get-Command Disconnect-SPOService -ErrorAction SilentlyContinue) {
                        Disconnect-SPOService -ErrorAction SilentlyContinue
                        $result.SharePointOnline = 'Disconnected'
                    } else {
                        $result.SharePointOnline = 'NotAvailable'
                    }
                }
            }
            'Purview' {
                if ($PSCmdlet.ShouldProcess('Compliance (IPPSSession)','Disconnect')) {
                    # IPPSSession is managed via ExchangeOnlineManagement; Disconnect-ExchangeOnline typically tears it down.
                    if (Get-Command Disconnect-ExchangeOnline -ErrorAction SilentlyContinue) {
                        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
                        $result.Purview = 'Disconnected'
                    } else {
                        # Best-effort cleanup of any compliance PSSessions if EXO cmdlet isn't available
                        try {
                            $ipp = Get-PSSession | Where-Object {
                                $_.ConfigurationName -eq 'Microsoft.Exchange' -and
                                $_.ComputerName -like '*.compliance.protection.outlook.com*'
                            }
                            if ($ipp) { $ipp | Remove-PSSession -ErrorAction SilentlyContinue }
                            $result.Purview = 'Disconnected'
                        } catch {
                            $result.Purview = "Error: $($_.Exception.Message)"
                        }
                    }
                }
            }
        }
    } catch {
        $result[$s] = "Error: $($_.Exception.Message)"
    }
}

[PSCustomObject]$result
}
