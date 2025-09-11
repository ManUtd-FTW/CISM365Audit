function Get-CISM365Control_7_3_3 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '7.3.3'
        Name        = "Ensure custom script execution is restricted on personal sites"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('SharePoint','OneDrive')
        Description = @'
Prevents users from running custom script on their personal sites and self-service created sites.
'@
        Rationale   = @'
Restricts custom scripting to reduce risk of malicious code and loss of governance.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/allow-or-prevent-custom-script',
            'https://learn.microsoft.com/en-us/sharepoint/security-considerations-of-allowing-custom-script'
        )
        Audit = {
            try {
                $steps = @(
                    "UI:",
                    "1. SharePoint admin center > Settings > Classic settings page.",
                    "2. In Custom Script section, verify 'Prevent users from running custom script on personal sites' and 'on self-service created sites' are set."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify custom script execution is restricted on personal sites in SharePoint and OneDrive.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}