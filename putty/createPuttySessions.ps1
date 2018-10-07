# Script to prepopulate the saved sessions for PuTTy on Windows
#
# 1. reads in text file where each line is: <name>,<FQDN|IP>
# 2. uses template registry file to create registry file specific to target host
# 3. imports .reg
#
param($file="puttyhosts.txt",$templateFile="template.reg")

# ensure list of hosts exists
if( ! (Test-Path $file -PathType Leaf) ) {
  write-host "ERROR: did not find file $file"
  exit(1)
}
# ensure template registry file exists
if( ! (Test-Path $templateFile -PathType Leaf) ) {
  write-host "ERROR: did not find template file $templateFile"
  exit(1)
}

# take template file, merge with properties map
function evalTemplate($file,$map) {
  $s = Get-Content $file
  foreach($key in $map.keys) {
    $s = $s -replace "<<${key}>>", "$($map[$key])"
  }
  return $s
}

# not all characters are valid, do substitution
function fixupName($name) {
  return $name -replace " ","%20"
}

#################### MAIN ############################

foreach($line in Get-Content $file) {
  # get putty session name and FQDN from line
  $name,$fqdn = $line.split(',',2)
  write-output "CREATING PuTTy session name: ${name} FQDN: ${fqdn}"
  
  # merge with template registry entry to produce one specific for this host
  $props = @{
    sessionName=fixupName $name
    actualHostName="$fqdn"
  }
  $output = evalTemplate $templateFile $props
  Set-Content "${name}.reg" $output
  
  # use reg.exe to import file into registry
  $argsArray = "IMPORT","${name}.reg"
  & reg.exe $argsArray
  write-host "Registry import on ${name}.reg finished with exit code $LASTEXITCODE"
  if($LASTEXITCODE -ne 0) {
    write-host "ERROR doing registry import on ${name}.reg"
    exit(2)
  }
}





