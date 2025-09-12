function Get-CISM365Control_7_2_9 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.9'
        Name        = "Ensure SharePoint sharing link permissions are restricted"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Restrict permissions granted by sharing links to prevent editing or full control unless absolutely necessary."
        Rationale   = "Limits what shared users can do with data."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to SharePoint Admin Center > Sharing.
2. Review link permission settings (view vs edit).
3. Confirm 'view only' is default where possible.
"@
    }
}