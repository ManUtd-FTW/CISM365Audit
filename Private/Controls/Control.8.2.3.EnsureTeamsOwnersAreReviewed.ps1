function Get-CISM365Control_8_2_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.2.3'
        Name        = "Ensure Teams owners are reviewed"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Teams')
        Description = "Regularly review Teams owners to ensure appropriate oversight and management."
        Rationale   = "Proper ownership helps maintain security and accountability."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/assign-owners'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center.
2. Review owner assignments for all Teams.
3. Confirm owners are current and business justified.
"@
    }
}