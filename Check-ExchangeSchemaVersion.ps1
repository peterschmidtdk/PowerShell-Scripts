<#
.SYNOPSIS
Check Exchange AD schema + forest + domain version markers.

.DESCRIPTION
Outputs:
- Forest (rangeUpper)    : CN=ms-Exch-Schema-Version-Pt (Schema NC) -> rangeUpper
- Forest (objectVersion) : msExchOrganizationContainer (Config NC)  -> objectVersion
- Domain (objectVersion) : CN=Microsoft Exchange System Objects      -> objectVersion (Default NC)

.NOTES
Author  : Peter
Script  : Check-ExchSchema.ps1
Version : 1.0.3
Updated : 2025-12-17

CHANGELOG
- 1.0.3 (2025-12-17): Simplified code to avoid copy/paste truncation issues and kept requested label names.
- 1.0.2 (2025-12-17): Renamed output labels.
- 1.0.1 (2025-12-17): Fixed try/catch structure.
- 1.0.0 (2025-12-17): Initial version.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    # Ensure AD module
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "ActiveDirectory module not found. Install RSAT (Active Directory tools) and try again."
    }
    Import-Module ActiveDirectory -ErrorAction Stop

    $root = Get-ADRootDSE

    # Forest (rangeUpper) = Schema marker
    $schemaNc = $root.SchemaNamingContext
    $schemaDn = "CN=ms-Exch-Schema-Version-Pt,$schemaNc"
    $forestRangeUpper = (Get-ADObject -Identity $schemaDn -Properties rangeUpper).rangeUpper
    Write-Output ("Forest (rangeUpper)`t`t: {0}" -f $forestRangeUpper)

    # Forest (objectVersion) = Org marker in Configuration NC
    $configNc = $root.ConfigurationNamingContext
    $orgFilter = "(objectClass=msExchOrganizationContainer)"
    $orgObj = Get-ADObject -LDAPFilter $orgFilter -SearchBase $configNc -Properties objectVersion,name

    if (-not $orgObj) {
        throw "Could not locate msExchOrganizationContainer in Configuration NC: $configNc"
    }

    # If multiple are returned (rare), take the first
    $orgFirst = $orgObj | Select-Object -First 1
    Write-Output ("Forest (objectVersion)`t: {0} (Org: {1})" -f $orgFirst.objectVersion, $orgFirst.name)

    # Domain (objectVersion) = Domain marker in Default NC
    $defaultNc = $root.DefaultNamingContext
    $domainDn = "CN=Microsoft Exchange System Objects,$defaultNc"
    $domainObjectVersion = (Get-ADObject -Identity $domainDn -Properties objectVersion).objectVersion
    Write-Output ("Domain (objectVersion)`t: {0}" -f $domainObjectVersion)
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
