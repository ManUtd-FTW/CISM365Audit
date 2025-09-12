function Get-CISM365Control_6_6_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.6.2'
        Name        = "Ensure audit/monitoring data is protected with RBAC"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Access to audit and monitoring data (e.g., Microsoft 365 audit logs, Sentinel workspaces) should be controlled using Role-Based Access Control (RBAC). Only approved users/groups should have permission to view or manage logs."
        Rationale   = "Restricts access to sensitive monitoring data, supporting compliance and reducing risk."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/roles/security-roles',
            'https://learn.microsoft.com/en-us/azure/role-based-access-control/overview'
        )
        Audit       = {
            try {
                $rbacAssignments = Get-MgRoleManagementDirectoryRoleAssignment | Where-Object {
                    $_.ResourceScope -match "AuditLog" -or $_.ResourceScope -match "SecurityWorkspace"
                }
                if ($rbacAssignments.Count -gt 0) {
                    "PASS (RBAC assignments found for audit/monitoring data: $($rbacAssignments | Select-Object -ExpandProperty PrincipalId -join ', '))"
                } else {
                    "FAIL (No RBAC assignments found for audit/monitoring data)"
                }
            }
            catch {
                "MANUAL (Unable to check RBAC assignments for audit/monitoring data: $($_.Exception.Message))"
            }
        }
    }
}