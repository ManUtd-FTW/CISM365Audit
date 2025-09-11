function Get-CISM365Control_2_1_9 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.1.9'
        Name        = 'Ensure DKIM, SPF, and DMARC are configured for all domains'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = @'
DKIM, SPF, and DMARC records must be correctly configured for all accepted domains to prevent spoofing and phishing.
'@
        Rationale   = @'
Proper email authentication mitigates phishing and impersonation risks.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dmarc-to-validate-email?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dkim-to-validate-email?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/use-spf-to-validate-email?view=o365-worldwide'
        )
        Audit = {
            try {
                $domains = Get-AcceptedDomain
                $failDomains = @()
                foreach ($domain in $domains) {
                    # SPF check (external DNS)
                    $spf = (Resolve-DnsName -Name $domain.DomainName -Type TXT | Where-Object { $_.Strings -like "v=spf1*" }).Strings
                    $dkim = Get-DkimSigningConfig -Identity $domain.DomainName -ErrorAction SilentlyContinue
                    $dmarc = (Resolve-DnsName -Name "_dmarc.$($domain.DomainName)" -Type TXT -ErrorAction SilentlyContinue | Where-Object { $_.Strings -like "v=DMARC1*" }).Strings
                    if (-not $spf -or -not $dkim.Enabled -or -not $dmarc) {
                        $failDomains += $domain.DomainName
                    }
                }
                if ($failDomains.Count -eq 0) {
                    "PASS (DKIM, SPF, and DMARC are configured for all accepted domains)"
                } else {
                    "FAIL (Missing DKIM, SPF, or DMARC for: $($failDomains -join ', '))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}