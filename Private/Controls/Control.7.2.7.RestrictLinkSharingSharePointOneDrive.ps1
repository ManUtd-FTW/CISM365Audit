function Get-CISM365Control_7_2_7 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.7'
        Name        = "Ensure link sharing is restricted in SharePoint and OneDrive"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('SharePoint','OneDrive')
        Description = @'
Sets default link type to Specific people when sharing content in SharePoint and OneDrive.
'@
        Rationale   = @'
Defaulting to specific people enforces least privilege and reduces unintended sharing.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/set-spotenant?view=sharepoint-ps'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.DefaultSharingLinkType -eq "Direct") {
                    "PASS (Default sharing link type is 'Specific people')"
                } else {
                    "FAIL (Default sharing link type is not 'Specific people': $($tenant.DefaultSharingLinkType))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}