function Get-CISM365Control_8_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.2.1'
        Name        = "Ensure Teams channel creation is restricted"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Restrict who can create channels in Teams to minimize sprawl and potential information exposure."
        Rationale   = "Limiting channel creation helps maintain orderly collaboration and security."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-channels-overview'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center.
2. Review Teams policies > 'Create and delete channels'.
3. Ensure only authorized users/groups can create channels.
"@
    }
}