#
# Creates suites of AD test users
# Run on the AD Domain Controller
#
# https://technig.com/create-user-account-using-powershell/
# https://www.faqforge.com/powershell/create-ad-user-in-specific-ou/
# https://devblogs.microsoft.com/scripting/powertip-create-an-active-directory-group-with-powershell/
# https://www.wintips.org/fix-the-sign-in-method-you-are-trying-to-use-is-not-allowed/

param([String]$password="ThisIsMyP4ss!")

Import-Module activedirectory

# takes user account name, suffixes with 123! and makes into secure password
function make-secure-pass {
  param([String]$plainPass)
  $securePass = ConvertTo-SecureString -string "$plainPass" -asplaintext -force
  write-output $securePass
}

# create AD user
function create-ad-user {
  param([String]$name,[String]$edomain,[String]$password)
  New-ADUser -Type User -Name $name -SamAccountName $name -EmailAddress "$name@$edomain" -UserPrincipalName "$name@$edomain" -AccountPassword (make-secure-pass "$password") -Enabled $true -ChangePasswordAtLogon $false
}


# create groups: engineers, managers
New-ADGroup -Name engineers -GroupScope global
New-ADGroup -Name managers -GroupScope global

# email domain
$edomain="fabian.lee"

# jdoe - test account that can login directly at console, but not over RDP
# has additional attributes that can be seen in ADSI
$name="jdoe"
New-ADUser -Type User -Name $name -GivenName John -Surname Doe -SamAccountName $name -EmailAddress "$name@$edomain" -UserPrincipalName "$name@$edomain" -AccountPassword (make-secure-pass $password) -Enabled $true -ChangePasswordAtLogon $false -OtherAttributes @{'title'="mytitle";'telephoneNumber'="(555)123-4567"}
Add-ADGroupMember -Identity "Remote Desktop Users" -Members $name
Add-ADGroupMember -Identity "Backup Operators" -Members $name

# myadmin - extra admin account
$name="myadmin"
create-ad-user $name $edomain "$password"
Add-ADGroupMember -Identity "Administrators" -Members $name

# adfs1 - service account for ADFS
$name="adfs1"
create-ad-user $name $edomain "$password"

# ldap1 - service account for ldap
$name="ldap1"
create-ad-user $name $edomain "$password"

# engineer1 - test engineer
$name="engineer1"
create-ad-user $name $edomain "$password"
Add-ADGroupMember -Identity "engineers" -Members $name
# engineer2 - another test engineer
$name="engineer2"
create-ad-user $name $edomain "$password"
Add-ADGroupMember -Identity "engineers" -Members $name

# manager1 - test manager
$name="manager1"
create-ad-user $name $edomain "$password"
Add-ADGroupMember -Identity "managers" -Members $name

