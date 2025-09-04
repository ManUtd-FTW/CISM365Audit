function Start-CISM365Audit {
<#
.SYNOPSIS
Runs an enhanced CIS Microsoft 365 audit and writes an HTML report.

.DESCRIPTION
- Connects to Microsoft 365 services (Graph, EXO) unless -NoConnect is specified.
- Evaluates 8 CIS controls (existing + new).
- Generates an HTML report with Description, Rationale, References, and collapsible details.
- Returns raw results for programmatic use.

.PARAMETER Tenant
Tenant GUID or domain (e.g., contoso.onmicrosoft.com).

.PARAMETER OutputPath
Path for the HTML report. Default: .\CISM365AuditReport.html

.PARAMETER NoConnect
Skip connection wrapper and assume you’re already connected.

.EXAMPLE
Start-CISM365Audit -Tenant contoso.onmicrosoft.com -Verbose
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Tenant,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = ".\CISM365AuditReport.html",

    [switch]$NoConnect
)

# Determine TenantId or TenantDomain
$tenantId = $null
$tenantDomain = $null
if ($Tenant -match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
    $tenantId = $Tenant
} else {
    $tenantDomain = $Tenant
}

# Connect if needed
if (-not $NoConnect) {
    if (Get-Command Connect-CISM365Services -ErrorAction SilentlyContinue) {
        $verboseOn = ($VerbosePreference -eq 'Continue')
        $conn = Connect-CISM365Services -Services Graph,ExchangeOnline `
            -TenantDomain $tenantDomain -TenantId $tenantId `
            -ErrorOnFailure -Verbose:$verboseOn
    } else {
        # Minimal fallback
        if (-not (Get-MgContext)) { Connect-MgGraph -Scopes "Directory.Read.All" }
        if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
            Connect-ExchangeOnline -Organization $tenantDomain -ShowBanner:$false
        }
    }
}

# Ensure output directory (robust even if the file doesn't exist yet)
if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    $fullOutputPath = $OutputPath
} else {
    $fullOutputPath = Join-Path -Path (Get-Location) -ChildPath $OutputPath
}

$dir = Split-Path -Path $fullOutputPath -Parent
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# HTML encode helper
$EncodeHtml = { param($s) if ($null -eq $s) { '' } else { [System.Net.WebUtility]::HtmlEncode($s.ToString()) } }

# --- CIS Controls ---
$CISControls = @(
    @{
        Id='1.1.3'; Name='Ensure 2–4 Global Admins are designated';
        Description='Limit the number of Global Administrators to reduce risk.';
        Rationale='Too many global admins increase attack surface.';
        References=@('https://learn.microsoft.com/en-us/azure/active-directory/roles/best-practices');
        Audit={
            $gaTemplateId='62e90394-69f5-4237-9190-012177145e10'
            $roles=Get-MgDirectoryRole -All
            $role=$roles|Where-Object{$_.RoleTemplateId -eq $gaTemplateId}
            if(-not $role){return 'MANUAL (Role not activated)'}
            $members=Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All
            $users=[System.Collections.Generic.HashSet[string]]::new()
            foreach($m in $members){
                if($m.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user'){[void]$users.Add($m.Id)}
            }
            $count=$users.Count
            if($count -ge 2 -and $count -le 4){"PASS ($count global admins)"}else{"FAIL ($count global admins)"}
        }
    },
    @{
        Id='2.1.9'; Name='Ensure DKIM is enabled for all custom domains';
        Description='DomainKeys Identified Mail (DKIM) helps prevent spoofing.';
        Rationale='DKIM adds cryptographic authentication to email headers.';
        References=@('https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dkim-to-validate-outbound-email');
        Audit={
            $domains=Get-AcceptedDomain|Where-Object{$_.DomainType -eq 'Authoritative' -and $_.DomainName -notlike '*.onmicrosoft.com'}
            if(-not $domains){return 'MANUAL (No custom domains)'}
            $fail=$false;$list=@()
            foreach($d in $domains){
                try{$cfg=Get-DkimSigningConfig -Identity $d.DomainName;if(-not $cfg.Enabled){$fail=$true;$list+=$d.DomainName}}catch{$fail=$true;$list+=$d.DomainName}
            }
            if($fail){"FAIL (DKIM not enabled for: $($list -join ', '))"}else{'PASS (DKIM enabled for all)'}
        }
    },
    @{
        Id='2.1.1'; Name='Ensure Safe Links for Office Apps is enabled';
        Description='Safe Links protects users from malicious URLs in Office apps.';
        Rationale='Helps prevent phishing and malware attacks.';
        References=@('https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-links');
        Audit={
            try{$p=Get-AtpPolicyForO365;if($p.EnableSafeLinksForOffice -and $p.EnableSafeLinksForClients){'PASS (Safe Links enabled)'}else{'FAIL (Safe Links not fully enabled)'}}catch{'MANUAL (Unable to retrieve policy)'}
        }
    },
    @{
        Id='1.2.1'; Name='Ensure Security Defaults is enabled';
        Description='Security Defaults enforce MFA and other protections.';
        Rationale='Helps protect against common identity attacks.';
        References=@('https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/concept-fundamentals-security-defaults');
        Audit={
            try{$s=Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy;if($s.IsEnabled){'PASS (Security Defaults enabled)'}else{'FAIL (Disabled)'}}catch{'MANUAL (Unable to retrieve Security Defaults)'}
        }
    },
    @{
  Id='1.3.1'; Name='Ensure MFA is enabled for all users';
  Description='Multi-Factor Authentication adds an extra layer of security.';
  Rationale='Reduces risk of credential compromise.';
  References=@(
    'https://learn.microsoft.com/en-us/graph/api/resources/authenticationmethods-usage-insights-overview'
  );
  Audit={
    try {
      # Requires: Microsoft.Graph.Reports; Scopes: Reports.Read.All (and typically Directory.Read.All)
      $details = Get-MgReportAuthenticationMethodsUserRegistrationDetail -All
      $noMfa = $details | Where-Object { -not $_.IsMfaRegistered }
      if ($noMfa.Count -gt 0) {
        "FAIL ($($noMfa.Count) users not registered for MFA)"
      } else {
        'PASS (All users registered for MFA)'
      }
    } catch {
      'MANUAL (Unable to check MFA via Graph reports)'
    }
  }
},
    @{
        Id='2.1.10'; Name='Ensure DMARC is configured';
        Description='DMARC helps prevent email spoofing and phishing.';
        Rationale='Provides domain-level email authentication policy.';
        References=@('https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dmarc-to-validate-email');
        Audit={
            try{$domains=Get-AcceptedDomain|Where-Object{$_.DomainType -eq 'Authoritative'};$fail=@();foreach($d in $domains){$txt=(Resolve-DnsName -Name \"_dmarc.$($d.DomainName)\" -Type TXT -ErrorAction SilentlyContinue);if(-not $txt){$fail+=$d.DomainName}};if($fail){\"FAIL (No DMARC for: $($fail -join ', '))\"}else{'PASS (DMARC configured)'}}catch{'MANUAL (Unable to check DMARC)'}
        }
    },
    @{
        Id='8.1.1'; Name='Ensure mailbox auditing is enabled';
        Description='Mailbox auditing logs actions for security investigations.';
        Rationale='Helps detect unauthorized mailbox access.';
        References=@('https://learn.microsoft.com/en-us/microsoft-365/compliance/enable-mailbox-auditing');
        Audit={
            try{$cfg=Get-OrganizationConfig;if($cfg.AuditDisabled -eq $false){'PASS (Mailbox auditing enabled)'}else{'FAIL (Mailbox auditing disabled)'}}catch{'MANUAL (Unable to check mailbox auditing)'}
        }
    },
    @{
        Id='8.5.1'; Name='Ensure external sharing is restricted';
        Description='Restrict external sharing to reduce data leakage risk.';
        Rationale='Prevents unauthorized access to sensitive content.';
        References=@('https://learn.microsoft.com/en-us/sharepoint/external-sharing-overview');
        Audit={
            try{$spo=Get-SPOTenant;if($spo.SharingCapability -eq 'Disabled' -or $spo.SharingCapability -eq 'ExistingExternalUserSharingOnly'){'PASS (External sharing restricted)'}else{'FAIL (External sharing too permissive)'}}catch{'MANUAL (Unable to check external sharing)'}
        }
    }
)

# Run audits
$results=@()
foreach($ctrl in $CISControls){
    Write-Host \"Checking $($ctrl.Id): $($ctrl.Name)...\" -ForegroundColor Cyan
    try{$status=& $ctrl.Audit}catch{$status=\"ERROR: $($_.Exception.Message)\"}
    $results+=[pscustomobject]@{
        Id=$ctrl.Id;Name=$ctrl.Name;Description=$ctrl.Description;Rationale=$ctrl.Rationale;References=$ctrl.References;Status=$status
    }
}

# Build HTML
$pass=($results|Where-Object{$_.Status -like 'PASS*'}).Count
$fail=($results|Where-Object{$_.Status -like 'FAIL*'}).Count
$manual=($results|Where-Object{$_.Status -like 'MANUAL*'}).Count
$error=($results|Where-Object{$_.Status -like 'ERROR*'}).Count
$gts=Get-Date -Format 'yyyy-MM-dd HH:mm K'

$html=@"
<!doctype html>
<html><head><meta charset='utf-8'><title>CIS M365 Audit</title>
<style>
body{font-family:Segoe UI,Arial;margin:24px;color:#222}
.summary .pill{display:inline-block;padding:2px 8px;border-radius:999px;margin-right:6px;font-size:12px;color:#fff}
.p-pass{background:#2e7d32}.p-fail{background:#c62828}.p-man{background:#ef6c00}.p-err{background:#6d4c41}
.details{margin:8px 0;padding:8px;background:#f9f9f9;border:1px solid #ddd}
.collapsible{cursor:pointer;color:#0366d6;text-decoration:underline}
</style>
<script>
function toggle(id){var e=document.getElementById(id);e.style.display=(e.style.display==='none')?'block':'none';}
</script>
</head><body>
<h2>CIS Microsoft 365 Audit Results for $Tenant</h2>
<div>Generated: $gts</div>
<div class='summary'>
<span class='pill p-pass'>PASS: $pass</span>
<span class='pill p-fail'>FAIL: $fail</span>
<span class='pill p-man'>MANUAL: $manual</span>
<span class='pill p-err'>ERROR: $error</span>
</div>
"@

$i=0
foreach($r in $results){
    $i++
    $color=if($r.Status -like 'PASS*'){'#2e7d32'}elseif($r.Status -like 'FAIL*'){'#c62828'}elseif($r.Status -like 'ERROR*'){'#6d4c41'}else{'#ef6c00'}
    $refs = ($r.References | ForEach-Object { '<a href="{0}" target="_blank" rel="noopener noreferrer">{0}</a>' -f $_ }) -join ', '
    $html+=@"
<div>
<h3>$($r.Id): $($r.Name)</h3>
<p><strong>Status:</strong> <span style='color:$color'>$($r.Status)</span></p>
<p class='collapsible' onclick=\"toggle('d$i')\">Show Details</p>
<div id='d$i' class='details' style='display:none'>
<p><strong>Description:</strong> $($r.Description)</p>
<p><strong>Rationale:</strong> $($r.Rationale)</p>
<p><strong>References:</strong> $refs</p>
</div>
</div>
"@
}
$html+='</body></html>'
$html | Out-File -FilePath $fullOutputPath -Encoding UTF8
Write-Host "Audit complete. Results saved to $fullOutputPath" -ForegroundColor Green
$results
}
