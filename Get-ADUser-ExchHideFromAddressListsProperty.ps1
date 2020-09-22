#Get all AD users with the Exchange Hidden From Address Lists attribute set to True
Get-ADUser -filter {-not(msExchHideFromAddressLists -eq $true)} -searchbase “OU=xxxxxx,dc=domainname,dc=local”
