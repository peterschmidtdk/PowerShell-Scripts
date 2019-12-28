#Set delegate calendar permissions on a mailbox, can be used for Exchange and in Exchange Online
Set-MailboxFolderPermission JohnDoe:\calendar -User PeterSchmidt -AccessRights Editor -SharingPermissionFlags Delegate
