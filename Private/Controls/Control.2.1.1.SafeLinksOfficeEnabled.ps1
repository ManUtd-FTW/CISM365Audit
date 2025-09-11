function Get-CISM365Control_2_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id = '2.1.1'
        Name = 'Ensure Safe Links for Office Applications is Enabled'
        Profile = 'L1'
        Automated = $true
        Services = @('Graph', 'SecurityCompliance')
        Description = 'Safe Links protection should be enabled for Office applications to help prevent malicious link activation.'
        Rationale = 'Safe Links provides time-of-click verification of URLs, helping to protect users from malicious links in Office documents.'
        References = @(
            'https://learn.microsoft.com/microsoft-365/security/office-365-security/safe-links',
            'https://www.tenable.com/audits/CIS_Microsoft_365_Foundations_v5.0.0_L1_E3'
        )
        Notes = 'This control checks if Safe Links protection is enabled for Office applications via policy settings.'

        Audit = {
            try {
                # Load helper if available
                try {
                    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
                    $helperPath = Join-Path $scriptDir 'Helper-GetTenant.ps1'
                    if (Test-Path $helperPath) {
                        try { . $helperPath } catch {}
                    }
                } catch {}

                # Get Safe Links policies
                $policies = Get-SafeLinksPolicy -ErrorAction SilentlyContinue
                if (-not $policies -or $policies.Count -eq 0) {
                    return 'MANUAL (No Safe Links policies found)'
                }

                # Check if any policy has Office apps protection enabled
                $violations = @()
                foreach ($policy in $policies) {
                    if (-not $policy.EnableSafeLinksForOffice) {
                        $violations += $policy.Name
                    }
                }

                if ($violations.Count -eq 0) {
                    return "PASS (All Safe Links policies have Office protection enabled)"
                } else {
                    $sample = ($violations | Select-Object -First 5) -join ', '
                    return "FAIL ($($violations.Count) policy(ies) missing Office protection: $sample)"
                }
            } catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}
