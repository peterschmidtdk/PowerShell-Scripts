<#
.SYNOPSIS
Checks Exchange AD schema and version markers (Schema, Domain, Configuration).

.DESCRIPTION
Runs against on-prem Active Directory and outputs the three commonly used Exchange AD version markers:
- Schema version: rangeUpper on CN=ms-Exch-Schema-Version-Pt (Schema NC)
- Domain version: objectVersion on CN=Microsoft Exchange System Objects (Default NC)
- Forest/Org version: objectVersion on msExchOrganizationContainer (Configuration NC)

These raw numbers can be compared with Microsoft’s "Exchange Active Directory versions" table
to confirm whether PrepareSchema / PrepareAD / PrepareDomain have been applied to the expected level.

.REQUIREMENTS
- RSAT Active Directory PowerShell module (Import-Module ActiveDirectory)
- Permissions to read Schema, Configuration, and Domain naming contexts

.NOTES
Author  : Peter
Script  : Get-ExchangeADVersions-Simple.ps1
Version : 1.0.0
Updated : 2025-12-17

Versioning policy:
- Increment Version on ANY script change.
- Update the date and changelog entry accordingly.

.CHANGELOG
- 1.0.0 (2025-12-17): Initial version based on user’s legacy script, with validation and cleaner output.

.PARAMETER AllDomains
If set, also checks the domain marker for every domain in the forest (not just DefaultNamingContext).

.EXAMPLE
.\Get-ExchangeADVersions-Simple.ps1

.EXAMPLE
.\Get-ExchangeADVersions-Simple.ps1 -AllDomains
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

    # --- Schema marker ---
    $sc = $root.SchemaNamingContext
    $schemaDn = "CN=ms-Exch-Schema-Version-Pt,$sc"
    $schemaRangeUpper = (Get-ADObject -Identity $schemaDn -Properties rangeUpper).rangeUpper
    Write-Output "RangeUpper (Schema)              : $schemaRangeUpper"

    # --- Domain marker (DefaultNamingContext) ---
    $dc = $root.DefaultNamingContext
    $domainDn = "CN=Microsoft Exchange System Objects,$dc"
    $domainObjectVersion = (Get-ADObject -Identity $domainDn -Properties objectVersion).objectVersion
    Write-Output "ObjectVersion (Domain - Default) : $domainObjectVersion"

    # --- Configuration / Org marker ---
    $cc = $root.ConfigurationNamingContext
    $fl = "(objectClass=msExchOrganizationContainer)"

    $orgObj = Get-ADObject -LDAPFilter $fl -SearchBase $cc -Properties objectVersion,name |
        Select-Object -First 1

    if (-not $orgObj) {
        throw "Could not locate msExchOrganizationContainer in Configuration NC: $cc"
    }

    Write-Output "ObjectVersion (Configuration)    : $($orgObj.objectVersion)  (Org: $($orgObj.name))"

    # --- Optional: check all domains in forest ---
    if ($AllDomains) {
        Write-Output ""
        Write-Output "Per-domain ObjectVersion (Microsoft Exchange System Objects):"

        $forest = Get-ADForest
        foreach ($d in ($forest.Domains | Sort-Object)) {
            try {
                $dDn = (Get-ADDomain -Identity $d).DistinguishedName
                $mesoDn = "CN=Microsoft Exchange System Objects,$dDn"
                $v = (Get-ADObject -Identity $mesoDn -Properties objectVersion).objectVersion
                Write-Output (" - {0} : {1}" -f $d, $v)
            }
            catch {
                Write-Output (" - {0} : ERROR ({1})" -f $d, $_.Exception.Message)
            }
        }
    }
}
