function Get-CISM365Control_8_5_8 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.8'
        Name        = 'Ensure Teams meeting recording is restricted to organizers/presenters'
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Restrict Teams meeting recording privileges to organizers and presenters using Teams meeting policies.
'@
        Rationale   = @'
Controlling recording privileges helps prevent accidental or unauthorized recording of meetings.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/meeting-policies-in-teams',
            'https://learn.microsoft.com/en-us/powershell/module/teams/set-csteamsmeetingpolicy'
        )
        Audit = {
            try {
                $policies = Get-CsTeamsMeetingPolicy
                $failList = @()
                foreach ($policy in $policies) {
                    if ($policy.AllowCloudRecording -eq $true -and $policy.WhoCanRecordMeeting -ne "OrganizerAndPresenter") {
                        $failList += $policy.Identity
                    }
                }
                if ($failList.Count -eq 0) {
                    "PASS (Meeting recording is properly restricted to organizers/presenters)"
                } else {
                    "FAIL (Meeting recording not restricted in policies: $($failList -join ', '))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}