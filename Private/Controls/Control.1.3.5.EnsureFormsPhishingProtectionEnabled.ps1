function Get-CISM365Control_1_3_5 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.5'
        Name        = "Ensure internal phishing protection for Forms is enabled"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('AdminCenter')
        Description = 'Enable internal phishing protection for Microsoft Forms.'
        Rationale   = 'Prevents use of Forms for phishing or malicious data collection.'
        References  = @(
            'https://learn.microsoft.com/en-US/microsoft-forms/administrator-settings-microsoft-forms'
        )
        Audit = {
            try {
                $steps = @(
                    "Step 1: Review settings in the UI:",
                    "  1. Navigate to Microsoft 365 admin center: https://admin.microsoft.com/",
                    "  2. Expand Settings > Org settings > Services > Microsoft Forms.",
                    "  3. Ensure 'Add internal phishing protection' is checked under Phishing protection."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Ensure internal phishing protection for Forms is enabled.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}