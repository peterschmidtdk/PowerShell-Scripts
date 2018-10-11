############################################################################# 
# Author: Peter Schmidt (peter@msdigest.net)
# Date: 2018.10.11 
# Version: 1.0
# Description: Create a DL Group report from Exchange 
############################################################################# 
 
#format Date 
 
$date = get-date -format d 
$date = $date.ToString().Replace(“/”, “-”) 
 
$output = ".\" + "DL-Report-" + $date + ".csv" 
 
$Collection = @() 
$a = Get-DistributionGroup -resultsize unlimited  

$a | foreach-object{ 
if($_.AcceptMessagesOnlyFrom -ne $null) 
{$restriction = "Yes"} 
else 
{$restriction = "NO"} 
$members = Get-DistributionGroupMember $_.identity -resultsize unlimited 
$countmem = $members.count 
 
$memb = “” | select Name, SamaccountName,CountMembers,restricted,PrimarySMTPAddress,Alias
  
$memb.Name = $_.Name 
$memb.SamaccountName = $_.SamaccountName 
$memb.CountMembers = $countmem #Count members in the Grouop
$memb.restricted = $restriction #Is the Group restricted to send to
$memb.PrimarySmtpAddress = $_.PrimarySmtpAddress
$memb.Alias = $_.Alias 

$Collection += $memb 
} 
 
# EXPORT TO A CSV FILE 
$Collection | export-csv $output 
