function Get-CISM365Control_8_1_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.1.2'
        Name        = "Ensure Teams guest access is controlled"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Teams')
        Description = "Guest access should be enabled only as necessary, with permissions reviewed regularly."
        Rationale   = "Guest users can access sensitive data if not properly managed."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/guest-access'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center.
2. Select 'Org-wide settings' > 'Guest access'.
3. Review guest permissions and ensure only required features are enabled.
4. Regularly review guest user list in Azure Active Directory.
"@
    }
}