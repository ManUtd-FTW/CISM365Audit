function Get-CISM365Control_8_4_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.4.1'
        Name        = "Ensure Teams audit logging is enabled"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Teams')
        Description = "Enable audit logging for Teams to track access and changes."
        Rationale   = "Supports investigation and compliance."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/audit-logs'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > Audit.
2. Confirm Teams activities are being logged.
3. Run sample audit reports for Teams access and configuration changes.
"@
    }
}