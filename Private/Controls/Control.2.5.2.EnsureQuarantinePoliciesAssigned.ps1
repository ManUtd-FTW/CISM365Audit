function Get-CISM365Control_2_5_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.5.2'
        Name        = "Ensure Quarantine Policies are assigned and enforced"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('ExchangeOnline', 'Defender')
        Description = "High-risk malware and phishing policies should use proper quarantine policies, such as AdminOnlyAccessPolicy."
        Rationale   = "Quarantine policies restrict access to malicious messages and enable secure admin review."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-policies?view=o365-worldwide'
        )
        Audit       = @"
Manual Audit Steps (as of 9/12/2025):
1. Go to https://security.microsoft.com/quarantine.
2. In the Quarantine Policies section, review all policies and their assigned access (e.g., AdminOnlyAccessPolicy).
3. In Defender > Policies > Threat policies > Anti-phishing and Anti-malware, review each rule and confirm quarantine policies are assigned as required.
4. Verify that high-risk rules (malware, phishing) use 'AdminOnlyAccessPolicy' or other restrictive quarantine policy.
5. Document any rules not using restrictive quarantine policies.
"@
    }
}