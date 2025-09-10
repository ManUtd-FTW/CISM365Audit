# Control: 2.1.12 Ensure the 'Restricted entities' report is reviewed weekly (L1)
# Manual control. Verifies that procedures exist and are followed for weekly review of the restricted entities report.
function Get-CISM365Control_2_1_12 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.1.12'
        Name        = "Ensure the 'Restricted entities' report is reviewed weekly"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender', 'Exchange')
        Description = "Microsoft 365 Defender's review of Restricted Entities provides a list of user accounts restricted from sending email due to exceeding outbound sending limits or being flagged by outbound spam policies. Restricted users can still receive email."
        Rationale   = "Users listed as restricted have a high probability of account compromise. Regular review enables timely remediation and unblocking of affected accounts."
        Impact      = "No negative impact. Ensures compromised accounts are remediated promptly."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/responding-to-a-compromised-email-account?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/removing-user-from-restricted-users-portal-after-spam?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/powershell/module/exchange/getblockedsenderaddress?view=exchange-ps'
        )
        Audit = {
            return "MANUAL: Confirm weekly review of the 'Restricted entities' report. Ensure procedures are in place and followed. See audit steps for details."
        }
        Remediation = @'
To review the report of users restricted from sending email due to spamming:
1. Navigate to Microsoft 365 Defender https://security.microsoft.com.
2. Under Email & collaboration, go to Review.
3. Click Restricted Entities.
4. Review alerts and remediate/unblock accounts as appropriate.

To review via PowerShell:
1. Connect to Exchange Online using Connect-ExchangeOnline.
2. Run: Get-BlockedSenderAddress
3. Review the output.
'@
        Evidence    = '' # Optionally add evidence of weekly review
        Status      = "MANUAL: Confirm weekly review of the 'Restricted entities' report and document procedures."
    }
}