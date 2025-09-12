function Get-CISM365Control_6_2_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.2.2'
        Name        = "Ensure automated incident response is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Automated incident response features (playbooks, workflows) should be enabled for Microsoft 365 security incidents."
        Rationale   = "Automation reduces response time and improves consistency."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/sentinel/incident-automation'
        )
        Audit       = {
            try {
                $playbooks = Get-MgSecurityPlaybook | Where-Object { $_.Enabled -eq $true }
                if ($playbooks.Count -gt 0) {
                    "PASS (Automated incident response playbooks are enabled)"
                } else {
                    "FAIL (No automated incident response playbooks enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check automated incident response status: $($_.Exception.Message))"
            }
        }
    }
}