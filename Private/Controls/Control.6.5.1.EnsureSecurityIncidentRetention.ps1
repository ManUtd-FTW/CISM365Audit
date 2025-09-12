function Get-CISM365Control_6_5_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.5.1'
        Name        = "Ensure security incidents and alerts are retained for appropriate period"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Security incidents and alerts must be retained for the required period (e.g., 90 days or as per regulatory standards)."
        Rationale   = "Retention of alerts and incidents supports compliance and investigations."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/sentinel/data-retention'
        )
        Audit       = {
            try {
                $retention = Get-MgSecurityRetentionPolicy | Where-Object { $_.Type -eq "Incident" }
                if ($retention.RetentionPeriodInDays -ge 90) {
                    "PASS (Security incident retention period is $($retention.RetentionPeriodInDays) days)"
                } else {
                    "FAIL (Security incident retention period is only $($retention.RetentionPeriodInDays) days)"
                }
            }
            catch {
                "MANUAL (Unable to check security incident retention policy: $($_.Exception.Message))"
            }
        }
    }
}