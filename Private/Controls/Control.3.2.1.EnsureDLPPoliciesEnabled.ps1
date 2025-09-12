function Get-CISM365Control_3_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.2.1'
        Name        = "Ensure DLP policies are enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ComplianceCenter')
        Description = "Data Loss Prevention (DLP) policies should be enabled to protect sensitive information in Exchange, SharePoint, and OneDrive."
        Rationale   = "DLP prevents accidental or malicious leakage of sensitive data."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/data-loss-prevention-policies?view=o365-worldwide'
        )
        Audit       = {
            try {
                $dlpPolicies = Get-DlpCompliancePolicy
                $enabled = $dlpPolicies | Where-Object { $_.State -eq "Enabled" }
                if ($enabled.Count -gt 0) {
                    "PASS (DLP policy enabled: $($enabled | Select-Object -ExpandProperty Name -join ', '))"
                } else {
                    "FAIL (No enabled DLP policies found)"
                }
            }
            catch {
                "MANUAL (Unable to check DLP policy status: $($_.Exception.Message))"
            }
        }
    }
}