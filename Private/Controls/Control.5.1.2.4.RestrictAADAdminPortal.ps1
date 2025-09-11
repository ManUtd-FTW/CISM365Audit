# Control: 5.1.2.4 (L1) Ensure 'Restrict access to the Azure AD administration portal' is set to 'Yes'
function Get-CISM365Control_5_1_2_4 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '5.1.2.4'
        Name        = "Ensure 'Restrict access to the Azure AD administration portal' is set to 'Yes'"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('AzureAD', 'Entra')
        Description = @'
Restrict non-privileged users from signing into the Azure Active Directory web portal to prevent inadvertent changes and reduce risk from compromised user accounts.
'@
        Rationale   = @'
Restricting access to the Azure AD administration portal helps prevent end users from viewing or modifying sensitive directory information, reducing administrative overhead and mitigating escalation risks from compromised accounts.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/users-default-permissions#restrict-member-users-default-permissions'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Navigate to Microsoft Entra admin center (https://entra.microsoft.com/).",
                    "2. Go to Identity > Users > User settings.",
                    "3. Under Administration portal, verify 'Restrict access to Microsoft Entra ID administration portal' is set to 'Yes'.",
                    "",
                    "Remediation:",
                    "1. In the same area, set 'Restrict access to Microsoft Entra ID administration portal' to 'Yes' and click Save."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify that non-privileged users are restricted from accessing the Azure AD administration portal.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}