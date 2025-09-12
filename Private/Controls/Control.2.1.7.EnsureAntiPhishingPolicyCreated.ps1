function Get-CISM365Control_2_1_7 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.1.7'
        Name        = "Ensure that an anti-phishing policy has been created"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Office365 AntiPhish Default policy should exist and be enabled, with threshold at least 2 (Aggressive), and mailbox/sender intelligence features enabled."
        Rationale   = "Anti-phishing policy with impersonation and spoof intelligence provides essential protection."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies?view=o365-worldwide'
        )
        Audit       = {
            try {
                $policies = Get-AntiPhishPolicy | Where-Object {
                    $_.Enabled -eq $true -and
                    $_.PhishThresholdLevel -ge 2 -and
                    $_.EnableMailboxIntelligenceProtection -eq $true -and
                    $_.EnableMailboxIntelligence -eq $true -and
                    $_.EnableSpoofIntelligence -eq $true
                }
                if ($policies) {
                    "PASS (Anti-phishing policy created and enabled with recommended settings)"
                } else {
                    "FAIL (No anti-phishing policy created or settings are not compliant)"
                }
            }
            catch {
                "MANUAL (Unable to check anti-phishing policy: $($_.Exception.Message))"
            }
        }
    }
}