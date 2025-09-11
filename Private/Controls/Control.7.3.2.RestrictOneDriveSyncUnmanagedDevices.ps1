function Get-CISM365Control_7_3_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.3.2'
        Name        = "Ensure OneDrive sync is restricted for unmanaged devices"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('OneDrive','SharePoint')
        Description = @'
Restricts OneDrive for Business sync client usage to domain-joined computers only.
'@
        Rationale   = @'
Prevents organizational data from syncing to unmanaged devices, reducing risk of data leakage.
'@
        References  = @(
            'https://learn.microsoft.com/en-US/sharepoint/allow-syncing-only-on-specific-domains?WT.mc_id=365AdminCSH_spo'
        )
        Audit = {
            try {
                $restrictions = Get-SPOTenantSyncClientRestriction
                if ($restrictions.TenantRestrictionEnabled -eq $true -and $restrictions.AllowedDomainList) {
                    "PASS (OneDrive sync is restricted to managed domains: $($restrictions.AllowedDomainList -join ', '))"
                } else {
                    "FAIL (OneDrive sync is not restricted to managed domains)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}