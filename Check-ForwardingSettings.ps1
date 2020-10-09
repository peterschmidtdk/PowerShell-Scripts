# This script will export the forwarding settings of all mailboxes from the CSV file
# The CSV file should include only the email of the users, one per line and no headers, eg. peter@domain.com
# All info is saved to the file: MailboxForwarding-status.csv
# Use a own risk
# Author: Peter Schmidt

Start-Transcript
#Import list of mailboxes
$mailboxes = Import-csv .\All-MBXUsers.csv -Delimiter ";" -Header "UserPrincipalName" -Encoding UTF8

#Loop through mailboxes
foreach ($mailbox in $mailboxes)
{
    Write-Host "Target: " $mailbox.UserPrincipalName 
    Get-Mailbox -ResultSize unlimited -Identity $mailbox.UserPrincipalName | Select Name,UserPrincipalName,DeliverToMailboxAndForward,ForwardingSmtpAddress,ForwardingAddress | Export-csv .\MailboxForwarding-status.csv -Append -Encoding Unicode
}
