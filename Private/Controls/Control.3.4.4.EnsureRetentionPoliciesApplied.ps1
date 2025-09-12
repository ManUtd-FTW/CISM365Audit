function Get-CISM365Control_3_4_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.4.4'
        Name        = "Ensure records management/retention policies are applied"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ComplianceCenter')
        Description = "Retention labels and policies should be assigned to content across Exchange, SharePoint, and OneDrive."
        Rationale   = "Retention policies are critical for regulatory and business compliance."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/retention-policies?view=o365-worldwide'
        )
        Audit       = {
            try {
                $retentionLabels = Get-ComplianceTag
                $retentionPolicies = Get-RetentionCompliancePolicy | Where-Object { $_.State -eq 'Enabled' }
                if ($retentionPolicies.Count -gt 0) {
                    "PASS (Retention policies applied: $($retentionPolicies | Select-Object -ExpandProperty Name -join ', '))"
                } else {
                    "FAIL (No retention policies applied)"
                }
            }
            catch {
                "MANUAL (Unable to check retention policy status: $($_.Exception.Message))"
            }
        }
    }
}