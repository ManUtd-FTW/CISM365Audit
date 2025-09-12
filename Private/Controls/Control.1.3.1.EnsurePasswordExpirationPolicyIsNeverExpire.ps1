function Get-CISM365Control_1_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.3.1'
        Name        = "Ensure 'Password expiration policy' is set to 'Set passwords to never expire (recommended)'"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Office 365 passwords should be set to never expire for all domains."
        Rationale   = "Continuous password expiration reduces security and user experience. NIST, Microsoft and CIS recommend passwords never expire unless compromised."
        References  = @(
            'https://learn.microsoft.com/en-US/microsoft-365/admin/misc/password-policy-recommendations?view=o365-worldwide'
        )
        Audit       = {
            try {
                $domains = Get-MgDomain -All
                $results = @()
                foreach ($domain in $domains) {
                    $expiry = $domain.PasswordValidityPeriodInDays
                    $results += [PSCustomObject]@{
                        Domain = $domain.Id
                        NeverExpires = ($expiry -eq 2147483647)
                        PasswordValidityPeriodInDays = $expiry
                    }
                }
                $nonCompliant = $results | Where-Object { -not $_.NeverExpires }
                if ($nonCompliant.Count -eq 0) {
                    'PASS (All domains set to never expire passwords)'
                } else {
                    "FAIL (The following domains are not set to never expire passwords: $($nonCompliant | ForEach-Object { $_.Domain + ' (' + $_.PasswordValidityPeriodInDays + ' days)' } -join ', '))"
                }
            }
            catch {
                "MANUAL (Unable to enumerate domain password policies: $($_.Exception.Message))"
            }
        }
    }
}