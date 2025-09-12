function Get-CISM365Control_3_4_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.4.5'
        Name        = "Ensure recent data classification activity is available"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ComplianceCenter')
        Description = "Data classification activity should be available for review to support sensitive data management and compliance."
        Rationale   = "Classification reports help inventory sensitive data and support incident response."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/data-classification-overview?view=o365-worldwide'
        )
        Audit       = {
            try {
                $dataClassification = Get-DataClassificationActivity
                if ($dataClassification) {
                    "PASS (Recent data classification activity detected)"
                } else {
                    "FAIL (No recent data classification activity found)"
                }
            }
            catch {
                "MANUAL (Unable to check data classification activity: $($_.Exception.Message))"
            }
        }
    }
}