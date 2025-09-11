function Get-CISM365Control_8_1_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.1.2'
        Name        = "Ensure users can't send emails to a channel email address"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Teams channel email addresses allow users to email channels directly. This should be disabled to prevent uncontrolled message injection.
'@
        Rationale   = @'
Disabling channel email prevents attackers from emailing channels directly and reduces risk.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/step-by-step-guides/reducing-attack-surface-in-microsoft-teams?view=o365-worldwide#restricting-channel-email-messages-to-approved-domains',
            'https://learn.microsoft.com/en-us/powershell/module/skype/set-csteamsclientconfiguration?view=skype-ps'
        )
        Audit = {
            try {
                $config = Get-CsTeamsClientConfiguration -Identity Global
                if ($config.AllowEmailIntoChannel -eq $false) {
                    "PASS (Users cannot send emails to a channel email address)"
                } else {
                    "FAIL (Users can send emails to a channel email address)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}