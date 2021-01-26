# Author: Peter Schmidt
# Blog: www.msdigest.net
# Date: 2019.03.07 - Initial script
# Last update: 2021.01.26 - few tweaks
# Will set Rooms to Limited Details and show Organizer of the meeting in the details
#

#First logon to Exchange Online, if you are not connected, you can uncomment the lines below and use your credentials
#Get EXO Credentials
#$credObject = Get-Credential
#Logon to EXO
#$ExchOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credObject -Authentication Basic -AllowRedirection
#Import-PSSession $ExchOnlineSession

#Logs using transcript
Start-Transcript

#Get all Room mailboxes
$Mailboxes = Get-Mailbox -Resultsize unlimited -RecipientTypeDetails RoomMailbox
$count = 1; $PercentComplete = 0;
foreach ($Mailbox in $Mailboxes) {
    #Progress message
    $ActivityMessage = "Retrieving data for mailbox $($Mailbox.Identity). Please wait..."
    $StatusMessage = ("Processing {0} of {1}: {2}" -f $count, @($Mailboxes).count, $Mailbox.PrimarySmtpAddress.ToString())
    $PercentComplete = ($count / @($Mailboxes).count * 100)
    Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
    $mbxno = $count
    $count++

    $Folder = Get-MailboxFolderStatistics -Identity $($Mailbox.UserPrincipalName) -FolderScope Calendar #-ErrorAction Stop
    foreach ($F in $Folder) {
        if ($F.FolderType -eq 'Calendar') {
            $CalendarPath = $F.FolderPath -Replace '/', '\'         
            Set-MailboxFolderPermission -Identity "$($Mailbox.UserPrincipalName):$CalendarPath" -User Default -AccessRights LimitedDetails -ErrorAction SilentlyContinue
            Write-Host "Setting Default Calendar Permissions to LimitedDetails for Mailbox:" $count" /"($Mailboxes).count" - " $Mailbox.UserPrincipalName
        }
    }
    Set-CalendarProcessing -Identity $($Mailbox.UserPrincipalName) -AddOrganizerToSubject $true -DeleteComments $false -DeleteSubject $false
}

#Stop log file
Stop-Transcript
