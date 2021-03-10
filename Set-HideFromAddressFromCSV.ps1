# This will hide users from the Exchange GAL, based on import from CSV

Import-Csv 'C:\temp\Mailboxes.csv' | ForEach-Object {
$UserPrincipalName = $_."UserPrincipalName"
Set-Mailbox -Identity $UserPrincipalNamen -HiddenFromAddressListsEnabled $true
}

# This will unhide users from the Exchange GAL, based on import from CSV

Import-Csv 'C:\temp\Mailboxes.csv' | ForEach-Object {
$UserPrincipalName = $_."UserPrincipalName"
Set-Mailbox -Identity $UserPrincipalNamen -HiddenFromAddressListsEnabled $false
}
