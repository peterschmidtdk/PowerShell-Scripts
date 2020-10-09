# This script will disable access to all mailboxes with a primary smtp address of the domain: domaintwo.com
# Make sure to connect to Exchange Online powershell before using this script.
# use at your own risk and test wisely
# Author: Peter Schmidt

Start-Transcript -Path .\TranscriptLog.txt -Append
Write-Host "Collecting mailboxes..."
$Users = Get-Mailbox -ResultSize unlimited | where { $_.WindowsEmailAddress -like "*@domaintwo.com"}
Write-Host "Total mailboxes: " $Users.count

foreach ($user in $users)
{ 
    Write-Host "Mailbox no:" $users.IndexOf($user)

    Write-Host "Processing:" $user.DisplayName "," $user.DisplayName $user.alias "," $user.UserPrincipalName "," $user.WindowsEmailAddress -ForegroundColor Yellow
    Set-CASMailbox -Identity $user.UserPrincipalName -ActiveSyncEnabled $false -OWAEnabled $false -OWAforDevicesEnabled $false -PopEnabled $false -ImapEnabled $false -MAPIEnabled $false -UniversalOutlookEnabled $false -OutlookMobileEnabled $false -MacOutlookEnabled $false -EwsEnabled $false
    Write-Host "Mailbox settings done:" $user.DisplayName "," $user.UserPrincipalName "," $user.WindowsEmailAddress -ForegroundColor Green
    
}
Write-Host "All done..." -ForegroundColor Green
Stop-Transcript
