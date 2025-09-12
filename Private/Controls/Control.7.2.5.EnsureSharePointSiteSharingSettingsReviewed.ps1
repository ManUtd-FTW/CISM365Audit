function Get-CISM365Control_7_2_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.5'
        Name        = "Ensure SharePoint site sharing settings are reviewed"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Review site-level sharing settings to ensure they align with organizational policy."
        Rationale   = "Prevents over-sharing and ensures policy compliance."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to SharePoint Admin Center > Active sites.
2. For each site, review the sharing settings.
3. Compare with organizational policy and document exceptions.
"@
    }
}