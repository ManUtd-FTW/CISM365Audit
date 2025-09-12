function Get-CISM365Control_2_5_7 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.5.7'
        Name        = "Ensure DLP policies cover all Exchange, SharePoint, and OneDrive locations"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ComplianceCenter')
        Description = "DLP policies should be configured to protect Exchange, SharePoint, and OneDrive locations."
        Rationale   = "Comprehensive DLP coverage ensures sensitive data is protected in all collaboration channels."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/data-loss-prevention-policies?view=o365-worldwide'
        )
        Audit       = {
            try {
                $dlpPolicies = Get-DlpCompliancePolicy
                $passPolicies = $dlpPolicies | Where-Object {
                    $_.ExchangeLocation.Count -gt 0 -and
                    $_.SharePointLocation.Count -gt 0 -and
                    $_.OneDriveLocation.Count -gt 0
                }
                if ($passPolicies.Count -gt 0) {
                    "PASS (DLP policies cover Exchange, SharePoint, and OneDrive)"
                } else {
                    "FAIL (No DLP policy covers all required service locations)"
                }
            }
            catch {
                "MANUAL (Unable to check DLP policy coverage: $($_.Exception.Message))"
            }
        }
    }
}