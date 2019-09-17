# Peter Schmidt
# Depends on the BurntToast Module

Function Get-LastReboot {
    Param ( 
    [string] $ComputerName = $env:COMPUTERNAME 
    )

    $os = Get-WmiObject win32_operatingsystem -ComputerName $ComputerName -ErrorAction SilentlyContinue
    if ($os.LastBootUpTime) {
        return ($os.ConvertToDateTime($os.LastBootUpTime))
        #return ((Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime))
    } else {
        Write-Warning "Unable to connect to $computername"
    }
}
    
$ahours = $([datetime]::Now - (Get-LastReboot)).totalhours
$hours = [math]::Round($ahours,2)

Import-Module BurntToast
New-BurntToastNotification -SnoozeAndDismiss -Text "PC'en has been online for : $hours !"
