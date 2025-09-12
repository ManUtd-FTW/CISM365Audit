function Get-CISM365Control_2_5_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.5.4'
        Name        = "Ensure Conditional Access protects email and collaboration apps"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('AzureAD', 'AzurePortal')
        Description = "Conditional Access policies should require MFA and session controls for Exchange, Teams, and SharePoint."
        Rationale   = "Conditional Access is critical for protecting access to sensitive collaboration and email data."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview'
        )
        Audit       = @"
Manual Audit Steps (as of 9/12/2025):
1. Sign in to the Azure Portal (https://portal.azure.com).
2. Navigate to Azure Active Directory > Security > Conditional Access > Policies.
3. Review enabled policies targeting 'Office 365 Exchange Online', 'Office 365 SharePoint Online', and 'Office 365 Teams'.
4. Ensure that each policy requires Multi-Factor Authentication (MFA) and session controls for these apps.
5. Document policies that do not meet these requirements.
"@
    }
}