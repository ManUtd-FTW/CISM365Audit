function Get-CISM365Control_8_5_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.1'
        Name        = "Ensure Teams third-party app access is reviewed"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Review and restrict access to third-party apps in Teams to minimize risk."
        Rationale   = "Third-party apps can introduce vulnerabilities."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/admin-settings'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center > Teams apps > Manage apps.
2. Review enabled third-party apps.
3. Disable or restrict apps not required for business.
"@
    }
}