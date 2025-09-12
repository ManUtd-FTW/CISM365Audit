function Get-CISM365Control_7_2_7 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.7'
        Name        = "Ensure SharePoint anonymous links are controlled"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Control and review use of anonymous sharing links in SharePoint."
        Rationale   = "Prevents uncontrolled public access to sensitive data."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to SharePoint Admin Center > Sharing.
2. Review settings for anonymous access links.
3. Spot check sites for use of anonymous links.
4. Remove or restrict as needed.
"@
    }
}