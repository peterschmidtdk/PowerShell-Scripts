#Small script to wait for a certain time and the execute the rest of the script, eg. restart a computer.
do {
Start-Sleep 1
}
until ((get-date) -ge (get-date "6:00 PM"))
Restart-Computer
