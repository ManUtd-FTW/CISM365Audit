# Control: 2.4.1 Ensure Priority account protection is enabled and configured (L1)
# Manual control. Verifies that procedures exist and are followed to enable and configure Priority Account Protection in Microsoft 365 Defender.
function Get-CISM365Control_2_4_1 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.4.1'
        Name        = 'Ensure Priority account protection is enabled and configured'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender', 'Exchange')
        Description = 'Identify and tag priority accounts (e.g., executives, managers, admins) in Microsoft 365 Defender to utilize advanced custom security features. Enable priority account protection, tag accounts, and configure alert policies for enhanced security.'
        Rationale   = 'Priority accounts are frequently targeted due to their critical roles and access to sensitive data. Enhanced security and alerting reduces risk of compromise and enables faster incident response.'
        Impact      = 'No negative impact. Provides stronger security for high-value accounts and improves incident response.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/admin/setup/priority-accounts',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/security-recommendations-for-priority-accounts'
        )
        Audit = {
            return 'MANUAL: Confirm Priority account protection is enabled, priority accounts are tagged, and alert policies are configured for those accounts. See audit steps for details.'
        }
        Remediation = @'
Remediate with a 3-step process:
Step 1: Enable Priority account protection in Microsoft 365 Defender:
1. Navigate to Microsoft 365 Defender https://security.microsoft.com/
2. Select Settings > E-mail & Collaboration > Priority account protection
3. Ensure Priority account protection is set to On

Step 2: Tag priority accounts:
4. Select User tags
5. Select the PRIORITY ACCOUNT tag and click Edit
6. Add members (users or groups) as needed. Groups recommended.
7. Repeat for additional tags (Finance, HR, etc.).
8. Next and Submit.

Step 3: Configure E-mail alerts for Priority Accounts:
9. Expand E-mail & Collaboration on the left column.
10. Select New Alert Policy
11. Enter a valid policy Name & Description. Set Severity to High and Category to Threat management.
12. Set Activity is to Detected malware in an e-mail message.
13. Mail direction is Inbound.
14. Add Condition and User: recipient tags are chosen priority tags.
15. Select Every time an activity matches the rule.
16. Next and verify valid recipient(s) are selected.
17. Next and select Yes, turn it on right away. Click Submit.
18. Repeat for other activities such as Phishing email detected at time of delivery.
'@
        Evidence    = '' # Optionally add evidence after manual review
        Status      = 'MANUAL: Confirm Priority account protection is enabled, priority accounts are tagged, and alert policies are configured.'
    }
}