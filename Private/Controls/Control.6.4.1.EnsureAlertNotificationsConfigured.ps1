function Get-CISM365Control_6_4_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.4.1'
        Name        = "Ensure alert notifications are configured for security teams"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Alert notifications should be configured to notify security teams of critical incidents via email or integration with ticketing systems."
        Rationale   = "Notification ensures immediate attention to security incidents."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/defender/alerts-notifications?view=o365-worldwide'
        )
        Audit       = {
            try {
                $notifications = Get-MgSecurityAlertNotification | Where-Object { $_.Enabled -eq $true }
                if ($notifications.Count -gt 0) {
                    "PASS (Alert notifications are configured for security teams)"
                } else {
                    "FAIL (No alert notifications configured for security teams)"
                }
            }
            catch {
                "MANUAL (Unable to check alert notification configuration: $($_.Exception.Message))"
            }
        }
    }
}