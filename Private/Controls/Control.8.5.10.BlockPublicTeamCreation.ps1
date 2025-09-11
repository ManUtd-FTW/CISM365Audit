function Get-CISM365Control_8.5.10{
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.10'
        Name        = 'Ensure only private teams can be created (block public team creation)'
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Block creation of public teams via Teams org-wide settings to prevent accidental data exposure.
'@
        Rationale   = @'
Limiting team creation to private teams reduces risk of exposing sensitive information to unauthorized users.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-settings',
            'https://learn.microsoft.com/en-us/powershell/module/teams/set-csteamsclientconfiguration'
        )
        Audit = {
            try {
                $settings = Get-CsTeamsClientConfiguration
                if ($settings.AllowCreatePublicTeam -eq $false) {
                    "PASS (Only private teams can be created; public team creation is blocked)"
                } else {
                    "FAIL (Public team creation is allowed)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}