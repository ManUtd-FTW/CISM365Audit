function Get-CISM365Control_2_1_9 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.1.9'
        Name        = "Ensure DKIM is enabled for all Exchange Online Domains"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "DKIM must be enabled for all accepted domains to prevent spoofing."
        Rationale   = "Enabling DKIM ensures outbound emails are cryptographically signed, reducing risk of domain spoofing."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dkim-configure?view=o365-worldwide'
        )
        Audit       = {
            try {
                $configs = Get-DkimSigningConfig
                $nonCompliant = $configs | Where-Object { $_.Enabled -eq $false }
                if ($nonCompliant.Count -eq 0) {
                    "PASS (DKIM enabled for all domains)"
                } else {
                    "FAIL (DKIM not enabled for domains: $($nonCompliant | Select-Object -ExpandProperty DomainName -join ', '))"
                }
            }
            catch {
                "MANUAL (Unable to check DKIM signing config: $($_.Exception.Message))"
            }
        }
    }
}