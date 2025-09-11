# Requires: Microsoft.Graph modules connected by the orchestrator
# Control: 1.1.3 Ensure that between two and four global admins are designated (L1)

function Get-CISM365Control_1_1_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.3'
        Name        = 'Ensure that between two and four Global Administrators are designated'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'Limit the number of Global Administrators to reduce risk.'
        Rationale   = 'Too many global admins increase the attack surface and the blast radius of compromised credentials.'
        References  = @(
            'https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference'
        )
        Audit       = {
            try {
                # Built-in role template ID for Global Administrator
                $gaTemplateId = '62e90394-69f5-4237-9190-012177145e10'

                # Find the activated directory role instance for Global Admin (take first match)
                $role = Get-MgDirectoryRole -All |
                        Where-Object { $_.RoleTemplateId -eq $gaTemplateId } |
                        Select-Object -First 1

                if (-not $role) {
                    return 'MANUAL (Global Administrator directory role is not activated in this tenant)'
                }

                # Enumerate members and count only user principals
                $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All
                $userIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

                foreach ($m in $members) {
                    if ($null -eq $m.AdditionalProperties) { continue }

                    $odataType = $m.AdditionalProperties['@odata.type']
                    if ($odataType -eq '#microsoft.graph.user') {
                        $id = $m.Id
                        if ([string]::IsNullOrWhiteSpace($id) -and $m.AdditionalProperties.objectId) {
                            $id = $m.AdditionalProperties.objectId
                        }
                        if ($id) { [void]$userIds.Add($id) }
                    }
                }

                $count = $userIds.Count

                if ($count -ge 2 -and $count -le 4) {
                    "PASS ($count global admins)"
                } else {
                    "FAIL ($count global admins)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}