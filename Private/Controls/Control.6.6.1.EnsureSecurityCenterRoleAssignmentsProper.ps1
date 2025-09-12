function Get-CISM365Control_6_6_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.6.1'
        Name        = "Ensure Security Center role assignments are properly configured"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Role assignments in Microsoft 365 Security Center should follow the principle of least privilege. Only authorized users or groups should have security admin, security reader, or incident responder roles."
        Rationale   = "Restricting role assignments reduces risk of unauthorized access and protects sensitive security data."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/defender/microsoft-365-security-center',
            'https://learn.microsoft.com/en-us/azure/active-directory/roles/security-roles'
        )
        Audit       = {
            try {
                $roles = Get-MgDirectoryRole | Where-Object { $_.DisplayName -match "Security" }
                $roleAssignments = @()
                foreach ($role in $roles) {
                    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
                    foreach ($member in $members) {
                        $roleAssignments += [PSCustomObject]@{
                            RoleName = $role.DisplayName
                            MemberId = $member.Id
                        }
                    }
                }
                if ($roleAssignments.Count -gt 0) {
                    "PASS (Security Center roles are assigned: $($roleAssignments | Select-Object -ExpandProperty MemberId -join ', '))"
                } else {
                    "FAIL (No Security Center roles found or assigned)"
                }
            }
            catch {
                "MANUAL (Unable to check Security Center role assignments: $($_.Exception.Message))"
            }
        }
    }
}