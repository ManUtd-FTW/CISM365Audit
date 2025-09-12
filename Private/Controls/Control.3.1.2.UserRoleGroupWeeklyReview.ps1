# Control: 3.1.2 Ensure user role group changes are reviewed at least weekly (L1)
# Manual control. Verifies procedures exist and are followed for weekly review of user role group changes via Microsoft Purview or Exchange Online PowerShell.
function Get-CISM365Control_3_1_2 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '3.1.2'
        Name        = "Ensure user role group changes are reviewed at least weekly"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Microsoft365', 'ExchangeOnline', 'Purview')
        Description = "Role-Based Access Control permissions must be reviewed at least weekly to detect and approve changes in user role group membership, ensuring least privilege and preventing privilege creep."
        Rationale   = "Weekly review of role group changes helps maintain least privilege, prevent privilege creep, and limit insider threats."
        Impact      = "Requires administrative effort to review and document changes, increasing accountability and auditability."
        References  = @(
            'https://learn.microsoft.com/en-us/powershell/module/exchange/searchunifiedauditlog?view=exchange-ps'
        )
        Audit = {
            return "MANUAL: Confirm that procedures are in place and followed to review user role group changes at least weekly. Review audit logs for 'Add member to role' activities within the past week using Microsoft Purview or Exchange Online PowerShell."
        }
        Remediation = @'
To review user role group changes:
Manual:
1. Go to Microsoft Purview https://compliance.microsoft.com/.
2. Under Solutions, click on Audit, then select New Search.
3. In Activities, find "Added member to Role" (Role administration activities).
4. Set Start Date and End Date within the last week.
5. Click Search and review results.

PowerShell:
1. Connect to Exchange Online using Connect-ExchangeOnline.
2. Run:
$startDate = ((Get-date).AddDays(-7)).ToShortDateString()
$endDate = (Get-date).ToShortDateString()
Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -RecordType AzureActiveDirectory -Operations "Add member to role."
3. Review results.
'@
        Evidence    = '' # Optionally add evidence after manual review
        Status      = "MANUAL: Confirm user role group changes are reviewed weekly using Purview or PowerShell audit logs."
    }
}