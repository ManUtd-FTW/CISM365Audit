# Control: 5.1.2.1 (L1) Ensure 'Per-user MFA' is disabled
function Get-CISM365Control_5_1_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.2.1'
        Name        = "Ensure 'Per-user MFA' is disabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('MSOnline')
        Description = "Legacy per-user Multi-Factor Authentication (MFA) should be disabled for all users to avoid conflicts and ensure consistent authentication state, as Conditional Access should be used instead."
        Rationale   = "Disabling per-user MFA ensures that MFA is managed through Conditional Access policies, providing a more robust and consistent security posture for all users."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/howtomfa-userstates#convert-users-from-per-user-mfa-to-conditional-access',
            'https://learn.microsoft.com/en-us/microsoft-365/admin/security-andcompliance/set-up-multi-factor-authentication?view=o365-worldwide#useconditional-access-policies',
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/howtomfa-userstates#convert-per-user-mfa-enabled-and-enforced-users-to-disabled'
        )
        Audit       = {
            try {
                # Connect to MSOnline if needed
                if (-not (Get-Command Get-MsolUser -ErrorAction SilentlyContinue)) {
                    return "ERROR: MSOnline module is not installed. Please install MSOnline and retry."
                }
                # Ensure MSOnline connection
                try {
                    Get-MsolCompanyInformation -ErrorAction Stop | Out-Null
                } catch {
                    Connect-MsolService -ErrorAction SilentlyContinue
                }

                $userList = Get-MsolUser -All | Where-Object { $_.UserType -eq 'Member' }
                $violations = @()
                foreach ($user in $userList) {
                    $mfaState = if ($user.StrongAuthenticationRequirements) {
                        $user.StrongAuthenticationRequirements.State
                    } else {
                        'Disabled'
                    }
                    if ($mfaState -ne 'Disabled') {
                        $violations += $user.UserPrincipalName
                    }
                }

                if ($violations.Count -eq 0) {
                    return "PASS (Per-user MFA is disabled for all users)"
                } else {
                    $sample = ($violations | Select-Object -First 5) -join ', '
                    return "FAIL (Per-user MFA is enabled for: $sample)"
                }
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}