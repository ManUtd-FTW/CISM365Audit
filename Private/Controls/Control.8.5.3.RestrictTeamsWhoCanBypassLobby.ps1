function Get-CISM365Control_8_5_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.3'
        Name        = "Ensure only people in my org can bypass the lobby"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Controls who can join a Teams meeting directly and who must wait in the lobby.
'@
        Rationale   = @'
Ensures only trusted organizational users can bypass the lobby and join meetings directly.
'@
        References  = @(
            'https://learn.microsoft.com/en-US/microsoftteams/who-can-bypass-meeting-lobby?WT.mc_id=TeamsAdminCenterCSH',
            'https://learn.microsoft.com/en-us/powershell/module/skype/set-csteamsmeetingpolicy?view=skype-ps'
        )
        Audit = {
            try {
                $policy = Get-CsTeamsMeetingPolicy -Identity Global
                if ($policy.AutoAdmittedUsers -eq "EveryoneInCompanyExcludingGuests") {
                    "PASS (Only people in org can bypass the lobby)"
                } else {
                    "FAIL (Lobby bypass not restricted to org only: $($policy.AutoAdmittedUsers))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}