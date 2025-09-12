function Get-CISM365Control_7_2_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.4'
        Name        = "Ensure SharePoint guest access is periodically reviewed"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Guest access to SharePoint sites should be reviewed regularly to ensure only necessary guests have access."
        Rationale   = "Minimizes risk of exposure to external parties."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/external-sharing-overview'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to SharePoint Admin Center > Active sites.
2. Filter for sites with guest users.
3. Review and document guest users for each site.
4. Remove unnecessary guest access.
"@
    }
}