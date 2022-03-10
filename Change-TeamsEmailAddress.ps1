<#
.SYNOPSIS
  To use the script, update the variables with the Group name of the Teams or underlying Office 365 Group.
  Set the existing e-mail aliases and the new addresses, you want to change to.
  Before running the script, connect to Exchange Online (connect-exchangeonline).

.DESCRIPTION
  This script can be used to change the primary e-mail address on a Teams or Office 365 Group.

.NOTES
  Version:        1.0
  Author:         Peter Schmidt
  Creation Date:  2022.03.10
  Purpose/Change: Initial script development
  
#>

$GroupName = "NameOfTheTeamsOrOffice365Group"
$ExistingEmailAddress = "oldalias@domainname.com"
$ExistingOnMSAddress = "oldalias@domainname.onmicrosoft.com"
$NewEmailAddress = "newalias@domainname.com"
$NewOnMSAddress = "newalias@domainname.onmicrosoft.com"

#Set the new primary e-mail alias to the Office 365 Group:
Set-UnifiedGroup -Identity $GroupName -EmailAddresses: @{Add ="$NewEmailAddress"}

#Set the new onmicrosoft e-mail alias to the Office 365 Group:
Set-UnifiedGroup -Identity $GroupName -EmailAddresses: @{Add ="$NewOnMSAddress"}

#Set the new primary alias, to be the primary e-mail address of the Office 365 Group:
Set-UnifiedGroup -Identity $GroupName -PrimarySmtpAddress "$NewEmailAddress"

#Removes the old primary e-mail alias of the Office 365 Group:
Set-UnifiedGroup -Identity $GroupName -EmailAddresses: @{Remove="$ExistingEmailAddress"}

#Removes the existing onmicrosoft address of the Office 365 Group:
Set-UnifiedGroup -Identity $GroupName -EmailAddresses: @{Remove="$ExistingOnMSAddress"}

