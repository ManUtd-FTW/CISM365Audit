function Get-CISM365Control_5_1_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.1.1'
        Name        = 'Ensure Security Defaults are enabled (if Conditional Access is not in use)'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('AzureAD','Graph')
        Description = @'
Enable Security Defaults for tenants not using custom Conditional Access policies to enforce baseline best practices for identity protection.
'@
        Rationale   = @'
Security Defaults provide basic protection (MFA, legacy auth block, admin restrictions) for organizations without custom policies.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults',
            'https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-policy-common'
        )
        Audit = {
            try {
                $caPolicies = Get-MgConditionalAccessPolicy -All
                $securityDefaults = (Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy).IsEnabled
                if ($caPolicies.Count -eq 0 -and $securityDefaults -eq $true) {
                    "PASS (Security Defaults are enabled; no custom Conditional Access policies detected)"
                } elseif ($caPolicies.Count -gt 0) {
                    "INFO (Custom Conditional Access policies are in use; Security Defaults not required)"
                } else {
                    "FAIL (Security Defaults are not enabled and no custom Conditional Access policies detected)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}