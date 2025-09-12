# Control: 5.1.6.1 (L2) Ensure that collaboration invitations are sent to allowed domains only
function Get-CISM365Control_5_1_6_1 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '5.1.6.1'
        Name        = "Ensure that collaboration invitations are sent to allowed domains only"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AzureAD', 'Entra')
        Description = @'
Azure AD B2B collaboration invitations should only be sent to specified allowed domains. This restricts guest invitations and helps prevent internal users from inviting unknown or unauthorized external accounts.
'@
        Rationale   = @'
Specifying allowed domains for collaboration ensures that only explicitly identified external organizations can be invited, reducing risk from unknown external accounts and personal email addresses.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/external-identities/allowdeny-list',
            'https://learn.microsoft.com/en-us/azure/active-directory/external-identities/whatis-b2b'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Navigate to Microsoft Entra admin center (https://entra.microsoft.com/).",
                    "2. Go to Identity > External Identities > External collaboration settings.",
                    "3. Under Collaboration restrictions, make sure 'Allow invitations only to the specified domains (most restrictive)' is selected.",
                    "4. Ensure 'Target domains' is checked and that allowed domains are specified.",
                    "",
                    "Remediation:",
                    "1. In the same area, select 'Allow invitations only to the specified domains (most restrictive)', check 'Target domains', and specify the domains allowed to collaborate."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify that collaboration invitations are sent only to specified allowed domains.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}