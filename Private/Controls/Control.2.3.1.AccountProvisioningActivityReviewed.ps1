# Control: 2.3.1 Ensure the Account Provisioning Activity report is reviewed at least weekly (L1)
# Manual control. Verifies that procedures exist and are followed for weekly review of the Account Provisioning Activity report.
function Get-CISM365Control_2_3_1 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.3.1'
        Name        = 'Ensure the Account Provisioning Activity report is reviewed at least weekly'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender', 'Exchange')
        Description = 'The Account Provisioning Activity report details any account provisioning attempted by an external application. It should be reviewed at least weekly to detect illicit or unusual provisioning activity.'
        Rationale   = "If the organization does not use a third party provider to manage accounts, any entry is likely illicit. If a third party provider is used, monitor for unusual transaction volumes or new/unusual applications managing users."
        Impact      = "No negative impact. Helps detect unauthorized account provisioning and supports incident response."
        References  = @(
            'https://security.microsoft.com'
        )
        Audit = {
            return 'MANUAL: Confirm weekly review of the Account Provisioning Activity report. Ensure procedures are in place and followed. See audit steps for details.'
        }
        Remediation = @'
To review the Account Provisioning Activity report:
1. Navigate to Microsoft 365 Defender https://security.microsoft.com.
2. Click on Audit.
3. Set Activities to Added user for User administration activities.
4. Set Start Date and End Date.
5. Click Search.
6. Review.

To review Account Provisioning Activity report using PowerShell:
1. Connect to Exchange Online using Connect-ExchangeOnline.
2. Run:
   $startDate = ((Get-date).AddDays(-7)).ToShortDateString()
   $endDate = (Get-date).ToShortDateString()
   Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate | Where-Object { $_.Operations -eq "add user." }
'@
        Evidence    = '' # Optionally add evidence of weekly review
        Status      = 'MANUAL: Confirm weekly review of the Account Provisioning Activity report and document procedures.'
    }
}