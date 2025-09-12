function Get-CISM365Control_8_5_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.3'
        Name        = "Ensure Teams app setup policies are reviewed"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Review and configure Teams app setup policies to control which apps are pinned or available."
        Rationale   = "Prevents unnecessary apps from being promoted to users."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-app-setup-policies'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center > Teams apps > Setup policies.
2. Review configuration of custom and global setup policies.
3. Validate pinned apps are business-required.
"@
    }
}