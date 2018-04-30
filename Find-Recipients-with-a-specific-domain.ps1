#This simple script find all Exchange Recipients with a specific domain
#This count the number of objects without this domain:
(Get-Recipient -ResultSize unlimited| Where {$_.EmailAddresses -NotLike "*@mydomain.com"} | FL DisplayName,EmailAddresses).count

#This shows all recipients:
Get-Recipient -ResultSize unlimited| Where {$_.EmailAddresses -NotLike "*@mydomain.com"} | FL DisplayName,EmailAddresses
