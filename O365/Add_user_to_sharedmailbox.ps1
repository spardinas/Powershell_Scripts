# Define the shared mailbox and the user
$sharedMailbox = "shared@domain.com"
$user = "generic_user@domain.com"

# Add the user to the shared mailbox with Full Access permission
Add-MailboxPermission -Identity $sharedMailbox -User $user -AccessRights FullAccess -InheritanceType All

# Optionally, add Send As permission
Add-RecipientPermission -Identity $sharedMailbox -Trustee $user -AccessRights SendAs

