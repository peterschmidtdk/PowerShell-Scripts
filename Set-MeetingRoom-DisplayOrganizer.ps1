# Author: Peter Schmidt
# Blog: www.msdigest.net
# Date: 2019.03.07 - Initial script
# Will set Rooms to Limited Details and show Organizer of the meeting in the details
#

#First logon to Exchange Online, if you are not connected, you can uncomment the lines below and use your credentials
#Get EXO Credentials
#$credObject = Get-Credential
#Logon to EXO
#$ExchOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credObject -Authentication Basic -AllowRedirection
#Import-PSSession $ExchOnlineSession

#Get all Rooms
$rooms = Get-Mailbox -RecipientTypeDetails RoomMailbox

#Set the AccessRights to Limited Details
$rooms | %{Set-MailboxFolderPermission $_":\Calendar" -User Default -AccessRights LimitedDetails}
 
#Set that Organizer are displayed the meetings details
$rooms | %{Set-CalendarProcessing $_ -AddOrganizerToSubject $true -DeleteComments $false -DeleteSubject $false}
