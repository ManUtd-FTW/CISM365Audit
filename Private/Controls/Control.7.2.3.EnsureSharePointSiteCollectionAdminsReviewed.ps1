function Get-CISM365Control_7_2_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.3'
        Name        = "Ensure SharePoint site collection administrators are periodically reviewed"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Site collection admins should be reviewed at least quarterly to ensure least privilege."
        Rationale   = "Reduces risk of excessive permissions."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/assign-site-collection-administrator'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to SharePoint Admin Center > Active sites.
2. Select a site and click 'Permissions'.
3. Review the list of site collection admins.
4. Document and validate if they need ongoing admin access.
"@
    }
}