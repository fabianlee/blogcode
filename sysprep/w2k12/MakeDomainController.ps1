param($netbiosName="contoso",$domainFQDN="contoso.com",$domainMode="Win2012R2")

Import-Module servermanager
Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools

$cred = ConvertTo-SecureString "ThisIsMyP4ss!" -AsPlainText -Force

Import-Module ADDSDeployment
Install-ADDSForest -CreateDNSDelegation:$false -DatabasePath "c:\windows\NTDS" -DomainMode $domainMode -DomainName $domainFQDN -DomainNetbiosName $netbiosName -ForestMode $domainMode -InstallDNS:$true -LogPath c:\Windows\NTDSLogs -NoRebootOnCompletion:$false -SysvolPath c:\Windows\SYSVOL -Force:$true -SafeModeAdministratorPassword $cred

