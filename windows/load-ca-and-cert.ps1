#
# Loads CA and then cert from filesystem
# Adds root and cert to Personal Certificates of local computer
#
# This script is meant to be run on Windows 2016 and higher
#
# For Secure LDAP on Win2012R2 and Win2016:
#   on local computer:
#     Personal: needs certificate
#     Trusted Root Certificates: need ca cert
#   root cert needs to be added for service account 'Active Dir Domain Services'
#     NTDS\Trusted Root Certification Authorities needs root cert
#
#  Windows 2012R2 is pickier about certificate and needs:
#    'Server Authentication' key extension
#    SAN name matching uppercase DOMAIN realm
# 

param(
  [string]$rootCN,
  [string]$certCN,
  [string]$pfxPassword="securepw"
)

if ( ! ( $rootCN -or $certCN ) ) {
  write-host "ERROR need to supply root and cert filenames"
  write-host "Example: myCA 'flee-dc1.fabian.lee'"
  exit(1)
}

$baseDir = 'c:\certs'
# ignore error if already exists
New-Item -Path $baseDir -ItemType Directory -Force | out-null

# CA certificate into trusted roots (computer level)
$safeName=([char[]]$rootCN | where { [IO.Path]::GetinvalidFileNameChars() -notcontains $_ }) -join ''
Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath "$baseDir\$safeName.crt"

# leaf certificate into personal (computer level)
# using PFX with key and passphrase
$primaryDnsName = $certCN.Split(',')[0]
$password = ConvertTo-SecureString -string "$pfxPassword" -AsPlainText -force
$cred = New-Object System.Management.Automation.PSCredential("foo",$password)
$safeName=([char[]]$primaryDnsName | where { [IO.Path]::GetinvalidFileNameChars() -notcontains $_ }) -join ''
Import-PfxCertificate -CertStoreLocation 'Cert:\LocalMachine\My' -FilePath "$baseDir\$safeName.pfx" -Password $cred.Password -Exportable

# this would have imported the cert without key, BUT we need the key from the pfx
#Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\My' -FilePath "$baseDir\$safeName.crt"
