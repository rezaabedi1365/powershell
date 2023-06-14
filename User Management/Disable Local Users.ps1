#abdi
get-localuser | ? {($_.name -ne 'Administrator')} | disable-localuser -Confirm:$false


#https://learn.microsoft.com/en-us/answers/questions/1040617/remove-disable-local-accounts-except-administrator
Get-LocalUser | Where-Object {$_.Name -ne "Administrator"} | Disable-LocalUser -WhatIf
