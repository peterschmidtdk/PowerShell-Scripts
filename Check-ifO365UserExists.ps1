# Full credit to: https://morgantechspace.com/2016/11/check-if-office-365-user-exists-with-powershell.html
# Customized a few things on the file import and export

#Logon to MSOnline
Import-Module MSOnline
$msolCred = Get-Credential
Connect-MsolService –Credential $msolCred

#Query the CSV file
$Result=@() 
Import-Csv '.\FailedUsers.csv' | ForEach-Object {
$user = $_."UserPrincipalName"
$userobj = Get-MsolUser -UserPrincipalName $user -ErrorAction SilentlyContinue
If ($userobj -ne $Null) {
$UserExists = $true
} else {
$UserExists = $false
}
$Result += New-Object PSObject -property @{ 
UserPrincipalName = $user
UserExists = $UserExists }
}
$Result | Select UserPrincipalName,UserExists

#Export to CSV
$Result | Export-CSV ".\FailedStatusReport.csv" -NoTypeInformation -Encoding UTF8
