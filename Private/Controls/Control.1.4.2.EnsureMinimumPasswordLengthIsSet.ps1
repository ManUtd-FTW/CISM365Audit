function Get-CISM365Control_1_4_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.4.2'
        Name        = "Ensure minimum password length is set to 8 or greater"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "All domains should enforce a minimum password length of 8 or greater, per NIST and Microsoft recommendations."
        Rationale   = "Enforcing password length is a foundational control for password security."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-password-ban-bad',
            'https://pages.nist.gov/800-63-3/sp800-63b.html'
        )
        Audit       = {
            try {
                $domains = Get-MgDomain -All
                $results = @()
                foreach ($domain in $domains) {
                    $minLength = $domain.PasswordMinimumLength
                    $results += [PSCustomObject]@{
                        Domain = $domain.Id
                        MinimumLength = $minLength
                        Compliant = ($minLength -ge 8)
                    }
                }
                $nonCompliant = $results | Where-Object { -not $_.Compliant }
                if ($nonCompliant.Count -eq 0) {
                    'PASS (All domains enforce minimum password length of 8 or greater)'
                } else {
                    $domainStrings = $nonCompliant | ForEach-Object { "$($_.Domain) (min: $($_.MinimumLength))" }
                    "FAIL (Domains not enforcing minimum password length: $($domainStrings -join ', '))"
                }
            }
            catch {
                "MANUAL (Unable to check minimum password length via Graph: $($_.Exception.Message))"
            }
        }
    }
}