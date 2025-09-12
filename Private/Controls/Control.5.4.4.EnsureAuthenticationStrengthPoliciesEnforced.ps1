function Get-CISM365Control_5_4_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.4.4'
        Name        = "Ensure authentication strength policies require strong methods"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Authentication strength policies should require strong methods (FIDO2, certificate, etc.) for privileged access."
        Rationale   = "Strong authentication reduces risk for privileged and sensitive accounts."
        References  = @(
            'https://learn.microsoft.com/en-us/entra/identity/authentication-strength-policy'
        )
        Audit       = {
            try {
                $policies = Get-MgPolicyAuthenticationStrengthPolicy
                $strongRequired = $policies | Where-Object {
                    $_.IsEnabled -eq $true -and
                    ($_.AllowedAuthenticationMethods -contains "fido2" -or $_.AllowedAuthenticationMethods -contains "certificate")
                }
                if ($strongRequired.Count -gt 0) {
                    "PASS (Authentication strength policies require strong methods)"
                } else {
                    "FAIL (Authentication strength policies do NOT require strong methods)"
                }
            }
            catch {
                "MANUAL (Unable to check authentication strength policy: $($_.Exception.Message))"
            }
        }
    }
}