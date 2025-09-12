function Get-CISM365Control_8_5_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.2'
        Name        = "Ensure Teams app permission policies are configured"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Configure Teams app permission policies to control which apps users can install."
        Rationale   = "Limits exposure to risky or unnecessary apps."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-app-permission-policies'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center > Teams apps > Permission policies.
2. Review custom and global app permission policies.
3. Confirm policies appropriately restrict app installation.
"@
    }
}