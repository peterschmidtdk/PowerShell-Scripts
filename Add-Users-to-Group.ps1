#Add users from a CSV file to a Specific Group in AD
#CSV file looks like this:
# Name,Group
# abc,O365_E3_LicensedUser,
#
import-csv .\listofMBXusers.csv | Foreach-Object {add-adgroupmember -Identity $_.group -Members $_.name}
