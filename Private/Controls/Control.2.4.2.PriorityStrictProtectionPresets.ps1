# Control: 2.4.2 Ensure Priority accounts have 'Strict protection' presets applied (L1)
# Manual control. Verifies that procedures exist and are followed to apply 'Strict protection' preset security policies to Priority accounts/groups in Microsoft 365 Defender.
function Get-CISM365Control_2_4_2 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.4.2'
        Name        = "Ensure Priority accounts have 'Strict protection' presets applied"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender', 'Exchange')
        Description = "Ensure that Microsoft's Strict protection preset security policies are applied to priority accounts/groups in Microsoft 365 Defender. Strict protection provides the most aggressive defense against spam, malware, phishing, spoofing, impersonation, and other threats."
        Rationale   = "Priority accounts (executives, IT admins, etc.) are high-value targets for attackers. Applying Strict protection minimizes risk of account compromise, even if it increases false positives."
        Impact      = "Strict preset security policies may increase false positives, resulting in more messages being flagged as junk or malicious for protected users."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/preset-security-policies?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/security-recommendations-for-priority-accounts',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365worldwide#impersonation-settings-in-anti-phishing-policies-in-microsoft-defenderfor-office-365'
        )
        Audit = {
            return "MANUAL: Confirm Strict protection preset security policies are enabled and applied to all Priority account groups. See audit steps for details."
        }
        Remediation = @'
Enable strict preset security policies for Priority accounts:
1. Navigate to Microsoft 365 Defender https://security.microsoft.com/
2. Expand E-mail & collaboration.
3. Select Policies & rules > Threat policies > Preset security policies.
4. Manage protection settings for Strict protection preset.
5. For Apply Exchange Online Protection, select Specific recipients and include Priority Accounts/Groups.
6. For Apply Defender for Office 365 Protection, select Specific recipients and include Priority Accounts/Groups.
7. For Impersonation protection, add valid email addresses or priority accounts, both internal and external, that may be subject to impersonation.
8. For Protected custom domains, add the organization's domain and other key partners.
9. Confirm and save settings.
'@
        Evidence    = '' # Optionally add evidence after manual review
        Status      = "MANUAL: Confirm Strict protection preset policies are applied to Priority accounts/groups."
    }
}