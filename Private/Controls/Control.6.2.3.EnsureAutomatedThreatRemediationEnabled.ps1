function Get-CISM365Control_6_2_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.2.3'
        Name        = "Ensure automated threat remediation is enabled (ExchangeOnline)"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Automated threat remediation (e.g., zero-hour auto purge, malware filter actions) should be enabled for Exchange Online mailboxes."
        Rationale   = "Helps contain threats automatically and reduce manual workload."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/zero-hour-auto-purge?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/powershell/module/exchange/remove-threats?view=exchange-ps'
        )
        Audit       = {
            try {
                $zhap = Get-ZeroHourAutoPurge
                $malwareFilter = Get-MalwareFilterPolicy | Where-Object { $_.Action -eq 'DeleteMessage' }
                if ($zhap.Enabled -eq $true -and $malwareFilter) {
                    "PASS (Automated threat remediation is enabled: Zero-hour auto purge and malware filter actions are set)"
                } else {
                    "FAIL (Automated threat remediation is NOT fully enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check automated threat remediation status: $($_.Exception.Message))"
            }
        }
    }
}