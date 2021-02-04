# Set Password to never expires for specified Azure AD / Office 365 users
#

#Using the Azure AD cmdlets:
Get-AzureADUser -SearchString user@domain.com | Set-AzureADUser -PasswordPolicies DisablePasswordExpiration

#Get list of users with Password Expire:
Get-AzureADUser | ? {$_.PasswordPolicies -match "DisablePasswordExpiration"}

#Using the MSOL cmdlets
Set-MsolUser -UserPrincipalName user@domain.com -PasswordNeverExpires $true

#Get list of users with Password Expire:
Get-MsolUser -All | Set-MsolUser -PasswordNeverExpires $true
