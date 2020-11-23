param(
  [string]$certCN
)

if ( ! $certCN ) {
  write-host "ERROR need to supply CN for certificate"
  exit(1)
}

$baseDir = 'c:\certs'
# ignore error if already exists
New-Item -Path $baseDir -ItemType Directory -Force | out-null

# https://infiniteloop.io/powershell-self-signed-certificate-via-self-signed-root-ca/
# https://invoke-automation.blog/2018/09/16/creating-a-local-ssl-certificate-hierarchy
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
$rootCA = Get-ChildItem -Path 'Cert:\LocalMachine\My' | Where-Object { $_.Subject -eq 'CN=myCA'} | Select -First 1
if ($rootCA) {
  write-host "root CA already created 'CN=myCA' thumbprint $($rootCA.Thumbprint)"
}else {
  $rootCA = New-SelfSignedCertificate @params

  # Extra step needed since self-signed cannot be directly shipped to trusted root CA store
  # if you want to silence the cert warnings on other systems you'll need to import the rootCA.crt on them too
  Export-Certificate -Cert $rootCA -FilePath "$baseDir\rootCA.crt"
  Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath "$baseDir\rootCA.crt"
}


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
$theCert = Get-ChildItem -Path 'Cert:\LocalMachine\My' | Where-Object { $_.Subject -eq "CN=$certCN" } | Select -First 1
if ($theCert) {
  write-host "certificate $certCN already created thumbprint $($theCert.Thumbprint)"
}else {
  $theCert = New-SelfSignedCertificate @params

  # https://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames
  $safeName=([char[]]$certCN | where { [IO.Path]::GetinvalidFileNameChars() -notcontains $_ }) -join ''
  #write-host "safeName is $safeName"
  Export-PfxCertificate -Cert $theCert -FilePath "$baseDir\$safeName.pfx" -Password (ConvertTo-SecureString -AsPlainText 'securepw' -Force)
}



