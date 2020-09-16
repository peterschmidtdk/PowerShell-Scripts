#MSOnline
Write-Host "Installing MSonline..."
Install-Module -Name MSOnline -Force

#Azure AD
Write-Host "Installing AzureAD and Azure Graph modules..."
Install-Module -Name AzureAD -Force

#Exchange
Write-Host "Installing Exchange Online modules..."
Install-Module -Name ExchangeOnlineManagement -Force

#SharePoint
Write-Host "Installing SharePoint Online modules..."
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force
#Update-Module -Name Microsoft.Online.SharePoint.PowerShell  -Force

#Teams
Write-Host "Installing Teams modules..."
Install-Module -Name MicrosoftTeams -Force
