function Get-CISM365Control_8_5_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.4'
        Name        = "Ensure Teams app store access is restricted"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Restrict access to the Teams app store to limit installation of unauthorized apps."
        Rationale   = "Reduces risk of users installing unvetted apps."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-app-permission-policies'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center > Teams apps > Permission policies.
2. Confirm policies restrict or block access to the Teams app store as required.
3. Review exceptions for business justification.
"@
    }
}