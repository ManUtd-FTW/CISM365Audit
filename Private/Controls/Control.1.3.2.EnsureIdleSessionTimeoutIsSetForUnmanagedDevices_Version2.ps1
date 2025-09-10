function Get-CISM365Control_1_3_2 {
    <#
    .SYNOPSIS
        Manual check for Idle Session Timeout configuration for unmanaged devices.

    .DESCRIPTION
        Ensures that Idle Session Timeout is set to 3 hours or less in Microsoft 365 Admin Center,
        and that a Conditional Access policy is configured to target unmanaged devices via browser access.

    .NOTES
        Control ID: 1.3.2 (L1)
        Profile: E3 Level 1
        Manual Check
    #>

    return @{
        Id = '1.3.2'
        Name = "Ensure 'Idle session timeout' is set to '3 hours (or less)' for unmanaged devices"
        Profile = 'L1'
        Automated = $false
        Services = @('AdminCenter','ConditionalAccess')
        Description = "Verify Idle Session Timeout is configured to 3 hours or less for unmanaged devices, and a Conditional Access policy enforces app-enforced restrictions for browser access."
        Rationale = "Limiting idle session duration and enforcing session controls for unmanaged devices reduces the risk of unauthorized access from unattended or unmanaged endpoints."
        References = @(
            'https://learn.microsoft.com/microsoft-365/admin/manage/idle-session-timeout',
            'https://learn.microsoft.com/azure/active-directory/conditional-access/overview'
        )
        Audit = {
            # This ScriptBlock will be invoked by the runner and must return a PSCustomObject describing the manual check.
            $ControlId = '1.3.2'
            $Title = "Ensure 'Idle session timeout' is set to '3 hours (or less)' for unmanaged devices"

            $Instructions = @'
Step 1 - Check Idle Session Timeout:
1. Sign in to Microsoft 365 admin center: https://admin.microsoft.com/
2. Go to Settings > Org settings > Security & privacy > Idle session timeout
3. Ensure the setting is enabled and set to 3 hours or less for applicable users.

Step 2 - Check Conditional Access Policy:
1. Sign in to Microsoft Entra admin center: https://entra.microsoft.com/
2. Go to Azure AD > Security > Conditional Access
3. Verify a policy exists that targets the intended user scope (e.g., All Users), applies to Microsoft 365 / Office 365 apps, targets "Browser" client apps (or excludes managed apps), and enforces session controls (e.g., "Use app enforced restrictions" or other session control) with the policy Enabled.
'@

            return [PSCustomObject]@{
                Id = $ControlId
                Name = $Title
                Profile = 'L1'
                Automated = $false
                Status = 'MANUAL'
                Findings = $Instructions
                Remediation = "Manually verify and, if necessary, configure Idle Session Timeout in the Microsoft 365 Admin Center and create or update a Conditional Access policy in Azure AD to target unmanaged devices via browser access with appropriate session controls."
                References = @(
                    'https://learn.microsoft.com/microsoft-365/admin/manage/idle-session-timeout',
                    'https://learn.microsoft.com/azure/active-directory/conditional-access/overview'
                )
            }
        }
    }
}