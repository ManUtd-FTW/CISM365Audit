# Control: 5.1.3.2 (L1) Ensure a dynamic group for all members is created
function Get-CISM365Control_5_1_3_2 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '5.1.3.2'
        Name        = "Ensure a dynamic group for all members is created"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('AzureAD', 'Entra')
        Description = @'
A dynamic group should be created in Azure Active Directory that automatically includes all member user accounts. This enables consistent and automated enforcement of access controls and security measures for all member users.
'@
        Rationale   = @'
Dynamic groups allow member user accounts to be automatically added and managed according to specific rules, ensuring consistent application of access controls and security policies.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/groupscreate-rule',
            'https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/groupsdynamic-membership'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Navigate to Microsoft Entra admin center (https://entra.microsoft.com/).",
                    "2. Go to Identity > Groups > All groups.",
                    "3. Add filter: Membership type = Dynamic.",
                    "4. Identify a dynamic group and select it.",
                    "5. Under manage, select Dynamic membership rules and ensure the rule syntax contains: (user.userType -eq \"Member\").",
                    "6. If necessary, inspect other dynamic groups for the above value.",
                    "",
                    "PowerShell:",
                    "1. Connect to Microsoft Graph: Connect-MgGraph -Scopes \"Group.Read.All\"",
                    "2. Run:",
                    "   \$groups = Get-MgGroup | Where-Object { \$_.GroupTypes -contains \"DynamicMembership\" }",
                    "   \$groups | ft DisplayName,GroupTypes,MembershipRule",
                    "3. Look for a dynamic group containing the rule: (user.userType -eq \"Member\")"
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify that a dynamic group exists for all member user accounts in Azure AD.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}