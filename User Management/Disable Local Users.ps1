get-localuser | ? {($_.name -ne 'Administrator')} | disable-localuser -Confirm:$false
