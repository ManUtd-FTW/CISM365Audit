function Get-CISM365Control_2_1_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.1.2'
        Name        = "Ensure the Common Attachment Types Filter is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Anti-malware policies should block common malicious file types in emails."
        Rationale   = "Blocking risky file types prevents malware infections via email."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-malware-policies-configure?view=o365-worldwide'
        )
        Audit       = {
            try {
                $policy = Get-MalwareFilterPolicy -Identity Default
                if ($policy.EnableFileFilter) {
                    "PASS (Common Attachment Types Filter is enabled)"
                } else {
                    "FAIL (Common Attachment Types Filter is NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check malware filter policy: $($_.Exception.Message))"
            }
        }
    }
}