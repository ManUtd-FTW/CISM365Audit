function Get-CISM365Control_3_4_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.4.1'
        Name        = "Ensure audit log retention meets compliance standards"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Audit log retention should meet minimum compliance (90 days or more)."
        Rationale   = "Compliance frameworks require sufficient retention for incident response and investigation."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/audit-log-search?view=o365-worldwide'
        )
        Audit       = {
            try {
                $config = Get-AdminAuditLogConfig
                $retention = $config.UnifiedAuditLogRetentionPeriodInDays
                if ($retention -ge 90) {
                    "PASS (Audit log retention period is $retention days)"
                } else {
                    "FAIL (Audit log retention period is $retention days; must be at least 90 days)"
                }
            }
            catch {
                "MANUAL (Unable to check audit log retention period: $($_.Exception.Message))"
            }
        }
    }
}