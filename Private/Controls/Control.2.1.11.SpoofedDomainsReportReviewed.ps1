# Control: 2.1.11 Ensure the spoofed domains report is reviewed weekly (L1)
# Manual control. Verifies that procedures exist and are followed for weekly review of the spoofed domains report.
function Get-CISM365Control_2_1_11 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.1.11'
        Name        = 'Ensure the spoofed domains report is reviewed weekly'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender', 'Exchange')
        Description = 'Use spoof intelligence in Microsoft 365 Defender to review all senders who are spoofing either domains that are part of the organization or spoofing external domains. Spoof intelligence is available as part of Office 365 E5, Defender for Office 365, and Exchange Online Protection (EOP).'
        Rationale   = 'Reviewing spoofed domains helps message administrators identify phishing techniques and current activities by bad actors, allowing better end-user education and campaign planning.'
        Impact      = 'No negative impact. Ensures administrators stay informed about spoofing activities targeting the organization.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/antispoofing-spoof-intelligence?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/powershell/module/exchange/getspoofintelligenceinsight?view=exchange-ps'
        )
        Audit = {
            return 'MANUAL: Confirm weekly review of the spoofed domains report. Ensure procedures are in place and followed. See audit steps for details.'
        }
        Remediation = @'
To review the spoofed domains report:
1. Navigate to Microsoft 365 Defender https://security.microsoft.com.
2. Under Email & collaboration click on Policies & rules then select Threat policies.
3. Under Rules click Tenant Allow / Block Lists then select Spoofed senders.
4. Review the report.

To view spoofed senders allowed or blocked in the last 7 days:
1. Connect to Exchange Online using Connect-ExchangeOnline.
2. Run: Get-SpoofIntelligenceInsight
3. Review the output.
'@
        Evidence    = '' # Optionally add evidence of weekly review
        Status      = 'MANUAL: Confirm weekly review of spoofed domains report and document procedures.'
    }
}