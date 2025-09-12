function Get-CISM365Control_3_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.1.1'
        Name        = "Ensure Microsoft 365 audit log search is Enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Audit log search must be enabled for user and admin activity recording."
        Rationale   = "Audit logging is fundamental for incident response and regulatory compliance."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/audit-log-enable-disable?view=o365-worldwide'
        )
        Audit       = {
            try {
                $config = Get-AdminAuditLogConfig
                if ($config.UnifiedAuditLogIngestionEnabled) {
                    "PASS (Unified audit log ingestion is enabled)"
                } else {
                    "FAIL (Unified audit log ingestion is NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check audit log ingestion status: $($_.Exception.Message))"
            }
        }
    }
}