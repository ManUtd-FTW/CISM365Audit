function Get-CISM365Control_8_5_7 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.7'
        Name        = "Ensure external participants can't give or request control"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Prevents external participants (guests, anonymous users) from giving or requesting control during Teams meetings.
'@
        Rationale   = @'
Limits risk of inappropriate or malicious presentation control by external participants.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/meeting-who-present-request-control',
            'https://learn.microsoft.com/en-us/powershell/module/skype/set-csteamsmeetingpolicy?view=skype-ps'
        )
        Audit = {
            try {
                $policy = Get-CsTeamsMeetingPolicy -Identity Global
                if ($policy.AllowExternalParticipantGiveRequestControl -eq $false) {
                    "PASS (External participants cannot give/request control)"
                } else {
                    "FAIL (External participants can give/request control)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}