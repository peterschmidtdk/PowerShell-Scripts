#This small script removes users from a CSV list, listed with UserPrincipalName from the Azure AD Group specified, find the ObjectID for the Group
#Connect with PowerShell to Azure AD

#Change the GroupObject with the ObjectID of the group that users should be added to

Import-Csv .\UserList.csv | ForEach-Object {
    $ObjectId = (Get-AzureADUser -ObjectId $_.Userprincipalname).ObjectId
    If ($ObjectId) {
        Remove-AzureADGroupMember -ObjectId $GroupObject -MemberId $ObjectId
    }
}
