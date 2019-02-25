#Run this command to Export IP Range from the Receive Connector:
Get-ReceiveConnector "servername\nameofconnector" | select -ExpandProperty remoteipranges | export-csv c:\temp\filename.csv
