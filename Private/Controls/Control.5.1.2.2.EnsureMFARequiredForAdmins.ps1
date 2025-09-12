function Get-CISM365Control_5_1_2_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.2.2'
        Name        = "Ensure MFA is required for all admin roles"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "All users assigned Azure AD admin roles must be required to sign in using Multi-Factor Authentication."
        Rationale   = "MFA is critical for protecting privileged accounts from compromise."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/howto-identity-protection-configure-mfa-policy'
        )
        Audit       = {
            try {
                $roleTemplates = @(
                    "62e90394-69f5-4237-9190-012177145e10", # Global Admin
                    "fe930be7-5e62-47db-91af-98c3a49a38b1", # Privileged Role Admin
                    "29232cdf-9323-42fd-ade2-1d097af3e4de", # Security Admin
                    "729827e3-9c14-49f7-bb1b-9608f156bbb8"  # Exchange Admin
                )
                $roles = Get-MgDirectoryRole | Where-Object { $_.RoleTemplateId -in $roleTemplates }
                $mfaRequired = $true
                foreach ($role in $roles) {
                    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
                    foreach ($member in $members) {
                        $user = Get-MgUser -UserId $member.Id
                        if ($user.StrongAuthenticationMethods.Count -eq 0) { $mfaRequired = $false }
                    }
                }
                if ($mfaRequired) {
                    "PASS (MFA is required for all admin accounts)"
                } else {
                    "FAIL (MFA is NOT enforced for all admins)"
                }
            }
            catch {
                "MANUAL (Unable to check MFA enforcement for admin roles: $($_.Exception.Message))"
            }
        }
    }
}