param(
  [string]$certCN
)

if ( ! $certCN ) {
  write-host "ERROR need to supply CN for certificate"
  exit(1)
}

$baseDir = 'c:\certs'
New-Item -Path $baseDir -ItemType Directory

# https://infiniteloop.io/powershell-self-signed-certificate-via-self-signed-root-ca/
$params = @{
  DnsName = "myCA"
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-Date).AddYears(5)
  CertStoreLocation = 'Cert:\LocalMachine\My'
  KeyUsage = 'CertSign','CRLSign' #fixes invalid cert error
}
$rootCA = New-SelfSignedCertificate @params

$params = @{
  DnsName = $certCN
  Signer = $rootCA
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-date).AddYears(2)
  CertStoreLocation = 'Cert:\LocalMachine\My'
}
$theCert = New-SelfSignedCertificate @params

# Extra step needed since self-signed cannot be directly shipped to trusted root CA store
# if you want to silence the cert warnings on other systems you'll need to import the rootCA.crt on them too
Export-Certificate -Cert $rootCA -FilePath "$baseDir\rootCA.crt"
Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath "$baseDir\rootCA.crt"

# https://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames
$safeName=([char[]]$certCN | where { [IO.Path]::GetinvalidFileNameChars() -notcontains $_ }) -join ''
Export-PfxCertificate -Cert $theCert -FilePath '$baseDir\$safeName.pfx' -Password (ConvertTo-SecureString -AsPlainText 'securepw' -Force)
