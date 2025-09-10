function Get-CISM365Control_1_3_3 {
    <#
    Returns a control descriptor. Audit is a ScriptBlock invoked by the runner.
    #>
    return @{
        Id = '1.3.3'
        Name = "Ensure 'External sharing' of calendars is not available"
        Profile = 'L2'
        Automated = $true
        Services = @('ExchangeOnline')
        Description = "Verify external calendar sharing is disabled by inspecting Exchange Online sharing policies."
        Rationale = "Prevent disclosure of calendar details to external users."
        References = @('https://learn.microsoft.com/en-us/microsoft-365/admin/manage/share-calendars-with-external-users?view=o365-worldwide')
        Audit = {
            try {
                $ControlId = '1.3.3'
                $Title = "Ensure 'External sharing' of calendars is not available"
                $References = @('https://learn.microsoft.com/en-us/microsoft-365/admin/manage/share-calendars-with-external-users?view=o365-worldwide')

                # Verify ExchangeOnlineManagement module exists
                if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
                    return [PSCustomObject]@{
                        Id = $ControlId; Name = $Title; Profile = 'L2'; Automated = $true; Status = 'ERROR';
                        Findings = 'ExchangeOnlineManagement PowerShell module is not installed in this environment.';
                        Remediation = 'Install-Module ExchangeOnlineManagement -Scope CurrentUser; then run Connect-ExchangeOnline to establish a session.';
                        References = $References
                    }
                }

                # Detect existing Exchange Online session (do NOT create/close sessions)
                $exoSession = Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
                    ($_.ConfigurationName -and ($_.ConfigurationName -match 'Microsoft.Exchange')) -or
                    ($_.ConnectionUri -and ($_.ConnectionUri -match 'exchange'))
                }

                if (-not $exoSession) {
                    return [PSCustomObject]@{
                        Id = $ControlId; Name = $Title; Profile = 'L2'; Automated = $true; Status = 'MANUAL';
                        Findings = 'No active Exchange Online session detected in this PowerShell session.';
                        Remediation = 'Run Connect-ExchangeOnline -UserPrincipalName admin@contoso.com to establish a session, then re-run the audit.';
                        References = $References
                    }
                }

                # Retrieve sharing policies
                try {
                    $allPolicies = Get-SharingPolicy -ErrorAction Stop
                } catch {
                    return [PSCustomObject]@{
                        Id = $ControlId; Name = $Title; Profile = 'L2'; Automated = $true; Status = 'MANUAL';
                        Findings = "Failed to retrieve sharing policies via Get-SharingPolicy: $($_.Exception.Message)";
                        Remediation = 'Ensure the connected account has sufficient Exchange administrative permissions and that Exchange Online cmdlets are functioning.';
                        References = $References
                    }
                }

                # Identify calendar-related sharing policies
                $calendarPolicies = $allPolicies | Where-Object {
                    ($_.Domains -and ($_.Domains -match 'Calendar' -or $_.Domains -match 'calendar' -or $_.Domains -like '*CalendarSharing*')) -or
                    ($_.Name -and ($_.Name -match 'Calendar' -or $_.Name -match 'calendar'))
                }

                if (-not $calendarPolicies -or $calendarPolicies.Count -eq 0) {
                    return [PSCustomObject]@{
                        Id = $ControlId; Name = $Title; Profile = 'L2'; Automated = $true; Status = 'MANUAL';
                        Findings = 'No calendar-specific sharing policies were detected via Get-SharingPolicy. Tenant may be using the Microsoft 365 Admin Center org setting for calendar sharing.';
                        Remediation = "Manually verify in Microsoft 365 Admin Center -> Settings -> Org settings -> Services -> Calendar that external calendar sharing is disabled, or create/identify sharing policies and ensure Enabled is False.";
                        References = $References
                    }
                }

                $enabledPolicies = $calendarPolicies | Where-Object { $_.Enabled -eq $true }

                if ($enabledPolicies.Count -eq 0) {
                    return [PSCustomObject]@{
                        Id = $ControlId; Name = $Title; Profile = 'L2'; Automated = $true; Status = 'PASS';
                        Findings = "All discovered calendar-sharing policy(ies) are disabled. Policies evaluated: $($calendarPolicies.Count)";
                        Remediation = 'No action required.';
                        References = $References
                    }
                } else {
                    $names = ($enabledPolicies | Select-Object -ExpandProperty Name) -join '; '
                    return [PSCustomObject]@{
                        Id = $ControlId; Name = $Title; Profile = 'L2'; Automated = $true; Status = 'FAIL';
                        Findings = "Found $($enabledPolicies.Count) enabled calendar-sharing policy(ies): $names. These must be disabled.";
                        Remediation = "For each policy: Set-SharingPolicy -Identity '<PolicyName>' -Enabled `$False or disable external calendar sharing in the Microsoft 365 Admin Center.";
                        References = $References
                    }
                }
            } catch {
                return [PSCustomObject]@{
                    Id = '1.3.3'; Name = $Title; Profile = 'L2'; Automated = $true; Status = 'ERROR';
                    Findings = "Unhandled error: $($_.Exception.Message)";
                    Remediation = 'Investigate and ensure Exchange Online cmdlets and connectivity are available.';
                    References = $References
                }
            }
        } # Audit scriptblock
    } # descriptor
}