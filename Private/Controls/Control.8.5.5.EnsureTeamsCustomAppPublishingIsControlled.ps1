function Get-CISM365Control_8_5_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.5'
        Name        = "Ensure Teams custom app publishing is controlled"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Control and review publishing of custom (line-of-business) apps in Teams."
        Rationale   = "Prevents deployment of apps without proper vetting."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-custom-apps'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center > Teams apps > Manage apps.
2. Filter for custom apps.
3. Review publishing process and authorization.
4. Confirm only approved apps are published.
"@
    }
}