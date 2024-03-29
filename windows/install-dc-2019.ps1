#
# Windows PowerShell script for AD DS Deployment
#
# https://social.technet.microsoft.com/wiki/contents/articles/52765.windows-server-2019-step-by-step-setup-active-directory-environment-using-powershell.aspx
# https://petri.com/how-to-install-active-directory-in-windows-server-2019-using-powershell/
# https://docs.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest?view=windowsserver2022-ps

write-host 'About to add the AD-Domain-Services feature...'
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
start-sleep -seconds 3

write-host 'About to add the DNS feature...'
Install-WindowsFeature -Name DNS -IncludeManagementTools
start-sleep -seconds 3

Import-Module ADDSDeployment

$domainbios = 'FABIAN'
$domain = 'FABIAN.LEE'
$dmode = '7' # win2019
$safepass = 'ThisIsMyP4ss!' # same as example unattend.xml
$safepassSecure = ConvertTo-SecureString -string $safepass -asplaintext -force

write-host "About to create the Windows Domain controller for $domain..."
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath 'C:\Windows\NTDS' `
-DomainMode $dmode `
-DomainName $domain `
-DomainNetbiosName $domainbios `
-ForestMode $dmode `
-InstallDns:$true `
-LogPath 'C:\Windows\NTDS' `
-NoRebootOnCompletion:$false `
-SysvolPath 'C:\Windows\SYSVOL' `
-SafeModeAdministratorPassword $safepassSecure `
-Force:$true

