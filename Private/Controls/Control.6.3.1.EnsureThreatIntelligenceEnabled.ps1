function Get-CISM365Control_6_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.3.1'
        Name        = "Ensure threat intelligence integration is enabled"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Threat intelligence feeds should be integrated and enabled in Microsoft 365 Security Center."
        Rationale   = "Threat intelligence enables proactive defense and rapid response to emerging threats."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/defender/threat-intelligence?view=o365-worldwide'
        )
        Audit       = {
            try {
                $feeds = Get-MgSecurityThreatIntelligenceIndicator | Where-Object { $_.Enabled -eq $true }
                if ($feeds.Count -gt 0) {
                    "PASS (Threat intelligence integration is enabled)"
                } else {
                    "FAIL (No enabled threat intelligence feeds found)"
                }
            }
            catch {
                "MANUAL (Unable to check threat intelligence status: $($_.Exception.Message))"
            }
        }
    }
}