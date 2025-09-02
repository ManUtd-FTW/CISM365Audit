function Start-CISM365Audit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Tenant,

        [string]$OutputPath = ".\CISM365AuditReport.html"
    )

    # Ensure output directory exists
    try {
        $dir = Split-Path -Path (Resolve-Path -Path $OutputPath -ErrorAction SilentlyContinue ?? $OutputPath) -Parent
        if (-not $dir) { $dir = Split-Path -Parent $OutputPath }
        if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    } catch { }

    # Helper: HTML-encode values
    $EncodeHtml = {
        param($s)
        if ($null -eq $s) { return '' }
        $s.ToString().
          Replace('&','&amp;').
          Replace('<','&lt;').
          Replace('>','&gt;').
          Replace('"','&quot;').
          Replace("'","&#39;")
    }

    # --- Minimal CIS Controls Registry ---
    $CISControls = @(
        @{
            Id   = '1.1.3'
            Name = 'Ensure that between two and four global admins are designated'
            Audit = {
                # Connect to Graph if not already connected with required scope
                $ctx = $null
                try { $ctx = Get-MgContext -ErrorAction Stop } catch { }
                $needGraph = -not $ctx -or -not $ctx.Scopes -or ('Directory.Read.All' -notin $ctx.Scopes)
                if ($needGraph) {
                    Connect-MgGraph -Scopes "Directory.Read.All" -TenantId $Tenant -NoWelcome
                }

                # GA Role Template Id (Company Administrator)
                $gaTemplateId = '62e90394-69f5-4237-9190-012177145e10'

                # DirectoryRole only returns activated roles
                $roles = Get-MgDirectoryRole -All -ErrorAction Stop
                $role  = $roles | Where-Object { $_.RoleTemplateId -eq $gaTemplateId -or $_.DisplayName -eq 'Company Administrator' }

                if (-not $role) {
                    return "MANUAL (Global Administrator role not activated in this tenant)"
                }

                # Get direct role members
                $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All -ErrorAction Stop

                # Count unique users, including users in any assigned groups (transitive)
                $userIds = [System.Collections.Generic.HashSet[string]]::new()

                foreach ($m in $members) {
                    $type = $m.AdditionalProperties.'@odata.type'
                    if ($type -eq '#microsoft.graph.user') {
                        [void]$userIds.Add($m.Id)
                    }
                    elseif ($type -eq '#microsoft.graph.group') {
                        try {
                            $tm = Get-MgGroupTransitiveMember -GroupId $m.Id -All -ErrorAction Stop
                            foreach ($x in $tm) {
                                if ($x.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user') {
                                    [void]$userIds.Add($x.Id)
                                }
                            }
                        } catch {
                            # Fallback to direct members if transitive fails
                            $gm = Get-MgGroupMember -GroupId $m.Id -All -ErrorAction SilentlyContinue
                            foreach ($x in $gm) {
                                if ($x.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user') {
                                    [void]$userIds.Add($x.Id)
                                }
                            }
                        }
                    }
                    # Ignore other principals for this count
                }

                $count = $userIds.Count
                if ($count -ge 2 -and $count -le 4) { "PASS ($count global admins)" }
                else { "FAIL ($count global admins)" }
            }
        },
        @{
            Id   = '2.1.9'
            Name = 'Ensure that DKIM is enabled for all Exchange Online Domains'
            Audit = {
                # Connect to Exchange Online if not already connected
                $exoConnected = $false
                try {
                    $ci = Get-ConnectionInformation -ErrorAction SilentlyContinue
                    if ($ci -and $ci.State -eq 'Connected') { $exoConnected = $true }
                } catch { }
                if (-not $exoConnected) {
                    Connect-ExchangeOnline -Organization $Tenant -ShowBanner:$false
                }

                # Only evaluate custom authoritative domains
                $domains = Get-AcceptedDomain -ErrorAction Stop |
                    Where-Object { $_.DomainType -eq 'Authoritative' -and $_.DomainName -notlike '*.onmicrosoft.com' }

                if (-not $domains) { return "MANUAL (No custom authoritative domains found)" }

                $dkimStatus = foreach ($d in $domains) {
                    try {
                        $cfg = Get-DkimSigningConfig -Identity $d.DomainName -ErrorAction Stop
                        [pscustomobject]@{ Domain=$d.DomainName; Enabled=$cfg.Enabled }
                    } catch {
                        # Treat missing config as not enabled
                        [pscustomobject]@{ Domain=$d.DomainName; Enabled=$false }
                    }
                }

                $notEnabled = $dkimStatus | Where-Object { -not $_.Enabled }
                if ($notEnabled) {
                    "FAIL (DKIM not enabled for: $($notEnabled.Domain -join ', '))"
                } else {
                    "PASS (DKIM enabled for all custom domains)"
                }
            }
        },
        @{
            Id   = '2.1.1'
            Name = 'Ensure Safe Links for Office Applications is Enabled'
            Audit = {
                # Connect to Exchange Online if not already connected
                $exoConnected = $false
                try {
                    $ci = Get-ConnectionInformation -ErrorAction SilentlyContinue
                    if ($ci -and $ci.State -eq 'Connected') { $exoConnected = $true }
                } catch { }
                if (-not $exoConnected) {
                    Connect-ExchangeOnline -Organization $Tenant -ShowBanner:$false
                }

                try {
                    $p = Get-AtpPolicyForO365 -ErrorAction Stop
                    $office  = $p.EnableSafeLinksForOffice
                    $clients = $p.EnableSafeLinksForClients
                    if ($office -and $clients) {
                        "PASS (Safe Links enabled for Office and clients)"
                    } else {
                        "FAIL (EnableSafeLinksForOffice=$office, EnableSafeLinksForClients=$clients)"
                    }
                } catch {
                    "MANUAL (Unable to read AtpPolicyForO365: $($_.Exception.Message))"
                }
            }
        }
    )

    # --- Run Controls ---
    $results = @()
    foreach ($ctrl in $CISControls) {
        Write-Host "Checking $($ctrl.Id): $($ctrl.Name) ..."
        try {
            $status = & $ctrl.Audit
        } catch {
            $status = "ERROR: $($_.Exception.Message)"
        }

        $results += [PSCustomObject]@{
            Id     = $ctrl.Id
            Name   = $ctrl.Name
            Status = $status
        }
    }

    # --- Build Minimal HTML with summary + encoding ---
    $pass   = ($results | Where-Object { $_.Status -like 'PASS*'  }).Count
    $fail   = ($results | Where-Object { $_.Status -like 'FAIL*'  }).Count
    $manual = ($results | Where-Object { $_.Status -like 'MANUAL*'}).Count
    $error  = ($results | Where-Object { $_.Status -like 'ERROR*' }).Count

    $gts = Get-Date -Format "yyyy-MM-dd HH:mm K"

    $html = @"
<html>
<head>
  <meta charset="utf-8" />
  <title>CIS M365 Audit Results</title>
  <style>
    body { font-family: Segoe UI, Arial, sans-serif; color:#222; margin:24px }
    .meta { color:#666; margin-bottom:12px }
    .summary { margin: 6px 0 16px 0 }
    .pill { display:inline-block; padding:2px 8px; border-radius:999px; margin-right:6px; font-size:12px; color:#fff }
    .p-pass { background:#2e7d32 }
    .p-fail { background:#c62828 }
    .p-man  { background:#ef6c00 }
    .p-err  { background:#6d4c41 }
    table { border-collapse:collapse; width:100% }
    th, td { border:1px solid #ddd; padding:6px 8px; vertical-align:top }
    th { background:#f7f7f7; text-align:left }
  </style>
</head>
<body>
  <h2 style="margin:0 0 8px 0">CIS Microsoft 365 Audit Results for $Tenant</h2>
  <div class="meta">Generated: $gts</div>
  <div class="summary">
    <span class="pill p-pass">PASS: $pass</span>
    <span class="pill p-fail">FAIL: $fail</span>
    <span class="pill p-man">MANUAL: $manual</span>
    <span class="pill p-err">ERROR: $error</span>
  </div>
  <table>
    <tr><th>Control</th><th>Description</th><th>Status</th></tr>
"@

    foreach ($r in $results) {
        $color = if ($r.Status -like "PASS*") { "#2e7d32" } elseif ($r.Status -like "FAIL*") { "#c62828" } elseif ($r.Status -like "ERROR*") { "#6d4c41" } else { "#ef6c00" }
        $id    = & $EncodeHtml $r.Id
        $name  = & $EncodeHtml $r.Name
        $stat  = & $EncodeHtml $r.Status
        $html += "<tr><td>$id</td><td>$name</td><td style='color:$color'>$stat</td></tr>"
    }

    $html += "</table></body></html>"

    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Audit complete. Results saved to $OutputPath" -ForegroundColor Green

    # Also return the raw results for programmatic use
    $results
}
