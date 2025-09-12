function Get-CISM365Control_2_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.3.1'
        Name        = "Ensure the Account Provisioning Activity report is reviewed at least weekly"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Audit log search should show user provisioning events for the past 7 days."
        Rationale   = "Identifies unauthorized or unexpected account provisioning attempts."
        References  = @(
            'https://learn.microsoft.com/en-us/powershell/module/exchange/search-unifiedauditlog?view=exchange-ps'
        )
        Audit       = {
            try {
                $startDate = ((Get-date).AddDays(-7)).ToShortDateString()
                $endDate = (Get-date).ToShortDateString()
                $log = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate | Where-Object { $_.Operations -eq "add user." }
                if ($log) {
                    "PASS (Account provisioning activity detected in the last 7 days)"
                } else {
                    "PASS (No account provisioning activity detected in the last 7 days)"
                }
            }
            catch {
                "MANUAL (Unable to check account provisioning activity logs: $($_.Exception.Message))"
            }
        }
    }
}