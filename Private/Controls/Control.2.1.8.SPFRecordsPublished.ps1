# Control: 2.1.8 Ensure that SPF records are published for all Exchange Domains (L1)
# Manual control. Checks that each accepted domain has the appropriate SPF record.
function Get-CISM365Control_2_1_8 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.1.8'
        Name        = 'Ensure that SPF records are published for all Exchange Domains'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Exchange')
        Description = 'For each domain configured in Exchange, verify a Sender Policy Framework (SPF) TXT record exists and includes "include:spf.protection.outlook.com" so Exchange Online Protection is designated as a permitted sender for that domain.'
        Rationale   = 'SPF records help mail systems determine whether email claiming to be from your domain is legitimate, reducing spoofing and improving spam handling.'
        Impact      = 'Minimal impact expected, but improper SPF setup may cause email to be flagged as spam.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-spf-configure?view=o365-worldwide',
            'https://docs.microsoft.com/en-us/office365/SecurityCompliance/set-up-spf-in-office-365-to-help-prevent-spoofing'
        )
        Audit = {
            # Manual control: Always return MANUAL: at the start for color coding
            return 'MANUAL: Review all accepted domains in Exchange. Ensure an SPF TXT record exists for each domain, including "include:spf.protection.outlook.com". See audit steps for details.'
        }
        Remediation = @'
To set up SPF records for Exchange Online accepted domains:
1. If all email is sent/received via Exchange Online, add the following TXT record for each Accepted Domain:
   v=spf1 include:spf.protection.outlook.com -all
2. If other systems send mail for the domain, refer to:
   https://docs.microsoft.com/en-us/office365/SecurityCompliance/set-up-spf-in-office-365-to-help-prevent-spoofing
'@
        Evidence    = '' # Optionally add evidence after manual review
        Status      = 'MANUAL: Review SPF DNS records for all accepted domains.'
    }
}