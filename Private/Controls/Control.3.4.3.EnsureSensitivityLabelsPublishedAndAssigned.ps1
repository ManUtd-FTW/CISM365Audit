function Get-CISM365Control_3_4_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.4.3'
        Name        = "Ensure sensitivity labels are published and assigned"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ComplianceCenter')
        Description = "Sensitivity labels should be published and assigned to content across Exchange, SharePoint, and OneDrive."
        Rationale   = "Labeling content enables protection, retention, and compliance."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels?view=o365-worldwide'
        )
        Audit       = {
            try {
                $labels = Get-Label
                $publishedLabels = Get-LabelPolicy | Where-Object { $_.Enabled -eq $true }
                if ($publishedLabels.Count -gt 0) {
                    "PASS (Published sensitivity label policies: $($publishedLabels | Select-Object -ExpandProperty Name -join ', '))"
                } else {
                    "FAIL (No published sensitivity label policies found)"
                }
            }
            catch {
                "MANUAL (Unable to check sensitivity label publication status: $($_.Exception.Message))"
            }
        }
    }
}