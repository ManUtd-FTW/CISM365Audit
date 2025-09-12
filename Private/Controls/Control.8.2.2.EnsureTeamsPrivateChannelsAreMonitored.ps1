function Get-CISM365Control_8_2_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.2.2'
        Name        = "Ensure Teams private channels are monitored"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Monitor private channels to ensure appropriate use and prevent unauthorized data sharing."
        Rationale   = "Private channels may bypass normal oversight."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/private-channels'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center.
2. Review Teams with private channels.
3. Audit membership and data shared in private channels.
4. Ensure business justification for private channels exists.
"@
    }
}