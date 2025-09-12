function Get-CISM365Control_8_5_7 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.7'
        Name        = "Ensure Teams app usage is monitored"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Monitor usage of Teams apps to detect anomalies and ensure business justification."
        Rationale   = "Detects unauthorized or risky app usage."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-analytics-and-reports'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center > Analytics & reports > Usage reports.
2. Review app usage reports for anomalies.
3. Investigate usage of high-risk or non-business apps.
"@
    }
}