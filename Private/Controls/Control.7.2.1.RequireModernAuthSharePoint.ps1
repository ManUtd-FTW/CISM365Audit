function Get-CISM365Control_7_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.1'
        Name        = "Ensure modern authentication for SharePoint applications is required"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('SharePoint')
        Description = @'
Modern authentication enables features like MFA and disables legacy basic authentication for SharePoint apps.
'@
        Rationale   = @'
Requiring modern authentication ensures strong authentication mechanisms and mitigates risk from legacy protocols.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/set-spotenant?view=sharepoint-ps'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.LegacyAuthProtocolsEnabled -eq $false) {
                    "PASS (Legacy authentication is disabled for SharePoint applications)"
                } else {
                    "FAIL (Legacy authentication is enabled for SharePoint applications)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}