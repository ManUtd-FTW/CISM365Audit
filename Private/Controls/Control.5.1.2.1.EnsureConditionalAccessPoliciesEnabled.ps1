function Get-CISM365Control_5_1_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.2.1'
        Name        = "Ensure Conditional Access policies are enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Conditional Access policies should be enabled to enforce modern authentication and access controls."
        Rationale   = "Conditional Access provides granular control over resource access and risk mitigation."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview'
        )
        Audit       = {
            try {
                $policies = Get-MgConditionalAccessPolicy -All
                $enabled = $policies | Where-Object { $_.State -eq "enabled" }
                if ($enabled.Count -gt 0) {
                    "PASS (Conditional Access policies are enabled: $($enabled | Select-Object -ExpandProperty DisplayName -join ', '))"
                } else {
                    "FAIL (No Conditional Access policies are enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check Conditional Access status: $($_.Exception.Message))"
            }
        }
    }
}