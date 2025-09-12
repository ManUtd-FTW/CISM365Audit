function Get-CISM365Control_8_5_6 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.6'
        Name        = "Ensure Teams app update process exists"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Establish and review a process for updating Teams apps."
        Rationale   = "Ensures apps remain supported and patched."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-apps-update'
        )
        Audit       = @"
Manual Audit Steps:
1. Review documentation for Teams app update processes.
2. Confirm updates are tracked and applied regularly.
3. Interview app owners for update frequency and process adherence.
"@
    }
}