function Get-CISM365Control_2_1_11 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '2.1.11'
        Name        = 'Ensure the spoofed domains report is reviewed weekly'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender','ExchangeOnline')
        Description = @'
Spoof intelligence in the Security Center allows administrators to review senders spoofing organization domains or external domains. The spoofed domains report should be reviewed weekly to identify and mitigate phishing techniques.
'@
        Rationale   = @'
Reviewing the spoofed domains report helps identify current spoofing activities, informs administrators and end users, and supports planning against phishing campaigns.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/antispoofing-spoof-intelligence?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/powershell/module/exchange/getspoofintelligenceinsight?view=exchange-ps'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Confirm procedures exist and are followed to review spoofed domains report at least weekly.",
                    "",
                    "To manually review the report:",
                    "  • Navigate to Microsoft 365 Defender: https://security.microsoft.com",
                    "  • Under Email & collaboration, click Policies & rules > Threat policies.",
                    "  • Under Rules, select Tenant Allow / Block Lists > Spoofed senders.",
                    "  • Review the findings.",
                    "",
                    "To view spoofed senders via PowerShell for the last 7 days:",
                    "  • Connect to Exchange Online using Connect-ExchangeOnline.",
                    "  • Run: Get-SpoofIntelligenceInsight",
                    "  • Review the results."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify the spoofed domains report is being reviewed at least weekly, using either the Security Center or Exchange Online PowerShell.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}