
Get-MailUser -ResultSize unlimited | where { ($_.RecipientTypeDetails -eq "GuestMailUser") -and ($_.UserPrincipalName -like "*EXT*")} | Select Name,UserPrincipalName,HiddenFromAddress*,*smtp* | Export-Csv .\AllGuestUsers.csv -NoTypeInformation -Delimiter ";" -Encoding Unicode
