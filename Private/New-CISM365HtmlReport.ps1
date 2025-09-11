function New-CISM365HtmlReport {
<#
.SYNOPSIS
    Builds the HTML report for CISM365Audit, grouped by section using Id prefix.

.DESCRIPTION
    - Section mapping is strictly by numeric prefix of the control Id.
    - Each control is visually separated by alternating shading and extra spacing.
    - Details toggle uses native HTML <details>/<summary>.
    - Optionally writes to -OutFile.
    - Status text is displayed below the control name as a colored pill/badge.
    - Table of Contents (TOC) entries now have clear vertical spacing.
    - Pills in summary show status name (PASS/FAIL/MANUAL/ERROR) and count.
    - Evidence and Audit Steps moved to Show Details area.
    - For MANUAL controls, includes the .Audit property in Show Details.
    - Each Control includes a scaffolded Notes section for manual entry, always at the bottom of Show Details.
    - If .Notes is provided in the result, it is displayed in the Notes section.
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
        [string]$LogoPath,

        [Parameter()]
        [string]$OutFile
    )

    $EncodeHtml = {
        param($s)
        if ($null -eq $s) { return '' }
        [System.Net.WebUtility]::HtmlEncode($s.ToString())
    }

    function Get-StatusColor {
        param([string]$Status)
        switch -Regex ($Status) {
            '^PASS'  { return '#2e7d32' }
            '^FAIL'  { return '#c62828' }
            '^ERROR' { return '#6d4c41' }
            '^MANUAL'{ return '#ef6c00' }
            default  { return '#374151' }
        }
    }

    function Build-ReferenceLinks {
        param([object]$Refs)
        if (-not $Refs) { return '' }
        $links = foreach ($r in $Refs) {
            if ([string]::IsNullOrWhiteSpace($r)) { continue }
            $href = $r
            try {
                $uri  = [System.Uri]::new($r)
                if (-not ($uri.Scheme -in @('http','https','data'))) {
                    & $EncodeHtml $r
                    continue
                }
                $href = $uri.AbsoluteUri
            } catch {
                & $EncodeHtml $r
                continue
            }
            $text = & $EncodeHtml $r
            ('<a href="{0}" target="_blank" rel="noopener noreferrer">{1}</a>' -f $href, $text)
        }
        ($links -join ', ')
    }

    # Helper to extract and remove "Evidence" and "Audit Steps" from status text
    function Extract-EvidenceAudit {
        param([string]$status)
        $evidence = ""
        $audit = ""

        # Find and extract Evidence: ... and Audit Steps: ... (case-insensitive)
        if ($status -match "(?s)Evidence:(.*?)(Audit Steps:|$)") {
            $evidence = ($Matches[1]).Trim()
        }
        if ($status -match "(?s)Audit Steps:(.*)") {
            $audit = ($Matches[1]).Trim()
        }
        # Remove them from status
        $cleanStatus = $status -replace "(?s)Evidence:.*?(Audit Steps:|$)", ""
        $cleanStatus = $cleanStatus -replace "(?s)Audit Steps:.*", ""
        $cleanStatus = $cleanStatus.Trim()
        return @{ Status = $cleanStatus; Evidence = $evidence; Audit = $audit }
    }

    $sectionOrder = @(
        @{ Key = '1'; Title = 'Section 1: Microsoft 365 Admin Center' },
        @{ Key = '2'; Title = 'Section 2: Microsoft 365 Defender' },
        @{ Key = '3'; Title = 'Section 3: Microsoft Purview' },
        @{ Key = '4'; Title = 'Section 4: Microsoft Intune Admin Center' },
        @{ Key = '5'; Title = 'Section 5: Microsoft Entra Admin Center' },
        @{ Key = '6'; Title = 'Section 6: Exchange Admin Center' },
        @{ Key = '7'; Title = 'Section 7: SharePoint Admin Center' },
        @{ Key = '8'; Title = 'Section 8: Microsoft Teams Admin Center' },
        @{ Key = '9'; Title = 'Section 9: Microsoft Fabric' }
    )

    $sectionBuilders = @{}
    foreach ($s in $sectionOrder) { $sectionBuilders[$s.Key] = New-Object System.Text.StringBuilder }

    $i = 0
    foreach ($r in $Results) {
        $i++
        $idStr = $r.Id.ToString()
        $prefix = if ($idStr -match '^(\d+)') { $Matches[1] } else { '1' }
        if (-not $sectionBuilders.ContainsKey($prefix)) { $prefix = '1' }

        $id          = & $EncodeHtml $r.Id
        $name        = & $EncodeHtml $r.Name
        $desc        = & $EncodeHtml $r.Description
        $rat         = & $EncodeHtml $r.Rationale
        $prof        = & $EncodeHtml $r.Profile
        $auto        = if ($r.Automated) { 'Automated' } else { 'Manual' }
        $autoEnc     = & $EncodeHtml $auto

        # Extract and clean status, evidence, audit steps
        $statusRaw   = ($r.Status | Out-String).Trim()
        $extract     = Extract-EvidenceAudit $statusRaw
        $statusText  = $extract.Status
        $evidence    = $extract.Evidence
        $audit       = $extract.Audit
        $statusEnc   = & $EncodeHtml $statusText
        $color       = Get-StatusColor -Status $statusText
        $refsHtml    = Build-ReferenceLinks -Refs $r.References

        # Handle Notes: If .Notes provided, encode and display it, else show placeholder
        $notesHtml = ""
        if ($r.PSObject.Properties.Name -contains "Notes" -and $r.Notes -and $r.Notes.Trim()) {
            $notesHtml = "<p class='notes'><strong>Notes:</strong> " + (& $EncodeHtml $r.Notes) + "</p>`n"
        } else {
            $notesHtml = "<p class='notes'><strong>Notes:</strong> <em>(Add notes here)</em></p>`n"
        }

        # Build Show Details content with Evidence and Audit inside if present
        $detailsPanel = @"
      <p><strong>Description:</strong> $desc</p>
      <p><strong>Rationale:</strong> $rat</p>
      <p><strong>References:</strong> $refsHtml</p>
"@
        if ($evidence) {
            $detailsPanel += "<p><strong>Evidence:</strong> $evidence</p>`n"
        }
        if ($audit) {
            $detailsPanel += "<p><strong>Audit Steps:</strong> $audit</p>`n"
        }
        # If this control is MANUAL and has a .Audit property, add it.
        if ($statusText -like "MANUAL*" -and $r.PSObject.Properties.Name -contains "Audit" -and $r.Audit) {
            $detailsPanel += "<p><strong>Manual Audit Steps:</strong> $($r.Audit)</p>`n"
        }
        # Notes section at the bottom (uses $notesHtml)
        $detailsPanel += "<hr />$notesHtml"

        [void]$sectionBuilders[$prefix].AppendLine(@"
<div class='control'>
  <div class='control-header'>
    <div class='control-title'><span class='cid'>$id</span> $name</div>
  </div>
  <div class='control-status' data-status='$statusText'>$statusEnc</div>
  <div class='meta'>
    <span class='meta-pill'>Profile: $prof</span>
    <span class='meta-pill'>$autoEnc</span>
  </div>
  <details class='details'>
    <summary class='collapsible'>Show Details</summary>
    <div class='details-panel'>
      $detailsPanel
    </div>
  </details>
</div>
"@)
    }

    $tocBuilder = New-Object System.Text.StringBuilder
    $bodyBuilder = New-Object System.Text.StringBuilder
    $secIndex = 0
    foreach ($s in $sectionOrder) {
        $secIndex++
        $key = $s.Key
        $title = $s.Title
        $anchor = "sec$secIndex"
        $count = 0
        if ($sectionBuilders.ContainsKey($key)) {
            $count = ([regex]::Matches($sectionBuilders[$key].ToString(), "<div class='control'").Count)
        }
        [void]$tocBuilder.AppendLine("<li><a href='#${anchor}'>$title</a> <span class='toc-count'>($count)</span></li>")

        [void]$bodyBuilder.AppendLine("<section id='$anchor' class='section-block'>")
        [void]$bodyBuilder.AppendLine("<div class='section-header'><h2>$title <span class='section-count'>($count)</span></h2></div>")
        if ($count -gt 0) {
            [void]$bodyBuilder.AppendLine("<div class='controls'>")
            [void]$bodyBuilder.AppendLine($sectionBuilders[$key].ToString())
            [void]$bodyBuilder.AppendLine("</div>")
        } else {
            [void]$bodyBuilder.AppendLine("<div class='empty'>No controls found for this section.</div>")
        }
        [void]$bodyBuilder.AppendLine("</section>")
    }

    $tocHtml = "<nav class='toc'><ul>" + $tocBuilder.ToString() + "</ul></nav>"
    $bodySections = $bodyBuilder.ToString()
    $generatedOn = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $logoHtml = ""
    if ($LogoPath) {
        $logoHtml = "<img src='$LogoPath' class='logo' alt='Logo' />"
    }

    # BULLETPROOF summary pills: use results directly, not $Summary object!
    $passCount   = ($Results | Where-Object { $_.Status -like 'PASS*' }).Count
    $failCount   = ($Results | Where-Object { $_.Status -like 'FAIL*' }).Count
    $manualCount = ($Results | Where-Object { $_.Status -like 'MANUAL*' }).Count
    $errorCount  = ($Results | Where-Object { $_.Status -like 'ERROR*' }).Count
    $totalCount  = $Results.Count

    $html = @"
<!doctype html>
<html lang='en'>
<head>
  <meta charset='utf-8' />
  <title>$ReportTitle</title>
  <meta name='viewport' content='width=device-width,initial-scale=1' />
  <style>
    :root{
      --bg:#ffffff; --fg:#222; --muted:#666; --border:#e0e0e0;
      --pill-pass:#2e7d32; --pill-fail:#c62828; --pill-man:#ef6c00; --pill-err:#6d4c41;
      --link:#0366d6; --panel:#f9f9f9;
      --shade-even: #fbfdff;
      --shade-odd:  #ffffff;
      --section-header-bg: #e7f1fb;
      --section-header-fg: #244a67;
      --section-header-border: #b4d5f3;
    }
    *{box-sizing:border-box}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;margin:24px;background:var(--bg);color:var(--fg)}
    header{display:flex;align-items:center;justify-content:space-between;margin-bottom:18px}
    .title{font-size:22px;font-weight:600}
    .logo{max-height:40px;margin-left:12px}
    .sub{color:var(--muted);font-size:13px;margin-top:4px}
    .summary{margin:12px 0 18px 0}
    .pill{display:inline-block;padding:4px 10px;border-radius:999px;color:#fff;font-size:12px;margin-right:8px}
    .p-pass{background:var(--pill-pass)}
    .p-fail{background:var(--pill-fail)}
    .p-man {background:var(--pill-man)}
    .p-err {background:var(--pill-err)}
    .layout{display:block;gap:16px}

    /* TOC improvements */
    .toc {
      border:1px solid var(--border);
      padding:12px;
      border-radius:8px;
      background:#fff;
      margin-bottom:12px;
    }
    .toc ul {
      list-style: none;
      padding: 0;
      margin: 0;
      display: block;
    }
    .toc li {
      margin-bottom: 14px;
    }
    .toc li:last-child {
      margin-bottom: 0;
    }
    .toc a {
      color: var(--link);
      text-decoration: none;
      padding: 6px 8px;
      border-radius: 6px;
      background: #fbfbfb;
      border: 1px solid var(--border);
      display: inline-block;
      transition: background 0.13s, border-color 0.13s;
    }
    .toc a:hover {
      background: #e7f1fb;
      border-color: #b4d5f3;
    }
    .toc-count {
      color: var(--muted);
      font-size: 12px;
      margin-left: 6px;
    }

    .section-block{margin-bottom:28px}
    .section-header{
      background: var(--section-header-bg);
      color: var(--section-header-fg);
      border-radius: 7px;
      border: 1.5px solid var(--section-header-border);
      padding: 10px 16px 10px 18px;
      margin-bottom: 12px;
      box-shadow: 0 2px 10px 0 rgba(36,74,103,0.04);
      font-size: 19px;
      font-weight: 600;
      display: flex;
      align-items: center;
    }
    .section-block h2{font-size:18px;margin-bottom:0;display:inline;}
    .section-count{color:var(--muted);font-size:12px;margin-left:12px}
    .grid{display:grid;grid-template-columns:1fr;gap:16px}

    /* controls wrapper and alternating shading */
    .controls { border-radius: 6px; overflow: hidden; border: 1px solid rgba(0,0,0,0.03); }
    .controls .control{
      border: none;
      border-bottom: 1px solid rgba(0,0,0,0.04);
      padding: 14px 16px;
      margin: 0 0 24px 0; /* vertical space between controls */
      transition: background-color 120ms ease, transform 80ms ease;
    }
    .controls .control:last-child { border-bottom: none; }
    .controls .control:nth-child(odd) { background: var(--shade-odd); }
    .controls .control:nth-child(even){ background: var(--shade-even); }
    .controls .control:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(16,24,40,0.06); }

    .control-header{display:flex;align-items:flex-start;gap:12px}
    .control-title{font-size:16px;font-weight:600}
    .cid{display:inline-block;background:#eef2ff;color:#334155;border:1px solid #c7d2fe;border-radius:6px;padding:2px 6px;margin-right:6px;font-size:12px}
    .control-status{
      font-weight:600; margin-top:4px; margin-bottom:4px;
      display:inline-block;
      border-radius:999px;
      padding:3px 10px;
      background:#f3f4f6;
      color:#374151;
    }
    .control-status[data-status^="PASS"]   { background: #e8f5e9; color: #2e7d32; }
    .control-status[data-status^="FAIL"]   { background: #ffebee; color: #c62828; }
    .control-status[data-status^="ERROR"]  { background: #ede7f6; color: #6d4c41; }
    .control-status[data-status^="MANUAL"] { background: #fff8e1; color: #ef6c00; }

    .meta{margin-top:6px;color:var(--muted);font-size:12px}
    .meta-pill{display:inline-block;border:1px solid var(--border);border-radius:999px;padding:2px 8px;margin-right:6px;background:#fafafa}
    details.details { margin-top: 8px; }
    details[open] .collapsible { font-weight: 600; }
    .collapsible{color:var(--link);background:none;border:none;font-size:13px;cursor:pointer;padding:0;display:inline;}
    .collapsible:focus{outline:2px solid var(--link);}
    .details-panel{margin-top:8px;background:var(--panel);border:1px solid var(--border);border-radius:6px;padding:10px}
    .notes { margin-top: 16px; font-size: 13px; color: #244a67; }
    .empty{color:var(--muted);padding:10px;background:#fbfbfb;border-radius:6px;border:1px dashed var(--border)}
    @media (min-width: 1100px){
      .layout{display:grid;grid-template-columns:1fr 1fr;gap:20px}
      .toc{grid-column:1 / -1}
    }
  </style>
</head>
<body>
  <header>
    <div>
      <div class='title'>$ReportTitle</div>
      <div class='sub'>Tenant: $Tenant &nbsp;&middot;&nbsp; Cloud: $($Summary.Cloud) &nbsp;&middot;&nbsp; Generated: $generatedOn</div>
    </div>
    <div>$logoHtml</div>
  </header>

  <section class='summary'>
    <span class='pill p-pass'>PASS ($passCount)</span>
    <span class='pill p-fail'>FAIL ($failCount)</span>
    <span class='pill p-man'>MANUAL ($manualCount)</span>
    <span class='pill p-err'>ERROR ($errorCount)</span>
    <span class='pill' style='background:#374151'>TOTAL: $totalCount</span>
  </section>

  <div class='layout'>
    $tocHtml
    <main>
      $bodySections
    </main>
  </div>
</body>
</html>
"@

    if ($OutFile) {
        Set-Content -Path $OutFile -Value $html -Encoding UTF8
        Write-Host "Report written to $OutFile"
    }

    return $html
}