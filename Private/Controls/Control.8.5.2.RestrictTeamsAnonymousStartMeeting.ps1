function Get-CISM365Control_8_5_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.2'
        Name        = "Ensure anonymous users and dial-in callers can't start a meeting"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Prevents anonymous users and dial-in callers from starting Teams meetings without someone in attendance.
'@
        Rationale   = @'
Reduces risk of meeting spamming from anonymous and dial-in users.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/anonymous-users-in-meetings',
            'https://learn.microsoft.com/en-US/microsoftteams/who-can-bypass-meeting-lobby?WT.mc_id=TeamsAdminCenterCSH#overview-of-lobby-settings-and-policies'
        )
        Audit = {
            try {
                $policy = Get-CsTeamsMeetingPolicy -Identity Global
                if ($policy.AllowAnonymousUsersToStartMeeting -eq $false) {
                    "PASS (Anonymous users and dial-in callers cannot start meetings)"
                } else {
                    "FAIL (Anonymous users and dial-in callers can start meetings)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}