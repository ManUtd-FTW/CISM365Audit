function Get-CISM365Control_2_5_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.5.5'
        Name        = "Ensure Unified Audit Log ingestion is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Unified audit log search must be enabled for full audit coverage across Microsoft 365."
        Rationale   = "Audit logs are essential for compliance and incident response."
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