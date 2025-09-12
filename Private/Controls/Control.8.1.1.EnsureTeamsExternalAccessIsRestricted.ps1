function Get-CISM365Control_8_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.1.1'
        Name        = "Ensure Teams external access is restricted"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Teams')
        Description = "Restrict external access in Microsoft Teams to prevent unauthorized communications and data sharing."
        Rationale   = "Limiting external access reduces risk of data leaks and unauthorized collaboration."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/manage-external-access'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Teams Admin Center.
2. Select 'Org-wide settings' > 'External access'.
3. Verify external domains are restricted or blocked.
4. Document allowed external domains and business justification.
"@
    }
}