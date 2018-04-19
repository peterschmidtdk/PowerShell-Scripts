# Author: Peter Schmidt (peter@msdigest.net) - Blog: www.msdigest.net
# Description:
# This script is to retrieve all e-mail addresses from Exchange and export them to a CSV file.
#
# Last updated: 2018.04.19
# Version: 0.1
# Requirements: Exchange Management Shell

Get-Recipient -ResultSize unlimited | Select Name,Alias,facsimileTelephoneNumber,RecipientType -Expandproperty EmailAddresses | select Alias,Name,facsimileTelephoneNumber,RecipientType,SmtpAddress | where { $_.SmtpAddress -ne $null} | Sort Alias | Export-Csv .\AllSMTPRecipients.osv
