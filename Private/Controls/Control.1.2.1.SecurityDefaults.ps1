# Control: 1.2.1 Ensure Security Defaults is enabled (L1)
# Requires: Microsoft Graph (Identity.SignIns) connected by the orchestrator

function Get-CISM365Control_1_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.2.1'
        Name        = "Ensure Security Defaults is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'Security Defaults enforce baseline identity protections such as MFA for administrators.'
        Rationale   = 'Enabling Security Defaults helps protect the tenant from common identity attacks with minimal configuration.'
        References  = @(
            # Security Defaults policy via Microsoft Graph
            'https://learn.microsoft.com/graph/api/identitysecuritydefaultsenforcementpolicy-get?view=graph-rest-1.0',
            # Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy cmdlet
            'https://learn.microsoft.com/powershell/module/microsoft.graph.identity.signins/get-mgpolicyidentitysecuritydefaultenforcementpolicy?view=graph-powershell-1.0'
        )
        Audit       = {
            try {
                $policy = Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy -ErrorAction Stop
                if ($null -eq $policy) {
                    return 'MANUAL (Security Defaults policy not returned by Graph)'
                }

                if ($policy.IsEnabled) {
                    'PASS (Security Defaults enabled)'
                } else {
                    'FAIL (Security Defaults disabled)'
                }
            }
            catch {
                "MANUAL (Unable to retrieve Security Defaults: $($_.Exception.Message))"
            }
        }
    }
}
