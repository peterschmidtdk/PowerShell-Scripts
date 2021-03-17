# This list all members of a specific Distribution List
# Change the DL name (DLName), to the DL, which you want to list members from e.g. dist1@domain.com
# It will display the: DisplayName, PrimarySmtpAddress for each members

$Members = (Get-DistributionGroupMember DLName).Identity
Foreach ($member in $members) { Get-Mailbox $Member | select DisplayName,PrimarySMTPAddress}
