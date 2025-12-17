<#
.SYNOPSIS
Checks Exchange AD version markers (Forest + Domain).

.DESCRIPTION
Outputs the three commonly used Exchange AD version markers, renamed as:
- Forest (rangeUpper)     : rangeUpper on CN=ms-Exch-Schema-Version-Pt (Schema NC)
- Forest (objectVersion)  : objectVersion on msExchOrganizationContainer (Configuration NC)
- Domain (objectVersion)  : objectVersion on CN=Microsoft Exchange System Objects (Default NC)

Optionally, with -AllDomains, prints Domain (objectVersion) per domain as well.

.REQUIREMENTS
- RSAT Active Directory PowerShell module (ActiveDirectory)
- Permissions to read Schema, Configuration, and Domain naming contexts

.NOTES
Author  : Peter
Script  : Check-ExchSchema.ps1
Version : 1.0.2
Updated : 2025-12-17

CHANGELOG
- 1.0.2 (2025-12-17): Renamed output labels to Forest/Domain naming.
- 1.0.1 (2025-12-17): Fixed try/catch structure and ensured braces are balanced.
- 1.0.0 (2025-12-17): Initial version.

.PARAMETER AllDomains
If specified, checks Domain (objectVersion) for every domain in the forest (not just DefaultNamingContext).

.EXAMPLE
.\Check-ExchSchema.ps1

.EXAMPLE
.\Check-ExchSchema.ps1 -AllDomains
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$AllDomains
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-ADModule {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "ActiveDirectory module not found. Install RSAT (Active Directory tools) and try again."
    }
    Import-Module ActiveDirectory -ErrorAction Stop
}

try {
    Ensure-ADModule

    $root = Get-ADRootDSE

    # --- Forest (rangeUpper) ---
    $schemaNc = $root.SchemaNamingContext
    $schemaDn = "CN=ms-Exch-Schema-Version-Pt,$schemaNc"
    $forestRangeUpper = (Get-ADObject -Identity $schemaDn -Properties rangeUpper).rangeUpper
    Write-Output "Forest (rangeUpper)             : $forestRangeUpper"

    # --- Domain (objectVersion) - DefaultNamingContext ---
    $defaultNc = $root.DefaultNamingContext
    $mesoDnDefault = "CN=Microsoft Exchange System Objects,$defaultNc"
    $domainObjectVersionDefault = (Get-ADObject -Identity $mesoDnDefault -Properties objectVersion).objectVersion
    Write-Output "Domain (objectVersion)          : $domainObjectVersionDefault"

    # --- Forest (objectVersion) - Configuration / Org ---
    $configNc = $root.ConfigurationNamingContext
    $orgFilter = "(objectClass=msExchOrganizationContainer)"
    $orgObj = Get-ADObject -LDAPFilter $orgFilter -SearchBase $configNc -Properties objectVersion,name |
        Select-Object -First 1

    if (-not $
