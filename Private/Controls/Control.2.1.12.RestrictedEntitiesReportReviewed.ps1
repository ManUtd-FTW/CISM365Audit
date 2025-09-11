function Get-CISM365Control_2_1_12 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '2.1.12'
        Name        = "Ensure the 'Restricted entities' report is reviewed weekly"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender','ExchangeOnline')
        Description = @'
The Restricted Entities report in Microsoft 365 Defender provides a list of user accounts restricted from sending email due to exceeding outbound sending limits or outbound spam policy violations. Reviewing this report weekly supports detection and remediation of compromised accounts.
'@
        Rationale   = @'
Consistent review of the restricted users list helps identify compromised accounts and enables timely remediation and unblocking.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365security/responding-to-a-compromised-email-account?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365security/removing-user-from-restricted-users-portal-after-spam?view=o365worldwide',
            'https://learn.microsoft.com/en-us/powershell/module/exchange/getblockedsenderaddress?view=exchange-ps'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Confirm procedures exist and are followed to review the Restricted Entities report at least weekly.",
                    "",
                    "To manually review the report:",
                    "  • Navigate to Microsoft 365 Defender: https://security.microsoft.com",
                    "  • Under Email & collaboration, go to Review > Restricted Entities.",
                    "  • Review alerts and take appropriate action after remediation.",
                    "",
                    "To view restricted users via PowerShell:",
                    "  • Connect to Exchange Online using Connect-ExchangeOnline.",
                    "  • Run: Get-BlockedSenderAddress",
                    "  • Review the results."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify the 'Restricted entities' report is reviewed at least weekly, using the Microsoft 365 Defender portal or Exchange Online PowerShell.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}