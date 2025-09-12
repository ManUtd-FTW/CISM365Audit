# Control: 3.2.2 Ensure DLP policies are enabled for Microsoft Teams (L1)
# Manual control. Verifies that Data Loss Prevention (DLP) policies are enabled for Microsoft Teams in Microsoft Purview.
function Get-CISM365Control_3_2_2 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '3.2.2'
        Name        = "Ensure DLP policies are enabled for Microsoft Teams"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Microsoft365', 'Teams', 'Purview')
        Description = "Default Teams DLP policy in Microsoft 365 prevents accidental sharing of sensitive information in Teams conversations and channels."
        Rationale   = "Enabling Teams DLP policies protects sensitive information from being shared or leaked in Teams chats and channels."
        Impact      = "End-users may have sharing restrictions for sensitive content in Teams. Admins may receive requests to adjust DLP policies."
        References  = @(
            'https://learn.microsoft.com/en-us/powershell/exchange/connect-to-sccpowershell?view=exchange-ps',
            'https://learn.microsoft.com/en-us/powershell/exchange/exchange-onlinepowershell-v2?view=exchange-ps#turn-on-basic-authentication-in-winrm',
            'https://learn.microsoft.com/en-us/powershell/module/exchange/connectippssession?view=exchange-ps'
        )
        Audit = {
            return "MANUAL: Confirm in Microsoft Purview that the Default policy for Teams Status is On. Using PowerShell, verify DLP policies are present and TeamsLocation is set for all required users. See audit steps for details."
        }
        Remediation = @'
To enable DLP policies for Teams:
1. Go to Microsoft Purview compliance portal https://compliance.microsoft.com.
2. Under Solutions, select Data loss prevention > Policies tab.
3. Edit Default policy for Teams.
4. Ensure Teams chat and channel messages location is On.
5. Ensure Default Teams DLP policy rule Status is On.
6. Select "Turn it on right away" and submit policy.
'@
        Evidence    = '' # Optionally add evidence after manual review
        Status      = "MANUAL: Confirm DLP policies for Teams are enabled and applied to all users."
    }
}