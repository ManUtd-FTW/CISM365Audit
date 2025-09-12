function Get-CISM365Control_1_3_8 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.8'
        Name        = "Ensure that Sways cannot be shared with people outside of your organization"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AdminCenter')
        Description = 'Disable external sharing of Sway documents to prevent leaks of sensitive information.'
        Rationale   = 'Limits risk of data spillage through externally shared Sway content.'
        References  = @(
            'https://support.microsoft.com/en-us/office/administrator-settings-for-sway-d298e79b-b6ab-44c6-9239-aa312f5784d4'
        )
        Audit = {
            try {
                $steps = @(
                    "Step 1: Review Sway settings in the UI:",
                    "  1. Navigate to https://admin.microsoft.com/",
                    "  2. Expand Settings > Org settings > Services > Sway.",
                    "  3. Under Sharing, ensure 'Let people in your organization share their Sways with people outside your organization' is NOT checked."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Ensure Sways cannot be shared externally.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}