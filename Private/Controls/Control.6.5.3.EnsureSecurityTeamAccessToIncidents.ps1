function Get-CISM365Control_6_5_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.5.3'
        Name        = "Ensure security teams have access to all incidents and alerts"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "Security teams must have access to view and manage all incidents and alerts in Microsoft 365 Security Center."
        Rationale   = "Access ensures teams can respond to and investigate security events."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/defender/microsoft-365-security-center'
        )
        Audit       = {
            try {
                $roles = Get-MgDirectoryRole | Where-Object { $_.DisplayName -match "Security" }
                $securityTeams = $roles | ForEach-Object { Get-MgDirectoryRoleMember -DirectoryRoleId $_.Id }
                if ($securityTeams.Count -gt 0) {
                    "PASS (Security teams have access to incidents and alerts)"
                } else {
                    "FAIL (No security teams or roles found with incident and alert access)"
                }
            }
            catch {
                "MANUAL (Unable to check security team access: $($_.Exception.Message))"
            }
        }
    }
}