# Peter Schmidt
# Script to list mailbox folder permissions, who has access on what folders etc.
#Set a specific mailbox to query for mailbox folder permissions and who has access on folder level
$mbx = "steve"

#Runs through the permissions and folders
$permissions = @()
$Folders = Get-MailboxFolderStatistics $mbx | % {$_.folderpath} | % {$_.replace(“/”,”\”)}
$list = ForEach ($F in $Folders)
   {
    $FolderKey = $mbx + ":" + $F
    $Permissions += Get-MailboxFolderPermission -identity $FolderKey -ErrorAction SilentlyContinue | Where-Object {$_.User -notlike “Default” -and $_.User -notlike “Anonymous” -and $_.AccessRights -notlike “None”}
   }
$permissions
