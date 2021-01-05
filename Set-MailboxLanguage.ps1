#Connect to Exchange Online using PowerShell

#Set Language to Danish, can be changed to any language, using the RFC 4646 Language code: https://www.venea.net/web/culture_code
Set-MailboxRegionalConfiguration -Identity example@example.com -LocalizeDefaultFolderName:$true -Language da-DK

Confirm folder has been change for the mailbox using:
Get-MailboxFolderStatistics example@example.com| Select Name,FolderSize,ItemsinFolder
