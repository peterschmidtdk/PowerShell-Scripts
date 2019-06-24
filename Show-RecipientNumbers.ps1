# Author: Peter Schmidt (peter@msdigest.net)
# Blog: www.msdigest.net
# Version: 1.0 - June 2019
# Description: Very simpel listing of the different recipients on the Exchange Server
# Notes: For on-premise Exchange Server

$DynGroups = (Get-Recipient -ResultSize unlimited -RecipientType DynamicDistributionGroup)
Write-Host "Dynamic Groups" ($DynGroups).count

$Contacts = (Get-Recipient -ResultSize unlimited -RecipientType MailContact)
Write-Host "MailContacts" ($Contacts).count

$MailUser = (Get-Recipient -ResultSize unlimited -RecipientType MailUser)
Write-Host "MailUsers" ($MailUser).count

$MailNonUniversalGroup = (Get-Recipient -ResultSize unlimited -RecipientType MailNonUniversalGroup)
Write-Host "MailNonUniversalGroups" ($MailNonUniversalGroup).count

$MailUniversalDistributionGroup = (Get-Recipient -ResultSize unlimited -RecipientType MailUniversalDistributionGroup)
Write-Host "MailUniversalDistributionGroups" ($MailUniversalDistributionGroup).count

$MailUniversalSecurityGroup = (Get-Recipient -ResultSize unlimited -RecipientType MailUniversalSecurityGroup)
Write-Host "MailUniversalSecurityGroups" ($MailUniversalSecurityGroup).count

$PublicFolder = (Get-Recipient -ResultSize unlimited -RecipientType PublicFolder)
Write-Host "Public Folders" ($PublicFolder).count

$UserMailbox = (Get-Recipient -ResultSize unlimited -RecipientType UserMailbox)
Write-Host "UserMailboxes" ($UserMailbox).count
