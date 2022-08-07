param([String]$thepass="ThisIsMyP4ss!")

# https://technig.com/create-user-account-using-powershell/
# https://www.faqforge.com/powershell/create-ad-user-in-specific-ou/

Import-Module activedirectory
$securePass = ConvertTo-SecureString -string $thepass -asplaintext -force

# type=iNetOrgPerson
New-ADUser -Type User -Name "jdoe" -GivenName John -Surname Doe -SamAccountName jdoe -UserPrincipalName jdoe@test.local -AccountPassword $securePass -Enabled $true -ChangePasswordAtLogon $false -OtherAttributes @{'title'="engineer";'mail'="jdoe@test.com"}

Add-ADGroupMember -Identity "Remote Desktop Users" -Members jdoe

# one of the groups that will allow a user to login directly to DC
# https://www.wintips.org/fix-the-sign-in-method-you-are-trying-to-use-is-not-allowed/
Add-ADGroupMember -Identity "Backup Operators" -Members jdoe
