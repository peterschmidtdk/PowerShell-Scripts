<#
.SYNOPSIS
Checks Exchange AD schema and version markers (Schema, Domain, Configuration).

.DESCRIPTION
Outputs the three commonly used Exchange AD version markers:
- Schema version: rangeUpper on CN=ms-Exch-Schema-Version-Pt (Schema NC)
- Domain version: objectVersion on CN=Microsoft Exchange System Objects (Default NC)
- Forest/Org version: objectVersion on msExchOrganizationContainer (Configuration NC)

Compare the raw numbers to Microsoft’s "Exchange Active Directory versions" table to confirm
PrepareSchema / PrepareAD / PrepareDomain levels.

.REQUIREMENTS
- RSAT Active Directory PowerShell module (ActiveDirectory)
- Permissions to read Schema, Configuration, and Domain naming contexts

.NOTES
Author  : Peter
Script  : Check-ExchSchema.ps1
Version : 1.0.1
Updated : 2025-12-17

CHANGELOG
- 1.0.1 (2025-12-17): Fixed try/catch structure and ensured braces are balanced.
- 1.0.0 (2025-12-17): Initial version.

.PARAMETER AllDomains
If specified, checks the domain marker for every domain in the forest (not just DefaultNamingContext).

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
catch {
    Write-Error $_.Exception.Message
    exit 1
}
