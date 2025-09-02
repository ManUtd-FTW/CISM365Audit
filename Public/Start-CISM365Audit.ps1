function Start-CISM365Audit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Tenant,

        [string]$OutputPath = ".\CISM365AuditReport.html"
    )

    # --- Minimal CIS Controls Registry (expand as needed) ---
    $CISControls = @(
        @{
            Id   = '1.1.3'
            Name = 'Ensure that between two and four global admins are designated'
            Audit = {
                # Connect to Graph if not already connected
                if (-not (Get-MgContext)) {
                    Connect-MgGraph -Scopes "Directory.Read.All" -TenantId $Tenant -NoWelcome
                }

                # RoleTemplateId for Global Administrator (Company Administrator)
                $role    = Get-MgDirectoryRole -Filter "RoleTemplateId eq '62e90394-69f5-4237-9190-012177145e10'"
                $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id

                $count = 0
                foreach ($m in $members) {
                    if ($m.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user') {
                        $count++
                    }
                    elseif ($m.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group') {
                        $groupMembers = (Get-MgGroupMember -GroupId $m.Id).AdditionalProperties
                        foreach ($gm in $groupMembers) {
                            if ($gm.'@odata.type' -eq '#microsoft.graph.user') { $count++ }
                        }
                    }
                }

                if ($count -ge 2 -and $count -le 4) { "PASS ($count global admins)" }
                else { "FAIL ($count global admins)" }
            }
        },
        @{
            Id   = '2.1.9'
            Name = 'Ensure that DKIM is enabled for all Exchange Online Domains'
            Audit = {
                # Connect to Exchange Online if not already connected
                if (-not (Get-PSSession | Where-Object { $_.ComputerName -like '*outlook.office365.com*' })) {
                    Connect-ExchangeOnline -Organization $Tenant
                }

                $dkim = Get-DkimSigningConfig
                $fail = $dkim | Where-Object { -not $_.Enabled }

                if ($fail.Count -eq 0) { "PASS (DKIM enabled for all domains)" }
                else { "FAIL (DKIM not enabled for: $($fail.DomainName -join ', '))" }
            }
        },
        @{
            Id   = '2.1.1'
            Name = 'Ensure Safe Links for Office Applications is Enabled'
            Audit = {
                if (-not (Get-PSSession | Where-Object { $_.ComputerName -like '*outlook.office365.com*' })) {
                    Connect-ExchangeOnline -Organization $Tenant
                }

                $policies = Get-SafeLinksPolicy
                $pass = $false
                foreach ($p in $policies) {
                    if ($p.EnableSafeLinksForOffice -and $p.EnableSafeLinksForEmail -and $p.EnableSafeLinksForTeams) {
                        $pass = $true
                    }
                }

                if ($pass) { "PASS (Safe Links enabled for Office, Email, Teams)" }
                else { "FAIL (Safe Links not fully enabled)" }
            }
        }
    )

    # --- Run Controls ---
    $results = @()
    foreach ($ctrl in $CISControls) {
        Write-Host "Checking $($ctrl.Id): $($ctrl.Name) ..."
        try {
            $status = & $ctrl.Audit
        }
        catch {
            $status = "ERROR: $($_.Exception.Message)"
        }

        $results += [PSCustomObject]@{
            Id     = $ctrl.Id
            Name   = $ctrl.Name
            Status = $status
        }
    }

    # --- Output Minimal HTML ---
    $html = @"
<html>
<head><title>CIS M365 Audit Results</title></head>
<body>
<h2>CIS Microsoft 365 Audit Results for $Tenant</h2>
<table border='1' cellpadding='5' cellspacing='0'>
<tr><th>Control</th><th>Description</th><th>Status</th></tr>
"@
    foreach ($r in $results) {
        $color = if ($r.Status -like "PASS*") { "green" } elseif ($r.Status -like "FAIL*") { "red" } else { "orange" }
        $html += "<tr><td>$($r.Id)</td><td>$($r.Name)</td><td style='color:$color'>$($r.Status)</td></tr>"
    }
    $html += "</table></body></html>"

    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Audit complete. Results saved to $OutputPath" -ForegroundColor Green
}
