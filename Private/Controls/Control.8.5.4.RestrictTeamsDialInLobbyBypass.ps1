function Get-CISM365Control_8_5_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.4'
        Name        = "Ensure users dialing in can't bypass the lobby"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Prevents users who dial in by phone from joining Teams meetings directly, requiring organizer approval.
'@
        Rationale   = @'
Ensures dial-in users are vetted before joining meetings, reducing risk.
'@
        References  = @(
            'https://learn.microsoft.com/en-US/microsoftteams/who-can-bypass-meeting-lobby?WT.mc_id=TeamsAdminCenterCSH#choose-who-can-bypass-the-lobby-in-meetings-hosted-by-your-organization',
            'https://learn.microsoft.com/en-us/powershell/module/skype/set-csteamsmeetingpolicy?view=skype-ps'
        )
        Audit = {
            try {
                $policy = Get-CsTeamsMeetingPolicy -Identity Global
                if ($policy.AllowPSTNUsersToBypassLobby -eq $false) {
                    "PASS (Dial-in users cannot bypass the lobby)"
                } else {
                    "FAIL (Dial-in users can bypass the lobby)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}