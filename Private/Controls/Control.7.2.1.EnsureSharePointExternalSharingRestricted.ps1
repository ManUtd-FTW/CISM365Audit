function Get-CISM365Control_7_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.1'
        Name        = "Ensure SharePoint external sharing is restricted"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Restrict external sharing for SharePoint sites to prevent unauthorized data exposure."
        Rationale   = "Limiting external sharing helps prevent accidental or malicious data leakage."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/external-sharing-overview'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft 365 Admin Center > SharePoint Admin Center.
2. Select 'Policies' > 'Sharing'.
3. Review external sharing settings for SharePoint.
4. Confirm sharing is set to 'Only people in your organization'.
"@
    }
}