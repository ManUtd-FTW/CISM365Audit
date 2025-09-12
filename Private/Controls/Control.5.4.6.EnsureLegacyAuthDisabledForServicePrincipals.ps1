function Get-CISM365Control_5_4_6 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.4.6'
        Name        = "Ensure legacy authentication is disabled for all service principals"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Graph')
        Description = "Legacy authentication (basic auth) should be disabled for all service principals/app registrations."
        Rationale   = "Prevent credential compromise via insecure protocols."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/block-legacy-authentication'
        )
        Audit       = {
            try {
                $principals = Get-MgServicePrincipal -All
                $legacyEnabled = $principals | Where-Object {
                    $_.PreferredSingleSignOnMode -eq "password" -or
                    $_.PasswordCredentials.Count -gt 0 -and $_.AppRoles.Count -eq 0
                }
                if ($legacyEnabled.Count -eq 0) {
                    "PASS (Legacy authentication disabled for all service principals)"
                } else {
                    "FAIL (Legacy authentication enabled for service principals: $($legacyEnabled | Select-Object -ExpandProperty DisplayName -join ', '))"
                }
            }
            catch {
                "MANUAL (Unable to check legacy authentication for service principals: $($_.Exception.Message))"
            }
        }
    }
}