function Get-CISM365Control_1_1_2 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.1.2'
        Name        = 'Ensure two emergency access accounts have been defined'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('AdminCenter','EntraID')
        Description = @'
Emergency access, or "break glass" accounts, are limited-use accounts for emergency scenarios where normal administrative accounts are unavailable. These accounts are not assigned to a specific user, and must have physical and technical controls to prevent access outside of true emergencies. Ensure two such accounts are defined according to Microsoft best practices.
'@
        Rationale   = @'
A break glass account allows organizations to retain access in emergency scenarios (e.g., MFA failures, loss of last Global Admin). Without these, organizations may lose administrative access, impacting support and security posture.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/roles/securityplanning#stage-1-critical-items-to-do-right-now',
            'https://learn.microsoft.com/en-us/azure/active-directory/roles/securityemergency-access'
        )
        Audit = {
            try {
                $steps = @(
                    "Step 1 - Policy & Procedures:",
                    "  • Ensure policies/procedures for emergency access accounts are authorized/distributed by senior management.",
                    "  • FIDO2 keys (if used) stored securely in a fireproof location.",
                    "  • Passwords are at least 16 characters, randomly generated, and may be split for emergency assembly.",
                    "",
                    "Step 2 - Define two emergency access accounts:",
                    "  1. Sign in to Microsoft 365 admin center: https://admin.microsoft.com",
                    "  2. Go to Users > Active Users",
                    "  3. Inspect emergency access accounts:",
                    "     • Not named for a person.",
                    "     • Use default .onmicrosoft.com domain.",
                    "     • Cloud-only, unlicensed, assigned Global Admin role.",
                    "",
                    "Step 3 - Conditional Access exclusion:",
                    "  1. Sign in to Microsoft Entra admin center: https://entra.microsoft.com/",
                    "  2. Go to Azure Active Directory > Protect & Secure > Conditional Access",
                    "  3. Confirm at least one emergency account is excluded from all rules."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify two emergency access accounts exist, meet break glass criteria, and at least one is excluded from Conditional Access rules.`nAudit steps:`n$joined`nDefault: Not defined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}