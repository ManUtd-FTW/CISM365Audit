function Get-CISM365Control_2_5_9 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.5.9'
        Name        = "Ensure Safe Links/Safe Attachments policies include all users, domains, and apps"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Safe Links and Safe Attachments policies should be assigned to all users, domains, and relevant apps for complete coverage."
        Rationale   = "Ensures protection against malicious links and attachments across all collaboration channels."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-links-policies-configure?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-attachments-policies-configure?view=o365-worldwide'
        )
        Audit       = {
            try {
                $safeLinksRules = Get-SafeLinksRule
                $safeAttachmentsRules = Get-SafeAttachmentRule
                $allDomains = (Get-AcceptedDomain | Select-Object -ExpandProperty Name)
                $slDomains = @()
                foreach ($rule in $safeLinksRules) { $slDomains += $rule.RecipientDomainIs }
                $saDomains = @()
                foreach ($rule in $safeAttachmentsRules) { $saDomains += $rule.RecipientDomainIs }
                $notCoveredSL = $allDomains | Where-Object { $slDomains -notcontains $_ }
                $notCoveredSA = $allDomains | Where-Object { $saDomains -notcontains $_ }
                if ($notCoveredSL.Count -eq 0 -and $notCoveredSA.Count -eq 0) {
                    "PASS (Safe Links and Safe Attachments policies cover all domains)"
                } else {
                    "FAIL (Domains not covered: SafeLinks=$($notCoveredSL -join ', '); SafeAttachments=$($notCoveredSA -join ', '))"
                }
            }
            catch {
                "MANUAL (Unable to check Safe Links/Safe Attachments policy coverage: $($_.Exception.Message))"
            }
        }
    }
}