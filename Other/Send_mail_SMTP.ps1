#Setup Credentials
$UserName = "user@domain.com"
$Password = "Password"
$SecurePassword = ConvertTo-SecureString -string $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -argumentlist $UserName, $SecurePassword
 

## Define the Send-MailMessage parameters
$mailParams = @{
    SmtpServer                 = 'smtp.server.com'
    Port                       = '587' #587, 465 or 25 .Check your security needs
    UseSSL                     = $true # or not if using non-TLS
    Credential                 = $credential
    From                       = 'user@domain.com'
    To                         = 'otheruser@otherdomain.com'
    Subject                    = "SMTP test"
    Body                       = 'This is a test email using SMTP Client Submission'
    DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
}

## Send the message
Send-MailMessage @mailParams