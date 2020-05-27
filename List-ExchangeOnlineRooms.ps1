#Connect to Exchange Online first
#Use the command here to report on the Rooms in EXO
Get-Recipient -RecipientTypeDetails RoomMailbox | Select DisplayName,PrimarySmtpAddress,RecipientType,HiddenFromAddressListsEnabled | Export-Csv .\Eniig-Rooms.csv -Encoding Unicode -Delimiter ";"
