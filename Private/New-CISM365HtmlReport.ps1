function New-CISM365HtmlReport {
<#
.SYNOPSIS
    Builds the HTML report for CISM365Audit.

.DESCRIPTION
    Accepts the audit results and a summary object and returns a complete HTML document
    as a string. The HTML is self-contained (inline CSS/JS). Links are generated safely and
    details are collapsible. Text content is HTML-encoded to prevent rendering issues.

.PARAMETER Tenant
    The tenant identifier shown in the report header (GUID or domain).

.PARAMETER Results
    Array of PSCustomObject items with fields:
        Id, Name, Description, Rationale, References, Profile, Automated, Status

.PARAMETER Summary
    Hashtable/object with counts and metadata:
        PASS, FAIL, MANUAL, ERROR, Total, Tenant, Cloud, GeneratedOn

.PARAMETER ReportTitle
    Optional custom title to display at the top of the report.
    Default: 'CIS Microsoft 365 Audit Results'

.PARAMETER LogoPath
    Optional HTTPS/HTTP URL or data URI to a logo shown in the top-right corner.

.OUTPUTS
    System.String  (HTML markup)

.EXAMPLE
    $html = New-CISM365HtmlReport -Tenant 'contoso.onmicrosoft.com' -Results $results -Summary $summary
    $html | Set-Content .\CISM365AuditReport.html -Encoding UTF8
#>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Tenant,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.IEnumerable]$Results,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]$Summary,

        [Parameter()]
        [string]$ReportTitle = 'CIS Microsoft 365 Audit Results',

        [Parameter()]
        [string]$LogoPath
    )

    # --- Helpers ---
    $EncodeHtml = {
        param($s)
        if ($null -eq $s) { return '' }
        [System.Net.WebUtility]::HtmlEncode($s.ToString())
    }

    function Get-StatusColor {
        param([string]$Status)
        if ($Status -like 'PASS*')  { return '#2e7d32' }  # green
        if ($Status -like 'FAIL*')  { return '#c62828' }  # red
        if ($Status -like 'ERROR*') { return '#6d4c41' }  # brown
        return '#ef6c00'                                  # orange (MANUAL/other)
    }

    function Build-ReferenceLinks {
        param([object]$Refs)
        if (-not $Refs) { return '' }

        $links = foreach ($r in $Refs) {
            if ([string]::IsNullOrWhiteSpace($r)) { continue }
            # Validate/normalize the URL if possible
            $href = $r
            try {
                $uri  = [System.Uri]::new($r)
                # Only accept http/https/data URIs to avoid javascript: etc.
                if (-not ($uri.Scheme -in @('http','https','data'))) {
                    # If invalid/undesired scheme, render as plain text
                    & $EncodeHtml $r
                    continue
                }
                $href = $uri.AbsoluteUri
            } catch {
                # Not a valid URI; render as encoded text
                & $EncodeHtml $r
                continue
            }
            # Display text is encoded; href is inserted with format operator
            $text = & $EncodeHtml $r
            ('<a href="{0}" target="_blank" rel="noopener noreferrer">{1}</a>' -f $href, $text)
        }

        ($links -join ', ')
    }

    # --- Summary fields (with sensible fallbacks) ---
    $gen = $Summary.GeneratedOn
    if (-not $gen) { $gen = Get-Date }

    $summaryPass   = $Summary.PASS
    $summaryFail   = $Summary.FAIL
    $summaryManual = $Summary.MANUAL
    $summaryError  = $Summary.ERROR
    $summaryTotal  = $Summary.Total
    $summaryCloud  = $Summary.Cloud

    $titleEncoded  = & $EncodeHtml $ReportTitle
    $tenantEncoded = & $EncodeHtml $Tenant
    $cloudEncoded  = & $EncodeHtml $summaryCloud
    $generatedOn   = $gen.ToString('yyyy-MM-dd HH:mm K')

    # --- Optional logo HTML ---
    $logoHtml = ''
    if ($LogoPath) {
        $safeLogo = $LogoPath
        try {
            $u = [System.Uri]::new($LogoPath)
            if ($u.Scheme -in @('http','https','data')) {
                $safeLogo = $u.AbsoluteUri
                $logoHtml = '<img class="logo" src="{0}" alt="Logo" />' -f $safeLogo
            }
        } catch {
            # Ignore invalid logo
        }
    }

    # --- Build control sections ---
    $sections = New-Object System.Text.StringBuilder
    $i = 0
    foreach ($r in $Results) {
        $i++

        $id          = & $EncodeHtml $r.Id
        $name        = & $EncodeHtml $r.Name
        $desc        = & $EncodeHtml $r.Description
        $rat         = & $EncodeHtml $r.Rationale
        $prof        = & $EncodeHtml $r.Profile
        $auto        = if ($r.Automated) { 'Automated' } else { 'Manual' }
        $autoEnc     = & $EncodeHtml $auto
        $statusText  = ($r.Status | Out-String).Trim()
        $statusEnc   = & $EncodeHtml $statusText
        $color       = Get-StatusColor -Status $statusText
        $refsHtml    = Build-ReferenceLinks -Refs $r.References

        [void]$sections.AppendLine(@"
<div class="control">
  <div class="control-header">
    <div class="control-title"><span class="cid">$id</span> $name</div>
    <div class="control-status" style="color: $color;">$statusEnc</div>
  </div>
  <div class="meta">
    <span class="meta-pill">Profile: $prof</span>
    <span class="meta-pill">$autoEnc</span>
  </div>
  <div class="details">
    <a class="collapsible" href="javascript:void(0)" onclick="toggle('d$i')">Show Details</a>
    <div id="d$i" class="details-panel">
      <p><strong>Description:</strong> $desc</p>
      <p><strong>Rationale:</strong> $rat</p>
      <p><strong>References:</strong> $refsHtml</p>
    </div>
  </div>
</div>
"@)
    }

    # --- Assemble final HTML ---
@"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>$titleEncoded</title>
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <style>
    :root{
      --bg:#ffffff; --fg:#222; --muted:#666; --border:#e0e0e0;
      --pill-pass:#2e7d32; --pill-fail:#c62828; --pill-man:#ef6c00; --pill-err:#6d4c41;
      --link:#0366d6; --panel:#f9f9f9;
    }
    *{box-sizing:border-box}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;margin:24px;background:var(--bg);color:var(--fg)}
    header{display:flex;align-items:center;justify-content:space-between;margin-bottom:18px}
    .title{font-size:22px;font-weight:600}
    .logo{max-height:40px;margin-left:12px}
    .sub{color:var(--muted);font-size:13px;margin-top:4px}
    .summary{margin:12px 0 24px 0}
    .pill{display:inline-block;padding:4px 10px;border-radius:999px;color:#fff;font-size:12px;margin-right:8px}
    .p-pass{background:var(--pill-pass)}
    .p-fail{background:var(--pill-fail)}
    .p-man {background:var(--pill-man)}
    .p-err {background:var(--pill-err)}
    .grid{display:grid;grid-template-columns:1fr;gap:16px}
    .control{border:1px solid var(--border);border-radius:8px;padding:14px;background:#fff}
    .control-header{display:flex;align-items:flex-start;justify-content:space-between;gap:12px}
    .control-title{font-size:16px;font-weight:600}
    .cid{display:inline-block;background:#eef2ff;color:#334155;border:1px solid #c7d2fe;border-radius:6px;padding:2px 6px;margin-right:6px;font-size:12px}
    .control-status{font-weight:600}
    .meta{margin-top:6px;color:var(--muted);font-size:12px}
    .meta-pill{display:inline-block;border:1px solid var(--border);border-radius:999px;padding:2px 8px;margin-right:6px;background:#fafafa}
    .details{margin-top:8px}
    .collapsible{color:var(--link);text-decoration:none;font-size:13px}
    .details-panel{display:none;margin-top:8px;background:var(--panel);border:1px solid var(--border);border-radius:6px;padding:10px}
    a { color: var(--link); }
    @media (min-width: 900px){
      .grid{grid-template-columns:1fr 1fr}
    }
  </style>
  <script>
    function toggle(id){
      var e=document.getElementById(id);
      if(!e) return;
      e.style.display = (e.style.display === 'none' || e.style.display === '') ? 'block' : 'none';
    }
  </script>
</head>
<body>
  <header>
    <div>
      <div class="title">$titleEncoded</div>
      <div class="sub">Tenant: $tenantEncoded &nbsp;&middot;&nbsp; Cloud: $cloudEncoded &nbsp;&middot;&nbsp; Generated: $generatedOn</div>
    </div>
    <div>$logoHtml</div>
  </header>

  <section class="summary">
    <span class="pill p-pass">PASS: $summaryPass</span>
    <span class="pill p-fail">FAIL: $summaryFail</span>
    <span class="pill p-man">MANUAL: $summaryManual</span>
    <span class="pill p-err">ERROR: $summaryError</span>
    <span class="pill" style="background:#374151">TOTAL: $summaryTotal</span>
  </section>

  <section class="grid">
    $($sections.ToString())
  </section>
</body>
</html>
"@
}
