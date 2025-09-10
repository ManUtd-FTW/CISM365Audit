# Control: 2.3.2 Ensure non-global administrator role group assignments are reviewed at least weekly (L1)
# Manual control. Verifies that procedures exist and are followed for weekly review of non-global administrator role assignments.
function Get-CISM365Control_2_3_2 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.3.2'
        Name        = 'Ensure non-global administrator role group assignments are reviewed at least weekly'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender', 'AzureAD')
        Description = 'Non-global administrator role group assignments should be reviewed at least weekly to detect and respond to unauthorized privilege escalation.'
        Rationale   = "Non-global admin roles grant special privileges and can be misused. Regular review helps ensure only legitimate access is granted and allows investigation of unusual activity."
        Impact      = "No negative impact. Supports privileged access management and incident response."
        References  = @(
            'https://security.microsoft.com'
        )
        Audit = {
            return 'MANUAL: Confirm weekly review of non-global administrator role group assignments. Ensure procedures are in place and followed. See audit steps for details.'
        }
        Remediation = @'
To review non-global administrator role group assignments:
1. Navigate to Microsoft 365 Defender https://security.microsoft.com.
2. Click on Audit.
3. Set Activities to Added member to Role and Removed a user from a directory role.
4. Set Start Date and End Date.
5. Click Search.
6. Review.
'@
        Evidence    = '' # Optionally add evidence of weekly review
        Status      = 'MANUAL: Confirm weekly review of non-global administrator role group assignments and document procedures.'
    }
}