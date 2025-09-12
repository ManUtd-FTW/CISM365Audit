function Get-CISM365Control_7_3_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.3.3'
        Name        = "Ensure SharePoint data classification labels are applied"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Apply sensitivity and classification labels to SharePoint documents and sites."
        Rationale   = "Ensures information is handled according to policy."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels?view=o365-worldwide'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > Information protection.
2. Review published sensitivity labels.
3. Spot check SharePoint sites and documents for label application.
"@
    }
}