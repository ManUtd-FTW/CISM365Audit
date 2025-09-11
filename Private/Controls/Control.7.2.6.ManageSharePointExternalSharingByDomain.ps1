function Get-CISM365Control_7_2_6 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.6'
        Name        = "Ensure SharePoint external sharing is managed through domain whitelist/blacklists"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('SharePoint')
        Description = @'
Control sharing of documents to external domains by allowing or blocking specific domains.
'@
        Rationale   = @'
Restricts sharing to trusted domains, reducing risk of data leakage.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/manage-security-groups'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.SharingDomainRestrictionMode -eq "AllowList" -and $tenant.SharingAllowedDomainList) {
                    "PASS (External sharing restricted to allowed domain list: $($tenant.SharingAllowedDomainList -join ', '))"
                } else {
                    "FAIL (External sharing not restricted by allowlist)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}