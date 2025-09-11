function Get-CISM365Control_7_2_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.4'
        Name        = "Ensure OneDrive content sharing is restricted"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('OneDrive')
        Description = @'
Restricts OneDrive external sharing to only people in your organization.
'@
        Rationale   = @'
OneDrive should have tighter controls than SharePoint, requiring users to use official channels for external sharing.
'@
        References  = @(
            'https://learn.microsoft.com/en-US/sharepoint/turn-external-sharing-on-or-off?WT.mc_id=365AdminCSH_spo'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.OneDriveSharingCapability -eq "Disabled") {
                    "PASS (OneDrive external sharing is disabled)"
                } else {
                    "FAIL (OneDrive external sharing is not disabled: $($tenant.OneDriveSharingCapability))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}