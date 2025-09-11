function Get-CISM365Control_8_6_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.6.1'
        Name        = "Ensure users can report security concerns in Teams"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Teams','Defender')
        Description = @'
Enables user reporting of malicious messages in Teams for further analysis. Ensures reports go only to authorized staff, not Microsoft by default.
'@
        Rationale   = @'
Allows users to alert admins of suspicious or malicious messages, supporting security operations.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/submissions-teams?view=o365-worldwide'
        )
        Audit = {
            try {
                $policy = Get-CsTeamsMessagingPolicy -Identity Global
                $reportEnabled = ($policy.AllowSecurityEndUserReporting -eq $true)
                # For Defender, you would typically use Get-ReportSubmissionPolicy (requires ExchangeOnlineManagement module)
                $defenderPolicy = $null
                try {
                    $defenderPolicy = Get-ReportSubmissionPolicy -Identity "DefaultReportSubmissionPolicy"
                }
                catch { }
                $defenderDest = $false
                if ($defenderPolicy) {
                    $defenderDest = ($defenderPolicy.ReportChatMessageToCustomizedAddressEnabled -eq $true)
                }
                if ($reportEnabled -and $defenderDest) {
                    "PASS (Teams security reporting enabled and goes to authorized mailbox)"
                } elseif (-not $reportEnabled) {
                    "FAIL (Teams message reporting not enabled)"
                } else {
                    "FAIL (Teams reporting enabled, but Defender not configured for custom mailbox)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}