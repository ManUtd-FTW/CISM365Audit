function Get-CISM365Control_2_5_6 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.5.6'
        Name        = "Ensure Office Message Encryption is enabled for sensitive emails"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Office Message Encryption (OME) should be enabled for sensitive email messages."
        Rationale   = "OME helps protect confidential information in email messages."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/ome?view=o365-worldwide'
        )
        Audit       = {
            try {
                $omeConfig = Get-OMEConfiguration
                $enabled = $omeConfig | Where-Object { $_.Enabled -eq $true }
                if ($enabled) {
                    "PASS (Office Message Encryption is enabled)"
                } else {
                    "FAIL (Office Message Encryption is NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check Office Message Encryption status: $($_.Exception.Message))"
            }
        }
    }
}