function Get-CISM365Control_8_5_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.5'
        Name        = "Ensure meeting chat does not allow anonymous users"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Controls who can read/write chat messages during a Teams meeting. Anonymous users should not have chat access.
'@
        Rationale   = @'
Prevents unauthorized individuals from reading/writing chat in meetings, reducing risk.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/powershell/module/skype/set-csteamsmeetingpolicy?view=skype-ps#-meetingchatenabledtype'
        )
        Audit = {
            try {
                $policy = Get-CsTeamsMeetingPolicy -Identity Global
                if ($policy.MeetingChatEnabledType -eq "EnabledExceptAnonymous") {
                    "PASS (Meeting chat excluded for anonymous users)"
                } else {
                    "FAIL (Meeting chat enabled for anonymous users: $($policy.MeetingChatEnabledType))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}