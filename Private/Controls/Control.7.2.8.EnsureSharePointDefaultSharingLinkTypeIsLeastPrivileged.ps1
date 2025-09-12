function Get-CISM365Control_7_2_8 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.8'
        Name        = "Ensure SharePoint default sharing link type is least privileged"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Default sharing link type should be set to the least privileged option (e.g., 'Specific people')."
        Rationale   = "Reduces accidental broad sharing."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to SharePoint Admin Center > Sharing.
2. Check default link type settings.
3. Verify 'Specific people' is the default.
"@
    }
}