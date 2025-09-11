function Get-CISM365Control_6_4_1 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '6.4.1'
        Name        = "Ensure mail forwarding rules are reviewed at least weekly"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('ExchangeOnline')
        Description = @'
Review mail forwarding rules in Exchange Online at least weekly to detect attempts at data exfiltration via forwarding rules, delegates, or SMTP forwarding.
'@
        Rationale   = @'
Regular review helps identify unauthorized forwarding which could indicate malicious activity or account compromise.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/outbound-spam-policies-external-email-forwarding?view=o365-worldwide'
        )
        Audit = {
            try {
                $steps = @(
                    "UI:",
                    "1. Exchange admin center > Reports > Mail flow > Auto forwarded messages report.",
                    "2. Review.",
                    "",
                    "PowerShell:",
                    "1. Connect to Exchange Online using Connect-ExchangeOnline.",
                    "2. Run:",
                    "$allUsers = Get-User -ResultSize Unlimited -Filter {RecipientTypeDetails -eq 'UserMailbox' } | Where-Object {$_.AccountDisabled -like 'False'}",
                    "$UserInboxRules = @()",
                    "$UserDelegates = @()",
                    "foreach ($User in $allUsers) {",
                    "  $UserInboxRules += Get-InboxRule -Mailbox $User.UserPrincipalName | Where-Object { ($_.ForwardTo -ne $null) -or ($_.ForwardAsAttachmentTo -ne $null) -or ($_.RedirectsTo -ne $null) }",
                    "  $UserDelegates += Get-MailboxPermission -Identity $User.UserPrincipalName | Where-Object { ($_.IsInherited -ne 'True') -and ($_.User -notlike '*SELF*') }",
                    "}",
                    "$SMTPForwarding = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.ForwardingSMTPAddress -ne $null}",
                    "Export findings to CSV for review."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Confirm mail forwarding rules are reviewed weekly in Exchange Online.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}