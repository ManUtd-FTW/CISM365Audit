function Disconnect-CISM365Services {
    [CmdletBinding()]
    param(
        [switch] $Graph,
        [switch] $ExchangeOnline,
        [switch] $Teams,
        [switch] $SharePointOnline,
        [switch] $SecurityCompliance,
        [switch] $All
    )

    if ($All -or -not ($Graph -or $ExchangeOnline -or $Teams -or $SharePointOnline -or $SecurityCompliance)) {
        $Graph = $true; $ExchangeOnline = $true; $Teams = $true; $SharePointOnline = $true; $SecurityCompliance = $true
    }

    if ($Graph)             { try { Disconnect-MgGraph -ErrorAction SilentlyContinue   | Out-Null } catch {} }
    if ($ExchangeOnline)    { try { Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue | Out-Null } catch {} }
    if ($Teams)             { try { Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue | Out-Null } catch {} }
    if ($SharePointOnline)  { try { Disconnect-SPOService  -ErrorAction SilentlyContinue | Out-Null } catch {} }
    if ($SecurityCompliance){ try { Disconnect-IPPSSession -ErrorAction SilentlyContinue | Out-Null } catch {} }
}
