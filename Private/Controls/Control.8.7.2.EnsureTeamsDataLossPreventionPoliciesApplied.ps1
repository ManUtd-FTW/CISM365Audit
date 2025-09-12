function Get-CISM365Control_8_7_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.7.2'
        Name        = "Ensure Teams Data Loss Prevention (DLP) policies are applied"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Apply and review DLP policies for Teams chats and channel messages to prevent sharing of sensitive information."
        Rationale   = "DLP is recommended by Microsoft and NIST for protecting regulated data in cloud collaboration."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/dlp-microsoft-teams',
            'https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > Data loss prevention.
2. Review DLP policies assigned to Teams.
3. Test DLP policy enforcement by attempting to share regulated data.
"@
    }
}