Send mail via MsGraph.

As microsoft is deprecating the use of SMTP, the next move is going to Graph to send mails for your automation.
I use this one to welcome new users into my appstream2.0 fleets, but it can be used elsewhere.

There is a prerequisite to use it.

-Create an Appregistration in Entra.
    Create a new pair of key value secrets and keep it ( I know, is not good policy to store secrets in code, I promise I'll fix it soon)
    Grant the application the following permissions:
        Mail.send ( Aplication )
        User.read ( Delegated )
        IMAP.AccessAsApp ( Delegated )

 