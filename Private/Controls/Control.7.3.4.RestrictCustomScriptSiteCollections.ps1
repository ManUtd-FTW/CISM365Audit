function Get-CISM365Control_7_3_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.3.4'
        Name        = "Ensure custom script execution is restricted on site collections"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('SharePoint')
        Description = @'
Restricts custom script execution on site collections using DenyAddAndCustomizePages.
'@
        Rationale   = @'
Prevents unauthorized custom scripting on site collections, reducing risk of malicious code.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/allow-or-prevent-custom-script',
            'https://learn.microsoft.com/en-us/sharepoint/security-considerations-of-allowing-custom-script'
        )
        Audit = {
            try {
                $sites = Get-SPOSite -Limit All
                $failSites = @()
                foreach ($site in $sites) {
                    # Skip MySite host
                    if ($site.Url -match '-my.sharepoint.com') { continue }
                    if ($site.DenyAddAndCustomizePages -ne "Enabled") { $failSites += $site.Url }
                }
                if ($failSites.Count -eq 0) {
                    "PASS (Custom script is restricted on all site collections)"
                } else {
                    "FAIL (Custom script is not restricted on these sites: $($failSites -join ', '))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}