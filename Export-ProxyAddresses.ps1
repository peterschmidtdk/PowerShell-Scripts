# This script will export all proxy addresses from Exchange from all Mailboxes, that is not a UserMailbox
#
$Mailboxes = get-mailbox -resultsize unlimited | ?{($_.recipienttypedetails -ne "usermailbox") -and ($_.recipienttypedetails -notlike "discovery*")}
$Output = @()

ForEach ($Mailbox in $Mailboxes)
{
    $Addresses = $Mailbox.emailaddresses
    
    $Temp = New-Object PSObject
    $Temp | Add-Member NoteProperty Alias $Mailbox.Alias

    $String = $null

    ForEach($Address in $Addresses)
    {
        If($Address.Prefix -like "*smtp*")
        {
            If ($String)
            {
                $String = $String + "," + $Address.ProxyAddressString
            }
            Else
            {
                $String = $String + $Address.ProxyAddressString 
            }            
        }
    }
    $Temp | Add-Member NoteProperty ProxyAddresses $String
    $Output += $Temp
}
$Output | export-csv OutputWithProxy.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8 
