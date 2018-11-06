$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

# Get all AD Users that are people
$myUsers = Get-ADUser -Filter * -Properties * | `
     Where-Object DistinguishedName -like '*MyOU' | `
     Where-Object UserPrincipalName -like '*@myDomain.local'
    <# Sort CanonicalName, UserPrincipalName
     sort name | select Name, UserPrincipalName, Mail #>

# Flip UPN
foreach ($myUser in $myUsers) {
    # Get the variables I need
    $myOldUPN = $myUser.UserPrincipalName
    $myName = $myUser.UserPrincipalName.Split('@')[0]
    [string]$myUPN = $myName + '@chaplaincyhealthcare.org'
    # Build the email ProxyAddresses
    $myProxies = @("SMTP:$myUPN","smtp:$myOldUPN")
    # Switch the UPN
    $myUser | Set-ADUser -UserPrincipalName $myUPN -EmailAddress $myUPN
    # Change email proxy addresses
    $myuser | Set-ADUser -Replace @{ProxyAddresses = $myProxies}
    # Change the primary email address in O365
    Set-Mailbox $myOldUPN -WindowsEmailAddress $myUPN -Force
    # Just to be sure, change the O365 UPN
    Set-MsolUserPrincipalName -UserPrincipalName $myOldUPN -NewUserPrincipalName $myUPN
}