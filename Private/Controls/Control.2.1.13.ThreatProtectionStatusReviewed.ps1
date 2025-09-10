# Control: 2.1.13 Ensure all security threats in the Threat protection status report are reviewed at least weekly (L1)
# Manual control. Verifies that procedures exist and are followed for weekly review of the Threat protection status report.
function Get-CISM365Control_2_1_13 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.1.13'
        Name        = 'Ensure all security threats in the Threat protection status report are reviewed at least weekly'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender')
        Description = 'The Threat protection status report shows instances of Microsoft blocking malware, phishing, impersonation, etc. This report should be reviewed at least weekly in Microsoft 365 Defender.'
        Rationale   = "Regular review of the Threat protection status report gives administrators insight into the overall volume and types of security threats targeting users, supporting more informed security decisions."
        Impact      = "No negative impact. Promotes proactive monitoring and threat mitigation."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/reports-email-security?view=o365-worldwide'
        )
        Audit = {
            return 'MANUAL: Confirm weekly review of the Threat protection status report. Ensure procedures are in place and followed. See audit steps for details.'
        }
        Remediation = @'
To review the Threat protection status report:
1. Navigate to Microsoft 365 Defender https://security.microsoft.com.
2. Click to expand Email & collaboration, select Review.
3. Select Malware trends.
4. On the Threat Explorer page, select All email and review statistics.
'@
        Evidence    = '' # Optionally add evidence of weekly review
        Status      = 'MANUAL: Confirm weekly review of the Threat protection status report and document procedures.'
    }
}