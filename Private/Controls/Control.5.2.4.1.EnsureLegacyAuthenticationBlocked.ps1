function Get-CISM365Control_5_2_4_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.2.4.1'
        Name        = "Ensure legacy authentication protocols are blocked"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Legacy authentication protocols (basic auth) should be blocked for all users."
        Rationale   = "Blocking legacy protocols prevents credential compromise and supports secure authentication."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/block-legacy-authentication'
        )
        Audit       = {
            try {
                $policies = Get-MgConditionalAccessPolicy -All
                $legacyBlocked = $policies | Where-Object {
                    $_.State -eq "enabled" -and
                    $_.Conditions.ClientAppTypes -contains "ExchangeActiveSync" -or
                    $_.Conditions.ClientAppTypes -contains "Other"
                }
                if ($legacyBlocked.Count -gt 0) {
                    "PASS (Legacy authentication protocols are blocked by Conditional Access policy)"
                } else {
                    "FAIL (Legacy authentication protocols are NOT blocked)"
                }
            }
            catch {
                "MANUAL (Unable to check legacy authentication status: $($_.Exception.Message))"
            }
        }
    }
}