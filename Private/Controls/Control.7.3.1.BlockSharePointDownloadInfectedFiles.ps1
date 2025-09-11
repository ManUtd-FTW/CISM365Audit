function Get-CISM365Control_7_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.3.1'
        Name        = "Ensure Office 365 SharePoint infected files are disallowed for download"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('SharePoint','OneDrive','Teams')
        Description = @'
Disallows download of files detected as infected by Defender for Office 365 in SharePoint, OneDrive, and Teams.
'@
        Rationale   = @'
Blocks access to malicious files and reduces risk of infection and data loss.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-attachments-for-spo-odfb-teams-configure?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-malware-protection-for-spo-odfb-teams-about?view=o365-worldwide'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.DisallowInfectedFileDownload -eq $true) {
                    "PASS (Download of infected files is disallowed)"
                } else {
                    "FAIL (Download of infected files is allowed)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}