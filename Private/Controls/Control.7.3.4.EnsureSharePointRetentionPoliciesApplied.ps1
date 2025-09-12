function Get-CISM365Control_7_3_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.3.4'
        Name        = "Ensure SharePoint retention policies are applied"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Retention labels and policies should be assigned to relevant SharePoint sites and content."
        Rationale   = "Supports regulatory and business compliance for data retention."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/retention-policies?view=o365-worldwide'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > Information governance > Retention policies.
2. Review retention policies assigned to SharePoint.
3. Spot check sites for correct label application.
"@
    }
}