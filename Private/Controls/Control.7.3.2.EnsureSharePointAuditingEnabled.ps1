function Get-CISM365Control_7_3_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.3.2'
        Name        = "Ensure SharePoint auditing is enabled"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Enable auditing of access and changes to documents and permissions in SharePoint."
        Rationale   = "Supports investigation and compliance."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/security-audit-log-report'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > Audit.
2. Confirm SharePoint activities are being logged.
3. Run sample audit reports for site access and document changes.
"@
    }
}