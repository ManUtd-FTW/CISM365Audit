function Get-CISM365Control_3_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.3.1'
        Name        = "Ensure SharePoint Online Information Protection policies are set up and used"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ComplianceCenter')
        Description = "SharePoint Online must have published sensitivity label policies for data classification and protection."
        Rationale   = "Classification and labeling enables better governance, DLP, and incident response."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/data-classification-overview?view=o365-worldwide'
        )
        Audit       = {
            try {
                $labels = Get-Label
                $publishedLabels = Get-LabelPolicy | Where-Object { $_.Enabled -eq $true }
                if ($publishedLabels.Count -gt 0) {
                    "PASS (Published sensitivity label policies: $($publishedLabels | Select-Object -ExpandProperty Name -join ', '))"
                } else {
                    "FAIL (No published sensitivity label policies found for SharePoint Online)"
                }
            }
            catch {
                "MANUAL (Unable to check label policy publication status: $($_.Exception.Message))"
            }
        }
    }
}