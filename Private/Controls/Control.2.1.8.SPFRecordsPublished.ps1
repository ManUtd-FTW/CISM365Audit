function Get-CISM365Control_2_1_8 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '2.1.8'
        Name        = 'Ensure that SPF records are published for all Exchange Domains'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('ExchangeOnline','DNS')
        Description = @'
For each Exchange domain, a Sender Policy Framework (SPF) record should be created to designate allowed senders and help prevent spoofing.
'@
        Rationale   = @'
SPF records allow Exchange Online Protection and other mail systems to verify the source of messages, helping to prevent spoofing and improve email security.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365security/email-authentication-spf-configure?view=o365-worldwide'
        )
        Audit = {
            try {
                $steps = @(
                    "Option 1 - Command Line:",
                    "  1. Open a command prompt.",
                    "  2. Type: nslookup -type=txt domain1.com",
                    "  3. Ensure a value exists and includes: include:spf.protection.outlook.com.",
                    "",
                    "Option 2 - Microsoft Graph API:",
                    "  1. For each domain, call:",
                    "     https://graph.microsoft.com/v1.0/domains/[DOMAIN.COM]/serviceConfigurationRecords",
                    "  2. Ensure a value exists that includes: include:spf.protection.outlook.com."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify that SPF records are published for all Exchange domains and include Exchange Online as a designated sender.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}