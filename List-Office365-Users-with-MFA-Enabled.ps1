#Two commands to identity Users who have registered for MFA and the ones, who have not.
#Reference: https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-reporting?fbclid=IwAR02bmCBuiOg4jPUOyeacl_Vpz0lNyLjjo7_AorMcg9zgG3r9pVfLkE2d-A

#Identify users who have registered for MFA using the PowerShell that follows.
Get-MsolUser -All | where {$_.StrongAuthenticationMethods -ne $null} | Select-Object -Property UserPrincipalName

#Identify users who have not registered for MFA using the PowerShell that follows.
Get-MsolUser -All | where {$_.StrongAuthenticationMethods -ne $null} | Select-Object -Property UserPrincipalName
