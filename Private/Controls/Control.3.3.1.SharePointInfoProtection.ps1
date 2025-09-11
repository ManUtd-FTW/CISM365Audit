# Control: 3.3.1 (L1) Ensure SharePoint Online Information Protection policies are set up and used (Manual)
function Get-CISM365Control_3_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '3.3.1'
        Name        = 'Ensure SharePoint Online Information Protection policies are set up and used'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('SharePoint', 'Purview')
        Description = 'SharePoint Online Information Protection (Sensitivity Label) policies enable organizations to classify and label content in SharePoint Online based on its sensitivity and business impact. This helps manage and protect sensitive data by automatically applying labels, which can enforce policy-based protection and governance controls.'
        Rationale   = 'Applying classification policies and sensitivity labels in SharePoint Online reduces the risk of data loss or exposure and enables more effective incident response in the event of a breach.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/compliance/data-classificationoverview?view=o365-worldwide#top-sensitivity-labels-applied-to-content'
        )
        Audit       = {
            @"
MANUAL:
1. Navigate to the Microsoft Purview compliance portal (https://compliance.microsoft.com).
2. Under Solutions, select Information protection.
3. Go to the Label policies tab.
4. Ensure at least one label policy exists and is published to SharePoint sites.

Remediation:
1. In the Purview compliance portal, go to Information protection.
2. Create and publish a sensitivity label in the Label policies tab.
3. Make sure the policy is configured and assigned to SharePoint Online locations.
"@
        }
    }
}