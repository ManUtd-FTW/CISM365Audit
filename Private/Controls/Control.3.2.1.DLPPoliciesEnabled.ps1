# Control: 3.2.1 Ensure DLP policies are enabled (L1)
# Manual control. Verifies that Data Loss Prevention (DLP) policies are enabled in Microsoft Purview for Exchange Online and SharePoint Online content.
function Get-CISM365Control_3_2_1 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '3.2.1'
        Name        = "Ensure DLP policies are enabled"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Microsoft365', 'ExchangeOnline', 'SharePointOnline', 'Purview')
        Description = "Data Loss Prevention (DLP) policies scan Exchange Online and SharePoint Online content for sensitive data (e.g. SSNs, credit cards, passwords) and help prevent accidental exposure."
        Rationale   = "DLP policies help protect sensitive data by alerting users/admins when specific types of data are detected, reducing accidental exposure risk."
        Impact      = "Enabling DLP may block or alert on sensitive data in communications. Proper testing and deployment procedures should be followed."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/dlp-learn-aboutdlp?view=o365-worldwide'
        )
        Audit = {
            return "MANUAL: Confirm Data Loss Prevention (DLP) policies exist and are enabled in Microsoft Purview. See audit steps for details."
        }
        Remediation = @'
To enable DLP policies:
1. Go to Microsoft Purview https://compliance.microsoft.com.
2. Under Solutions, select Data loss prevention, then Policies.
3. Click Create policy and follow the wizard.
'@
        Evidence    = '' # Optionally add evidence after manual review
        Status      = "MANUAL: Confirm DLP policies exist and are enabled."
    }
}