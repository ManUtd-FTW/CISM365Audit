function Get-CISM365Control_6_1_4 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '6.1.4'
        Name        = "Ensure 'AuditBypassEnabled' is not enabled on mailboxes"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('ExchangeOnline')
        Description = @'
Ensure AuditBypassEnabled is not enabled for any mailbox. Audit bypass allows a user or computer account to access mailboxes without logging actions in the mailbox audit log, which poses a risk for undetected activity.
'@
        Rationale   = @'
Disabling AuditBypassEnabled ensures all mailbox access is logged, supporting incident response and forensics.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/powershell/module/exchange/get-mailboxauditbypassassociation?view=exchange-ps'
        )
        Audit = {
            try {
                $steps = @(
                    "PowerShell:",
                    "1. Connect to Exchange Online using Connect-ExchangeOnline.",
                    "2. Run:",
                    "$MBX = Get-MailboxAuditBypassAssociation -ResultSize unlimited",
                    "$MBX | where {$_.AuditBypassEnabled -eq $true} | Format-Table Name,AuditBypassEnabled",
                    "3. If nothing is returned, then AuditBypass is not enabled for any account."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify AuditBypassEnabled is not enabled for any mailbox account.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}