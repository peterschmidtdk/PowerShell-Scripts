#This small script removes users from a CSV list, listed with UserPrincipalName from the Azure AD Group specified, find the ObjectID for the Group

$GroupObject = "40xxx461-fxxb-4xx8-a6x2-0xxxxxxxx"

Import-Csv .\UserList.csv | ForEach-Object {
    $ObjectId = (Get-AzureADUser -ObjectId $_.Userprincipalname).ObjectId
    If ($ObjectId) {
        Remove-AzureADGroupMember -ObjectId $GroupObject -MemberId $ObjectId
    }
}
