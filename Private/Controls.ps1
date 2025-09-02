# Helper: standard result object
function New-CismControlResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $ControlId,
        [Parameter(Mandatory)] [string] $Title,
        [Parameter(Mandatory)] [ValidateSet('Pass','Fail','Manual')] [string] $Status,
        [string] $Service = 'Microsoft 365',
        [string] $Severity = 'Medium',
        [string] $Finding = '',
        [string] $Evidence = '',
        [string] $Recommendation = '',
        [string[]] $References = @()
    )
    [pscustomobject]@{
        ControlId      = $ControlId
        Title          = $Title
        Status         = $Status
        Service        = $Service
        Severity       = $Severity
        Finding        = $Finding
        Evidence       = $Evidence
        Recommendation = $Recommendation
        References     = $References
        Timestamp      = (Get-Date).ToString('s')
    }
}

# 1.1.3 Limit Global Admins (<= 3)
function Test-CismGlobalAdmins {
    [CmdletBinding()]
    param(
        [int] $MaxGlobalAdmins = 3
    )

    $title = "Ensure the number of Global Administrators is limited (<= $MaxGlobalAdmins)"
    $ctrl  = '1.1.3'
    $refs  = @(
        'CIS Microsoft 365 Foundations v3.0.0 – 1.1.3'
    )

    try {
        # "Company Administrator" = Global Administrator (role must be activated)
        $roles = Get-MgDirectoryRole -ErrorAction Stop
        $gaRole = $roles | Where-Object { $_.DisplayName -eq 'Company Administrator' }

        if (-not $gaRole) {
            return New-CismControlResult -ControlId $ctrl -Title $title -Status 'Manual' -Service 'Entra ID' -Severity 'High' `
                -Finding "Global Administrator role not activated in this tenant." `
                -Recommendation "Activate the 'Company Administrator' role and review membership (<= $MaxGlobalAdmins)." `
                -References $refs
        }

        $members = Get-MgDirectoryRoleMember -DirectoryRoleId $gaRole.Id -All -ErrorAction Stop
        $userMembers = $members | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.user' }
        $count = ($userMembers | Measure-Object).Count

        $status  = if ($count -le $MaxGlobalAdmins) { 'Pass' } else { 'Fail' }
        $finding = "Global Administrator user count: $count (max allowed: $MaxGlobalAdmins)"
        $evidence = ($userMembers | ForEach-Object { $_.Id }) -join ', '
        $reco = "Reduce GA users to <= $MaxGlobalAdmins. Prefer PIM for just-in-time elevation."

        New-CismControlResult -ControlId $ctrl -Title $title -Status $status -Service 'Entra ID' -Severity 'High' `
            -Finding $finding -Evidence $evidence -Recommendation $reco -References $refs

    } catch {
        New-CismControlResult -ControlId $ctrl -Title $title -Status 'Manual' -Service 'Entra ID' -Severity 'High' `
            -Finding "Error while querying GA membership." -Evidence ($_.Exception.Message) `
            -Recommendation "Ensure Graph is connected and Directory.Read.All consent is granted." -References $refs
    }
}

# 2.1.9 DKIM enabled for all custom domains
function Test-CismDkimEnabled {
    [CmdletBinding()]
    param()

    $title = "Ensure DKIM is enabled for all custom accepted domains"
    $ctrl  = '2.1.9'
    $refs  = @(
        'CIS Microsoft 365 Foundations v3.0.0 – 2.1.9'
    )

    try {
        $domains = Get-AcceptedDomain -ErrorAction Stop |
            Where-Object { $_.DomainType -eq 'Authoritative' -and $_.DomainName -notlike '*.onmicrosoft.com' }

        if (-not $domains) {
            return New-CismControlResult -ControlId $ctrl -Title $title -Status 'Manual' -Service 'Exchange Online' -Severity 'High' `
                -Finding "No custom authoritative domains found." `
                -Recommendation "Add/verify custom domains and enable DKIM for each sending domain." -References $refs
        }

        $dkim = foreach ($d in $domains) {
            try {
                $cfg = Get-DkimSigningConfig -Identity $d.DomainName -ErrorAction Stop
                [pscustomobject]@{ Domain=$d.DomainName; Enabled=$cfg.Enabled }
            } catch {
                [pscustomobject]@{ Domain=$d.DomainName; Enabled=$false }
            }
        }

        $notEnabled = $dkim | Where-Object { -not $_.Enabled }
        $status   = if ($notEnabled) { 'Fail' } else { 'Pass' }
        $finding  = if ($notEnabled) { "DKIM not enabled for: " + ($notEnabled.Domain -join ', ') } else { "DKIM enabled for all custom domains." }
        $evidence = ($dkim | ForEach-Object { "$($_.Domain)=Enabled:$($_.Enabled)" }) -join '; '
        $reco     = "Enable DKIM on all verified sending domains in Exchange Online Protection."

        New-CismControlResult -ControlId $ctrl -Title $title -Status $status -Service 'Exchange Online' -Severity 'High' `
            -Finding $finding -Evidence $evidence -Recommendation $reco -References $refs

    } catch {
        New-CismControlResult -ControlId $ctrl -Title $title -Status 'Manual' -Service 'Exchange Online' -Severity 'High' `
            -Finding "Error while checking DKIM status." -Evidence ($_.Exception.Message) `
            -Recommendation "Ensure Exchange Online connection and permissions; retry." -References $refs
    }
}

# 2.1.1 Safe Links enabled (tenant policy)
function Test-CismSafeLinksEnabled {
    [CmdletBinding()]
    param()

    $title = "Ensure Safe Links is enabled for Office apps and clients (tenant policy)"
    $ctrl  = '2.1.1'
    $refs  = @(
        'CIS Microsoft 365 Foundations v3.0.0 – 2.1.1'
    )

    try {
        $p = Get-AtpPolicyForO365 -ErrorAction Stop
        $office  = $p.EnableSafeLinksForOffice
        $clients = $p.EnableSafeLinksForClients

        $status   = if ($office -and $clients) { 'Pass' } else { 'Fail' }
        $finding  = "EnableSafeLinksForOffice=$office; EnableSafeLinksForClients=$clients"
        $evidence = $finding
        $reco     = "Enable Safe Links for Office and Outlook clients via Set-AtpPolicyForO365 or the Defender portal."

        New-CismControlResult -ControlId $ctrl -Title $title -Status $status -Service 'Exchange Online' -Severity 'High' `
            -Finding $finding -Evidence $evidence -Recommendation $reco -References $refs

    } catch {
        New-CismControlResult -ControlId $ctrl -Title $title -Status 'Manual' -Service 'Exchange Online' -Severity 'High' `
            -Finding "Error while checking Safe Links policy." -Evidence ($_.Exception.Message) `
            -Recommendation "Ensure Exchange Online connection and appropriate Defender permissions." -References $refs
    }
}
