# Control: 2.1.10 Ensure DMARC Records for all Exchange Online domains are published (L1)
# Manual control. Checks that each accepted domain has a DMARC record.
function Get-CISM365Control_2_1_10 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.1.10'
        Name        = 'Ensure DMARC Records for all Exchange Online domains are published'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Exchange')
        Description = 'For each domain configured in Exchange Online, verify a DMARC TXT record exists at _dmarc.domain.com and begins with "v=DMARC1;". DMARC helps recipient mail systems determine how to handle messages failing SPF or DKIM authentication.'
        Rationale   = 'DMARC strengthens the trustworthiness of messages sent from your domain, especially when combined with SPF and DKIM, helping to prevent spoofing and phishing.'
        Impact      = 'No expected mail flow impact, but organizations should ensure DMARC is set up appropriately for their environment.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dmarc-configure?view=o365-worldwide'
        )
        Audit = {
            return 'MANUAL: Review all accepted domains in Exchange Online. Ensure a DMARC TXT record exists at _dmarc.domain.com, beginning with "v=DMARC1;". See audit steps for details.'
        }
        Remediation = @'
To add DMARC records:
1. For each Exchange Online Accepted Domain, add to DNS:
   Record:  _dmarc.domain.com
   Type:    TXT
   Value:   v=DMARC1; p=none;
2. This creates a basic DMARC policy to audit compliance.
'@
        Evidence    = '' # Optionally add evidence after manual review
        Status      = 'MANUAL: Review DMARC DNS records for all accepted domains.'
    }
}