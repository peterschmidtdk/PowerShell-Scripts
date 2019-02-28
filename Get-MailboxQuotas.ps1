#This command will list the Mailbox Quota on all mailboxes on this specific Exchange Server
Get-Mailbox -Server EXCHANGESERVERNAME -ResultSize unlimited |  Where {$_.UseDatabaseQuotaDefaults -eq $false} | ft DisplayName,IssueWarningQuota,ProhibitSendQuota,@{label="TotalItemSize(MB)";expression={(get-mailboxstatistics $_).TotalItemSize.Value.ToMB()}}
