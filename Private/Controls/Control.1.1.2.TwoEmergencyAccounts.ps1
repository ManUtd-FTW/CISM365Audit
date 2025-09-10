function Get-CISM365Control_1_1_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.2'
        Name        = 'Ensure two emergency access (break glass) accounts have been defined'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Graph')
        Description = 'Two emergency access accounts should exist with hardened auth and CA exclusions suitable for emergency use.'
        Rationale   = 'Maintains access to admin functions during outages or auth failures while minimizing day-to-day risk.'
        References  = @(
            'https://www.tenable.com/audits/items/CIS_Microsoft_365_Foundations_v5.0.0_L1_E3.audit:161600259447be66bb2bbcde8c519cea'
        )
        Audit       = {
            'MANUAL (Verify two non-personal Global Administrator accounts exist, are cloud-only, minimally licensed, use FIDO2/cert-based MFA, and at least one is excluded from CA policies)'
        }
    }
}
