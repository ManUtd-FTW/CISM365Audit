function Get-CISM365Control_8_7_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.7.3'
        Name        = "Ensure Teams guest access is limited to approved domains"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Restrict Teams guest access to a list of approved domains to reduce risk of external data exposure."
        Rationale   = "Limiting guest access is a recommended security practice per Microsoft and NIST."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/guest-access',
            'https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center > Org-wide settings > Guest access.
2. Review the allowed guest domains list.
3. Confirm only approved domains are present.
"@
    }
}