function Get-CISM365Control_7_2_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.2'
        Name        = "Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('SharePoint','OneDrive')
        Description = @'
Azure AD B2B integration provides authentication and management of guest accounts for SharePoint and OneDrive.
'@
        Rationale   = @'
Integration enables controls and oversight for external users and applies MFA and access policies to guests.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/sharepoint-azureb2b-integration#enabling-the-integration'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.EnableAzureADB2BIntegration -eq $true) {
                    "PASS (SharePoint/OneDrive Azure AD B2B integration is enabled)"
                } else {
                    "FAIL (SharePoint/OneDrive Azure AD B2B integration is disabled)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}