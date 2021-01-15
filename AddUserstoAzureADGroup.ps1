#This small script adds users from a CSV list, listed with UserPrincipalName from the Azure AD Group specified, find the ObjectID for the Group

#Change the GroupObject with the ObjectID of the group that users should be added to
$GroupObject = "40xxx461-fxxb-4xx8-a6x2-0xxxxxxxx"

Import-Csv .\BoxerUsers.csv | ForEach-Object {
    $ObjectId = (Get-AzureADUser -ObjectId $_.Userprincipalname).ObjectId
    If ($ObjectId) {
        Add-AzureADGroupMember -ObjectId $GroupObject -RefObjectId $ObjectId
    }
}
