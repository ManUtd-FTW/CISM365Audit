function Get-CISM365Control_7_2_9 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.9'
        Name        = "Ensure guest access to a site or OneDrive will expire automatically"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('SharePoint','OneDrive')
        Description = @'
Configure expiration time for each guest invited to a SharePoint site or OneDrive link. Recommended: 30 days or less.
'@
        Rationale   = @'
Ensures guest access is limited to a defined period, reducing risk of lingering access.
'@
        References  = @(
            'https://learn.microsoft.com/en-US/sharepoint/turn-external-sharing-on-or-off?WT.mc_id=365AdminCSH_spo#change-the-organization-level-external-sharing-setting'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.ExternalUserExpirationRequired -eq $true -and $tenant.ExternalUserExpireInDays -le 30) {
                    "PASS (Guest access expires automatically after $($tenant.ExternalUserExpireInDays) days)"
                } else {
                    "FAIL (Guest access expiration not properly configured: Required=$($tenant.ExternalUserExpirationRequired), Days=$($tenant.ExternalUserExpireInDays))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}