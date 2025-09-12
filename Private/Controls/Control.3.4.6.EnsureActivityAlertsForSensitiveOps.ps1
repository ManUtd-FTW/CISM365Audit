function Get-CISM365Control_3_4_6 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.4.6'
        Name        = "Ensure activity alerts for sensitive operations are configured"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ComplianceCenter')
        Description = "Alerts should be configured for sensitive operations, such as admin role changes, DLP events, and label changes."
        Rationale   = "Alerts enable rapid response to high-risk changes or events."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/create-activity-alerts?view=o365-worldwide'
        )
        Audit       = {
            try {
                $alerts = Get-ActivityAlert
                $sensitiveAlerts = $alerts | Where-Object {
                    $_.Enabled -eq $true -and (
                        $_.AlertType -match 'AdminRoleChange' -or
                        $_.AlertType -match 'DLPEVENT' -or
                        $_.AlertType -match 'LabelChange'
                    )
                }
                if ($sensitiveAlerts.Count -gt 0) {
                    "PASS (Sensitive activity alerts configured: $($sensitiveAlerts | Select-Object -ExpandProperty Name -join ', '))"
                } else {
                    "FAIL (No sensitive activity alerts configured)"
                }
            }
            catch {
                "MANUAL (Unable to check activity alert configuration: $($_.Exception.Message))"
            }
        }
    }
}