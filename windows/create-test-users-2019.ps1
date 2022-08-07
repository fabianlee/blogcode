param([String]$thepass="ThisIsMyP4ss!")

# https://technig.com/create-user-account-using-powershell/
# https://www.faqforge.com/powershell/create-ad-user-in-specific-ou/
# https://devblogs.microsoft.com/scripting/powertip-create-an-active-directory-group-with-powershell/
# https://www.wintips.org/fix-the-sign-in-method-you-are-trying-to-use-is-not-allowed/

Import-Module activedirectory

# create groups: engineers, managers
New-ADGroup -Name engineers -GroupScope global
New-ADGroup -Name managers -GroupScope global


# create users
$securePass = ConvertTo-SecureString -string $thepass -asplaintext -force

# myadmin - extra admin account
New-ADUser -Type User -Name "myadmin" -SamAccountName myadmin -UserPrincipalName myadmin@test.local -AccountPassword $securePass -Enabled $true -ChangePasswordAtLogon $false
Add-ADGroupMember -Identity "Administrators" -Members myadmin

# jdoe - test account that can login directly at console, but not over RDP
New-ADUser -Type User -Name "jdoe" -GivenName John -Surname Doe -SamAccountName jdoe -UserPrincipalName jdoe@test.local -AccountPassword $securePass -Enabled $true -ChangePasswordAtLogon $false -OtherAttributes @{'title'="engineer";'mail'="jdoe@test.com"}
Add-ADGroupMember -Identity "Remote Desktop Users" -Members jdoe
Add-ADGroupMember -Identity "Backup Operators" -Members jdoe

# adfs1 - service account for ADFS
New-ADUser -Type User -Name "adfs1" -SamAccountName adfs1 -UserPrincipalName adfs1@test.local -AccountPassword $securePass -Enabled $true -ChangePasswordAtLogon $false

# engineer1 - test engineer
$name="engineer1"
New-ADUser -Type User -Name $name -SamAccountName $name -UserPrincipalName "$name@test.local" -AccountPassword $securePass -Enabled $true -ChangePasswordAtLogon $false
Add-ADGroupMember -Identity "engineers" -Members $name
# engineer2
$name="engineer2"
New-ADUser -Type User -Name $name -SamAccountName $name -UserPrincipalName "$name@test.local" -AccountPassword $securePass -Enabled $true -ChangePasswordAtLogon $false
Add-ADGroupMember -Identity "engineers" -Members $name

# manager1 - test manager
$name="manager1"
New-ADUser -Type User -Name $name -SamAccountName $name -UserPrincipalName "$name@test.local" -AccountPassword $securePass -Enabled $true -ChangePasswordAtLogon $false
Add-ADGroupMember -Identity "managers" -Members $name

