function Get-CISM365Control_8_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.3.1'
        Name        = "Ensure Teams data retention policies are applied"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Teams')
        Description = "Apply retention policies to Teams chats and channel messages to meet compliance requirements."
        Rationale   = "Ensures records are retained or deleted per policy."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/retention-policies'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > Information governance > Retention policies.
2. Review Teams-specific retention policies.
3. Spot check Teams for policy application.
"@
    }
}