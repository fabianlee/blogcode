#
# Creates CA and then cert based on CA with optional SAN
# Adds root and cert to Personal Certificates of local computer
#
# This script is meant to be run on Windows 2016 and higher
# I would need to use certutil to make this run on Windows 2012 
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
  write-host "ERROR need to supply root and cert CN for certificate"
  write-host "Example: myCA 'flee-dc1.fabian.lee,flee-dc1.FABIAN.LEE,flee-adfs1.fabian.lee'"
  exit(1)
}

$baseDir = 'c:\certs'
# ignore error if already exists
New-Item -Path $baseDir -ItemType Directory -Force | out-null

# https://infiniteloop.io/powershell-self-signed-certificate-via-self-signed-root-ca/
# https://invoke-automation.blog/2018/09/16/creating-a-local-ssl-certificate-hierarchy
$params = @{
  DnsName = $rootCN
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-Date).AddYears(5)
  CertStoreLocation = 'Cert:\LocalMachine\My'
  KeyUsage = 'CertSign','CRLSign' #fixes invalid cert error
}
$rootCA = Get-ChildItem -Path 'Cert:\LocalMachine\Root' | Where-Object { $_.Subject -eq "CN=$rootCN"} | Select -First 1
$safeName=([char[]]$rootCN | where { [IO.Path]::GetinvalidFileNameChars() -notcontains $_ }) -join ''

if ($rootCA) {
  write-host "root CA already created 'CN=$rootCN' thumbprint $($rootCA.Thumbprint)"
  Export-Certificate    -Cert $rootCA -FilePath "$baseDir\$safeName.crt"
  Export-PfxCertificate -Cert $rootCA -FilePath "$baseDir\$safeName.pfx" -Password (ConvertTo-SecureString -AsPlainText "$pfxPassword" -Force)
}else {
  $rootCA = New-SelfSignedCertificate @params

  Export-Certificate    -Cert $rootCA -FilePath "$baseDir\$safeName.crt"
  Export-PfxCertificate -Cert $rootCA -FilePath "$baseDir\$safeName.pfx" -Password (ConvertTo-SecureString -AsPlainText "$pfxPassword" -Force)

  # cannot create cert in Root, so have to move it post-creation
  Move-Item (Join-Path Cert:\LocalMachine\My $rootCA.Thumbprint) -Destination Cert:\LocalMachine\Root

  # in order to create self-signed leaf certs, need CA cert in 'My'
  Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\My' -FilePath "$baseDir\$safeName.crt"
}

# ServerAuth key extension not necessary in Win2016, but it is with 2012
$primaryDnsName = $certCN.Split(',')[0]
$params = @{
  DnsName = $certCN.Split(',')
  Signer = $rootCA
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-date).AddYears(2)
  CertStoreLocation = 'Cert:\LocalMachine\My'
  TextExtension = @("2.5.29.37={text}1.3.6.1.5.5.7.3.1,1.3.6.1.5.5.7.3.2")
}
$theCert = Get-ChildItem -Path 'Cert:\LocalMachine\My' | Where-Object { $_.Subject -eq "CN=$primaryDnsName" } | Select -First 1
if ($theCert) {
  write-host "certificate $primaryDnsName already created thumbprint $($theCert.Thumbprint)"
}else {
  $theCert = New-SelfSignedCertificate @params
}

# write pfx/pem cert to file
# https://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames
$safeName=([char[]]$primaryDnsName | where { [IO.Path]::GetinvalidFileNameChars() -notcontains $_ }) -join ''
#write-host "safeName is $safeName"
Export-Certificate -Cert $theCert -FilePath "$baseDir\$safeName.crt"
Export-PfxCertificate -Cert $theCert -FilePath "$baseDir\$safeName.pfx" -Password (ConvertTo-SecureString -AsPlainText "$pfxPassword" -Force)


#
# Do on linux host to convert format
#
# convert root ca certificate to pem format
#echo openssl x509 -inform DER -in rootCA.crt -out rootCA.pem
# export server private key to pem format
#openssl pkcs12 -in <cert>.pfx -nocerts -nodes -out <cert>.pem
# convert server certificate to pem format
#openssl x509 -inform DER -in <cert>.crt-out <cert>.pem
