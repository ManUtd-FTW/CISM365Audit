# Control: 2.4.3 Ensure Microsoft Defender for Cloud Apps is enabled and configured (L2)
# Manual control. Verifies procedures are in place and followed to enable and configure Microsoft Defender for Cloud Apps in Microsoft 365 Defender.
function Get-CISM365Control_2_4_3 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.4.3'
        Name        = 'Ensure Microsoft Defender for Cloud Apps is enabled and configured'
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Defender', 'CloudApps')
        Description = "Microsoft Defender for Cloud Apps is a Cloud Access Security Broker (CASB) providing visibility, detection, and remediation of suspicious activity in Microsoft 365. It integrates with Azure AD Identity Protection for advanced risk detection."
        Rationale   = "Cloud Apps Defender enables security teams to detect, investigate, and respond to suspicious activities targeting Microsoft 365 resources, reducing risk and improving incident response."
        Impact      = "No negative impact. Provides essential monitoring and protection for cloud resources and accounts."
        References  = @(
            'https://learn.microsoft.com/en-us/defender-cloud-apps/connect-office-365',
            'https://learn.microsoft.com/en-us/defender-cloud-apps/connect-azure',
            'https://learn.microsoft.com/en-us/defender-cloud-apps/best-practices',
            'https://learn.microsoft.com/en-us/defender-cloud-apps/get-started',
            'https://learn.microsoft.com/en-us/azure/active-directory/identityprotection/concept-identity-protection-risks'
        )
        Audit = {
            return 'MANUAL: Confirm Microsoft Defender for Cloud Apps is enabled and configured. Ensure Microsoft 365 and Azure are connected, Defender for Endpoint integration is enabled, and file monitoring is checked. See audit steps for details.'
        }
        Remediation = @'
Configure Information Protection and Cloud Discovery:
1. Navigate to Microsoft 365 Defender https://security.microsoft.com/
2. Select Settings > Cloud apps.
3. Scroll to Information Protection and select Files.
4. Check Enable file monitoring.
5. Scroll up to Cloud Discovery and select Microsoft Defender for Endpoint.
6. Check Enforce app access, configure a Notification URL and Save.
Note: Defender for Endpoint requires a Defender for Endpoint license.

Configure App Connectors:
1. Scroll to Connected apps and select App connectors.
2. Click on Connect an app and select Microsoft 365.
3. Check all Azure and Office 365 boxes then click Connect Office 365.
4. Repeat for the Microsoft Azure application.
'@
        Evidence    = '' # Optionally add evidence after manual review
        Status      = 'MANUAL: Confirm Microsoft Defender for Cloud Apps is enabled and configured, including app connectors, endpoint integration, and file monitoring.'
    }
}