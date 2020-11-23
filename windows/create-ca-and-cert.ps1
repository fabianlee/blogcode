#Requires -Version 5.1
param(
  [string]$rootCN,
  [string]$certCN,
  [string]$pfxPassword="securepw"
)

if ( ! ( $certCN -or $certCN ) ) {
  write-host "ERROR need to supply root and cert CN for certificate"
  write-host "Example: myCA flee-dc1.fabian.lee 'flee-dc1.fabian.lee,flee-dc1.FABIAN.LEE,flee-dc1.home.lab'"
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
$rootCA = Get-ChildItem -Path 'Cert:\LocalMachine\My' | Where-Object { $_.Subject -eq "CN=$rootCN"} | Select -First 1
if ($rootCA) {
  write-host "root CA already created 'CN=$rootCN' thumbprint $($rootCA.Thumbprint)"
}else {
  Try {
    $rootCA = New-SelfSignedCertificate @params
  }Catch {
    Write-Warning "ERROR creating CA cert, you are probably on an older Windows2012R2 host"
    Write-Warning (Get-WmiObject -class Win32_OperatingSystem).Caption
    #Write-Warning "Windows Mmgmt Framework 5.1 download: https://www.microsoft.com/en-us/download/details.aspx?id=54616"
    $PSVersionTable
    exit 3
  }

  # Extra step needed since self-signed cannot be directly shipped to trusted root CA store
  # if you want to silence the cert warnings on other systems you'll need to import the rootCA.crt on them too
  $safeName=([char[]]$rootCN | where { [IO.Path]::GetinvalidFileNameChars() -notcontains $_ }) -join ''
  Export-Certificate -Cert $rootCA -FilePath "$baseDir\$safeName.crt"
  Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath "$baseDir\$safeName.crt"
}

# ServerAuth key extension not necessary in Win2016, but it is with 2012

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
$theCert = Get-ChildItem -Path 'Cert:\LocalMachine\My' | Where-Object { $_.Subject -eq "CN=$certCN" } | Select -First 1
if ($theCert) {
  write-host "certificate $certCN already created thumbprint $($theCert.Thumbprint)"
}else {
  $theCert = New-SelfSignedCertificate @params

  # https://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames
  $safeName=([char[]]$certCN.Split(',')[0] | where { [IO.Path]::GetinvalidFileNameChars() -notcontains $_ }) -join ''
  #write-host "safeName is $safeName"
  Export-Certificate -Cert $theCert -FilePath "$baseDir\$safeName.crt"
  Export-PfxCertificate -Cert $theCert -FilePath "$baseDir\$safeName.pfx" -Password (ConvertTo-SecureString -AsPlainText "$pfxPassword" -Force)
}


#
# Do on linux host to convert format
#
# convert root ca certificate to pem format
#echo openssl x509 -inform DER -in rootCA.crt -out rootCA.pem
# export server private key to pem format
#openssl pkcs12 -in <cert>.pfx -nocerts -nodes -out <cert>.pem
# convert server certificate to pem format
#openssl x509 -inform DER -in <cert>.crt -out <cert>.pem
