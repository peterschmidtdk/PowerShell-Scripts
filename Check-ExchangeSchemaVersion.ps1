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
Version : 1.0.4
Updated : 2025-12-17

CHANGELOG
- 1.0.4 (2025-12-17): Fixed output alignment using fixed-width formatting.
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
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "ActiveDirectory module not found. Install RSAT (Active Directory tools) and try again."
    }
    Import-Module ActiveDirectory -ErrorAction Stop

    $root = Get-ADRootDSE
    $labelWidth = 28  # adjust if you want more/less spacing

    # Forest (rangeUpper)
    $schemaNc = $root.SchemaNamingContext
    $schemaDn = "CN=ms-Exch-Schema-Version-Pt,$schemaNc"
    $forestRangeUpper = (Get-ADObject -Identity $schemaDn -Properties rangeUpper).rangeUpper

    # Forest (objectVersion)
    $configNc = $root.ConfigurationNamingContext
    $orgFilter = "(objectClass=msExchOrganizationContainer)"
    $orgObj = Get-ADObject -LDAPFilter $orgFilter -SearchBase $configNc -Properties objectVersion,name
    if (-not $orgObj) { throw "Could not locate msExchOrganizationContainer in Configuration NC: $configNc" }
    $orgFirst = $orgObj | Select-Object -First 1

    # Domain (objectVersion)
    $defaultNc = $root.DefaultNamingContext
    $domainDn = "CN=Microsoft Exchange System Objects,$defaultNc"
    $domainObjectVersion = (Get-ADObject -Identity $domainDn -Properties objectVersion).objectVersion

    # Clean aligned output
    Write-Output ("{0,-$labelWidth}: {1}" -f "Forest (rangeUpper)",    $forestRangeUpper)
    Write-Output ("{0,-$labelWidth}: {1} (Org: {2})" -f "Forest (objectVersion)", $orgFirst.objectVersion, $orgFirst.name)
    Write-Output ("{0,-$labelWidth}: {1}" -f "Domain (objectVersion)", $domainObjectVersion)
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
