# Control: 5.1.2.3 Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes' (L1)
function Get-CISM365Control_5_1_2_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.2.3'
        Name        = "Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes'"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Entra', 'AzureAD')
        Description = "Restricts non-privileged users from creating new Azure AD tenants, preventing uncontrolled deployment of resources and shadow IT."
        Rationale   = "Restricting tenant creation ensures only authorized administrators can create new tenants. This maintains organizational control and prevents shadow IT risks."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/users-default-permissions#restrict-member-users-default-permissions'
        )
        Audit       = {
            try {
                # Connect-MgGraph must be run with at least Policy.Read.All scope
                $policy = Get-MgPolicyAuthorizationPolicy -ErrorAction Stop
                $result = $policy.DefaultUserRolePermissions.AllowedToCreateTenants
                if ($result -eq $false) {
                    return "PASS (Non-admin users are restricted from creating tenants.)"
                } elseif ($result -eq $true) {
                    return "FAIL (Non-admin users can create tenants. Set 'Restrict non-admin users from creating tenants' to Yes.)"
                } else {
                    return "ERROR (Unable to determine AllowedToCreateTenants value.)"
                }
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}