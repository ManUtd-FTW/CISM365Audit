function Get-CISM365Control_8_7_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.7.1'
        Name        = "Ensure Teams session timeouts are configured"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Configure session timeouts for Teams to automatically sign users out after periods of inactivity."
        Rationale   = "Session management is required by NIST SP 800-53 for cloud and remote access."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-session-lifetime',
            'https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft 365 Admin Center > Azure Active Directory > Conditional Access > Session controls.
2. Review and validate session timeout settings for Teams.
3. Test to confirm auto sign-out occurs on inactivity.
"@
    }
}