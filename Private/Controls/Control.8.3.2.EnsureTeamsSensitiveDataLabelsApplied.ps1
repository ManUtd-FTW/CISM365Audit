function Get-CISM365Control_8_3_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.3.2'
        Name        = "Ensure Teams sensitive data labels are applied"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Teams')
        Description = "Apply sensitivity labels to Teams and channels handling confidential or regulated data."
        Rationale   = "Ensures data is handled according to classification requirements."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/sensitivity-labels'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > Information protection.
2. Review published sensitivity labels.
3. Spot check Teams and channels for label application.
"@
    }
}