# Oneliner on getting a list of all Deleted Users in Office 365, with a specific domain in UPN
# Makue sure you are connect to MSonline

Get-MsolUser -ReturnDeletedUsers | Where { $_.UserPrincipalName -like "*@domainname.com"} | Select DisplayName,UserPrincipalName,SoftDeletionTimestamp | Sort SoftDeletionTimestamp
