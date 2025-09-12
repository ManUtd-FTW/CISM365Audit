function Get-CISM365Control_8_6_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.6.1'
        Name        = "Ensure Teams compliance features are configured"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Teams')
        Description = "Configure Teams for compliance features such as eDiscovery, legal hold, and communication compliance."
        Rationale   = "Supports regulatory and legal requirements."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/ediscovery-legal-hold'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to Microsoft Purview compliance portal > eDiscovery.
2. Review Teams included in eDiscovery and legal hold policies.
3. Check communication compliance settings for Teams.
"@
    }
}