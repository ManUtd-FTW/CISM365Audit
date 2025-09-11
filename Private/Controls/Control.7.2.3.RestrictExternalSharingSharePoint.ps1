function Get-CISM365Control_7_2_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.3'
        Name        = "Ensure external content sharing is restricted"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('SharePoint','OneDrive')
        Description = @'
Restrict SharePoint external sharing to new and existing guests or more restrictive settings.
'@
        Rationale   = @'
Forcing guest authentication enables controls and oversight over external file sharing.
'@
        References  = @(
            'https://learn.microsoft.com/en-US/sharepoint/turn-external-sharing-on-or-off?WT.mc_id=365AdminCSH_spo'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                $valid = $tenant.SharingCapability -eq "ExternalUserSharingOnly" -or
                         $tenant.SharingCapability -eq "ExistingExternalUserSharingOnly" -or
                         $tenant.SharingCapability -eq "Disabled"
                if ($valid) {
                    "PASS (External content sharing is restricted to guests/disabled)"
                } else {
                    "FAIL (External content sharing is not restricted: $($tenant.SharingCapability))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}