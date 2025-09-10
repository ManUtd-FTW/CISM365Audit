# Control: 2.1.9 Ensure that DKIM is enabled for all Exchange Online domains (L1)
# Requires: Exchange Online (Get-AcceptedDomain / Get-DkimSigningConfig)
function Get-CISM365Control_2_1_9 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.1.9'
        Name        = 'Ensure that DKIM is enabled for all Exchange Online domains'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Exchange')    # use 'Exchange' to match other controls; change back if your runner expects 'ExchangeOnline'
        Description = 'DKIM should be enabled for all custom accepted domains (non-onmicrosoft.com).'
        Rationale   = 'DKIM helps prevent spoofing by cryptographically signing outbound mail.'
        References = @(
            'https://learn.microsoft.com/powershell/module/exchangepowershell/get-dkimsigningconfig?view=exchange-ps'
        )
        Audit = {
            try {
                # Ensure Exchange cmdlets are available
                if (-not (Get-Command -Name Get-AcceptedDomain -ErrorAction SilentlyContinue) -or
                    -not (Get-Command -Name Get-DkimSigningConfig -ErrorAction SilentlyContinue)) {
                    return "MANUAL: Exchange Online cmdlets are not available in this session. Connect to Exchange Online (Connect-ExchangeOnline) or run this check from a session with Exchange cmdlets."
                }

                # Find custom authoritative domains (exclude *.onmicrosoft.com)
                $domains = Get-AcceptedDomain -ErrorAction SilentlyContinue |
                    Where-Object { $_.DomainType -eq 'Authoritative' -and $_.DomainName -notlike '*.onmicrosoft.com' }

                if (-not $domains -or $domains.Count -eq 0) {
                    return 'MANUAL (No custom authoritative domains found)'
                }

                $notEnabled = New-Object System.Collections.Generic.List[string]
                foreach ($d in $domains) {
                    try {
                        $dk = Get-DkimSigningConfig -Identity $d.DomainName -ErrorAction SilentlyContinue
                        if ($null -eq $dk -or ($dk.Enabled -ne $true)) {
                            $notEnabled.Add($d.DomainName)
                        }
                    } catch {
                        # Treat lookup failures as not enabled
                        $notEnabled.Add($d.DomainName)
                    }
                }

                if ($notEnabled.Count -eq 0) {
                    return 'PASS: DKIM enabled on all custom domains'
                } else {
                    return "FAIL: DKIM not enabled on: $($notEnabled -join ', ')"
                }
            } catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}