# ----------------------------------------------------------------------------- 
# Author: Peter Schmidt
# Blog: http://www.msdigest.net 
# Twitter: @petsch
# Date: 2019.02.20 
# Enables modern authentication for Skype for Business Online
# Make sure to install the Skype for Business Online, Windows PowerShell Module:
# https://www.microsoft.com/en-us/download/details.aspx?id=39366
# ----------------------------------------------------------------------------- 

#Logon using your Global Admin
$sfboSession = New-CsOnlineSession -UserName user@domain.com
Import-PSSession $sfboSession

# Verify the current settings (optional), expected Result: ClientAdalAuthOverride : Disallowed
Get-CsOAuthConfiguration

# Enable modern authentication for Skype for Business Online
Set-CsOAuthConfiguration -ClientAdalAuthOverride Allowed

# Verify that the change was successful by running the following, expected Result: ClientAdalAuthOverride : Allowed
Get-CsOAuthConfiguration
