# Control: 3.1.1 Ensure Microsoft 365 audit log search is Enabled (L1)
# Automated control. Verifies that audit log search is enabled in Microsoft 365 using Exchange Online PowerShell.
function Get-CISM365Control_3_1_1 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '3.1.1'
        Name        = "Ensure Microsoft 365 audit log search is Enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Microsoft365', 'ExchangeOnline')
        Description = "Audit log search records user and admin activities in Microsoft 365 and retains them for 90 days. Required for security, compliance, and incident response."
        Rationale   = "Enabling audit log search helps organizations meet compliance, improve security, and respond to incidents."
        Impact      = "No negative impact; enables essential auditing."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/audit-log-enabledisable?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/powershell/module/exchange/setadminauditlogconfig?view=exchange-ps'
        )
        Audit = {
            # Returns True if UnifiedAuditLogIngestionEnabled is set to True, otherwise False
            $result = Get-AdminAuditLogConfig | Select-Object -ExpandProperty UnifiedAuditLogIngestionEnabled
            if ($result -eq $true) {
                return "PASS: UnifiedAuditLogIngestionEnabled is True. Audit log search is enabled."
            } else {
                return "FAIL: UnifiedAuditLogIngestionEnabled is False. Audit log search is not enabled."
            }
        }
        Remediation = @'
To enable Microsoft 365 audit log search:
Manual:
1. Go to Microsoft Purview https://compliance.microsoft.com.
2. Select Audit.
3. Click "Start recording user and admin activity" next to the warning at the top.
4. Confirm.

PowerShell:
1. Connect to Exchange Online using Connect-ExchangeOnline.
2. Run: Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
'@
        Evidence    = '' # Optionally add evidence after automated or manual review
        Status      = "AUTOMATED: Checks if UnifiedAuditLogIngestionEnabled is True using Exchange Online PowerShell."
    }
}