function Get-CISM365Control_8_5_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.1'
        Name        = "Ensure anonymous users can't join a meeting"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Prevents anyone other than invited attendees from joining Teams meetings by bypassing the lobby.
'@
        Rationale   = @'
Disabling anonymous join ensures only vetted users may join sensitive meetings.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/MicrosoftTeams/configure-meetings-sensitive-protection'
        )
        Audit = {
            try {
                $policy = Get-CsTeamsMeetingPolicy -Identity Global
                if ($policy.AllowAnonymousUsersToJoinMeeting -eq $false) {
                    "PASS (Anonymous users cannot join meetings)"
                } else {
                    "FAIL (Anonymous users are allowed to join meetings)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}