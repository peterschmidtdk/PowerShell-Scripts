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

# This will show all mailboxes that are hidden in Exchange GAL
Get-Mailbox -ResultSize Unlimited | Where {$_.HiddenFromAddressListsEnabled -eq $True} | Select Name, UserPrincipalName, HiddenFromAddressListsEnabled

# This will show all mailboxes that are unhidden in Exchange GAL
Get-Mailbox -ResultSize Unlimited | Where {$_.HiddenFromAddressListsEnabled -eq $False} | Select Name, UserPrincipalName, HiddenFromAddressListsEnabled
