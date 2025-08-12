##
## Automate mail via Graph
##

# credentials and connection
$tenantid = 'XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$clientid = 'YYYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY'
$clientsecret = 'ZZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ'
$securesecret = ConvertTo-SecureString `
    -string $clientsecret `
    -AsPlainText `
    -Force
# mailbox and user
$sender_maibox = 'shared-mailbox@domain.com'
$sender_user = "service-account@domain.com"
 
# receiver
$mailrecipient = "another-user@domain.com"
 
$token = get-msaltoken -clientid $clientid -tenantid $tenantid -clientsecret $securesecret -scopes "https://graph.microsoft.com/.default"
# mail body
 $body = @{
  message = @{
    subject = "Welcome mail"
    body = @{
      contentType = "Text"
      content = @"
Wellcome $mailrecipient
Your account is created.
-User: $mailrecipient
-Password: temporaryPassword
Please enter to the application in the following URL: https://www.myapps.microsoft.com
Consider to change your password during the first login.
Regards.
"@
    }
    toRecipients = @(@{ emailAddress = @{ address = "$mailrecipient" } })
  }
  saveToSentItems = "true"
}
Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$sender_user/sendMail" `
  -Method POST -Headers @{ Authorization = "Bearer $($token.AccessToken)" } `
  -Body ($body | ConvertTo-Json -Depth 10) -ContentType "application/json"
 
 