# Need to connect to Exchange Online before running.
# This script will show all Guest MailUsers and export the values to CSV, so it is possible to see if they are visible in the Exchange GAL.

Get-MailUser -ResultSize unlimited | where { ($_.RecipientTypeDetails -eq "GuestMailUser") -and ($_.UserPrincipalName -like "*EXT*")} | Select Name,UserPrincipalName,HiddenFromAddress*,*smtp* | Export-Csv .\AllGuestUsers.csv -NoTypeInformation -Delimiter ";" -Encoding Unicode
