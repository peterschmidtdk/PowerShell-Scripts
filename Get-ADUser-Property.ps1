# Author: Peter Schmidt (peter@msdigest.net) - Blog: www.msdigest.net
# Description:
# This script retrives the facsimileTelephoneNumber based on the filter that the user is Enabled (info from Description) and that there is some information in the facsimileTelephoneNumber attribute. 
# Last updated: 2018.04.19
# Version: 0.1
# Requirements: Active Directory module 
#
import-module ActiveDirectory
Get-ADUser -filter "(description -like 'Enabled*') -And (facsimileTelephoneNumber -like '*')" -Properties * | select name,samAccountName,facsimileTelephoneNumber
