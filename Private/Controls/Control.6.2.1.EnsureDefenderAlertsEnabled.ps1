function Get-CISM365Control_6_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.2.1'
        Name        = "Ensure Microsoft Defender alerts are enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Microsoft Defender alerts should be enabled to notify security teams of threats and incidents."
        Rationale   = "Timely alerts are critical for rapid incident response."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/defender-alerts?view=o365-worldwide'
        )
        Audit       = {
            try {
                $settings = Get-MgSecurityAlertSetting
                if ($settings.IsEnabled -eq $true) {
                    "PASS (Microsoft Defender alerts are enabled)"
                } else {
                    "FAIL (Microsoft Defender alerts are NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check Defender alerts status: $($_.Exception.Message))"
            }
        }
    }
}