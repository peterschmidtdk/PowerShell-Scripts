# Author: Peter Schmidt
# Blog: www.msdigest.net
# Company: NeoConsulting www.neoconsulting.dk
# Version 1.0
# Notes: Finds the UPN Suffix of AD User and changes it to a new UPN Suffix.

#Import AD Module
Import-Module ActiveDirectory

$oldSuffix = "theoldUPNsuffix.com"
$newSuffix = "theNEWUPNsuffix.com"

#Target an OU
$ou = "OU=TestOU,DC=domain,DC=com"
#DC server
$server = "DCSERVERNAME"

Get-ADUser -SearchBase $ou -filter * | ForEach-Object {
  $newUpn = $_.UserPrincipalName.Replace($oldSuffix,$newSuffix)
  $_ | Set-ADUser -server $server -UserPrincipalName $newUpn
}
