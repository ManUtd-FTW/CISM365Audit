function Get-CISM365Control_7_2_6 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.6'
        Name        = "Ensure SharePoint sharing activity is monitored"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Monitor sharing activity for unusual or unauthorized external sharing in SharePoint."
        Rationale   = "Detects data leakage or policy violations."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > Audit.
2. Search for SharePoint sharing activities.
3. Review for unusual patterns or unauthorized sharing.
4. Take action as needed.
"@
    }
}