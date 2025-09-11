function Get-CISM365Control_8_5_6 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.6'
        Name        = "Ensure only organizers and co-organizers can present"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Restricts Teams meeting presentation rights to organizers and co-organizers only.
'@
        Rationale   = @'
Limits presentation to trusted individuals, reducing risk of inappropriate content sharing.
'@
        References  = @(
            'https://learn.microsoft.com/en-US/microsoftteams/meeting-who-present-request-control',
            'https://learn.microsoft.com/en-us/microsoftteams/meeting-who-present-request-control#manage-who-can-present',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/step-by-step-guides/reducing-attack-surface-in-microsoft-teams?view=o365-worldwide#configure-meeting-settings-restrict-presenters',
            'https://learn.microsoft.com/en-us/powershell/module/skype/set-csteamsmeetingpolicy?view=skype-ps'
        )
        Audit = {
            try {
                $policy = Get-CsTeamsMeetingPolicy -Identity Global
                if ($policy.DesignatedPresenterRoleMode -eq "OrganizerOnlyUserOverride") {
                    "PASS (Only organizers and co-organizers can present)"
                } else {
                    "FAIL (Other users can present: $($policy.DesignatedPresenterRoleMode))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}