function Get-CISM365Control_2_5_8 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.5.8'
        Name        = "Ensure highest priority Anti-Spam and Anti-Phishing policies cover all users, groups, and domains"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Highest priority anti-spam and anti-phishing policies should apply to all relevant users, groups, and domains."
        Rationale   = "Ensures full protection against spam and phishing for all identities."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies?view=o365-worldwide'
        )
        Audit       = {
            try {
                $antiSpamPolicies = Get-HostedContentFilterPolicy
                $antiPhishPolicies = Get-AntiPhishPolicy
                $antiSpamRules = Get-HostedContentFilterRule
                $antiPhishRules = Get-AntiPhishRule
                $allUsers = (Get-Mailbox -ResultSize Unlimited | Select-Object -ExpandProperty UserPrincipalName)
                $spamCovered = @()
                foreach ($rule in $antiSpamRules) { $spamCovered += $rule.Recipients }
                $phishCovered = @()
                foreach ($rule in $antiPhishRules) { $phishCovered += $rule.Recipients }
                $notCoveredSpam = $allUsers | Where-Object { $spamCovered -notcontains $_ }
                $notCoveredPhish = $allUsers | Where-Object { $phishCovered -notcontains $_ }
                if ($notCoveredSpam.Count -eq 0 -and $notCoveredPhish.Count -eq 0) {
                    "PASS (Highest priority anti-spam and anti-phishing policies cover all users)"
                } else {
                    "FAIL (Users not covered: Spam=$($notCoveredSpam -join ', '); Phishing=$($notCoveredPhish -join ', '))"
                }
            }
            catch {
                "MANUAL (Unable to check anti-spam/anti-phishing policy coverage: $($_.Exception.Message))"
            }
        }
    }
}