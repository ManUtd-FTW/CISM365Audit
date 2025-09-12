function Get-CISM365Control_6_5_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.5.2'
        Name        = "Ensure alert escalation processes are configured"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Alert escalation rules should be configured to ensure unresolved or critical alerts are prioritized for response."
        Rationale   = "Escalation ensures that critical threats receive appropriate attention."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/sentinel/incident-automation'
        )
        Audit       = {
            try {
                $rules = Get-MgSecurityIncidentEscalationRule | Where-Object { $_.Enabled -eq $true }
                if ($rules.Count -gt 0) {
                    "PASS (Alert escalation processes are configured)"
                } else {
                    "FAIL (No alert escalation processes configured)"
                }
            }
            catch {
                "MANUAL (Unable to check alert escalation configuration: $($_.Exception.Message))"
            }
        }
    }
}