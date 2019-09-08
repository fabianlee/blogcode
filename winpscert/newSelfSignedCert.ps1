#requires -version 4
#requires -runasadministrator
param ([string] $cn=$null,[string] $pw=$null)

# check for mandatory parameters
if ( ! ($cn -and $pw)) {
  write-host "Usage: <cn> <password>"
  write-host "Example: myserver.com Certp4ss!"
  exit 1
}

# for old versions of powershell, exit if not using at least PS4
$pver=$PSVersionTable.PSVersion.Major
write-host "powershell major version is " $pver
if ($pver -lt 4) {
  write-host "ERROR, you need at least Powershell 4+ to run this script"
  exit 2
}

write-host "creating new self-signed cert for cn:" $cn
$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $cn

write-host "exporting cert"
$pwd = ConvertTo-SecureString -String $pw -Force -AsPlainText
$pspath = 'cert:\localMachine\my\'+$cert.thumbprint 
Export-PfxCertificate -cert $pspath -FilePath "c:\temp\${cn}.pfx" -Password $pwd
write-host "`n`nexported cert: c:\temp\${cn}.pfx"


