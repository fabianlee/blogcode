# Script to prepopulate the known hosts for PuTTy on Windows
#
# 1. reads in text file where each line is: <name>,<FQDN|IP>
# 2. uses ssh-keyscan from Windows Git client or otherwise to create known_hosts format
# 3. uses kh2reg.py from PuTTy project to convert known_hosts format to .reg
# 4. imports .reg
#
# These executables need to be available on the Windows PATH
# python.exe, ssh-keyscan.exe, reg.exe
#
param($file="puttyhosts.txt")



# ensure list of hosts exists
if( ! (Test-Path $file -PathType Leaf) ) {
  write-host "ERROR: did not find file $file"
  exit(1)
}

#################### MAIN ############################

foreach($line in Get-Content $file) {
  # get putty session name and FQDN from line
  $name,$fqdn = $line.split(',',2)
  write-output "SCANNING for host keys: ${fqdn}"
  
  # use ssh-keyscan from Windows Git install to get known_hosts format
  $argsArray = "-T","5","$fqdn"
  try {
    $output = & ssh-keyscan.exe $argsArray
  }catch {
    write-host "ERROR executing ssh-keyscan, make sure it is in the PATH.  Test from command line using > ssh-keyscan.exe --version"
    exit (3)
  }
  # unfortunately exit code is 0 regardless of success/timeout, but length when timeout is 0
  #write-host "SCAN on ${fqdn} finished with exit code $LASTEXITCODE"
  if($output.length -eq 0) {
    write-host "SKIPPING ${fqdn}, could not connect."
    continue
  }else {
    Set-Content "${name}-known_hosts.txt" $output
  }
  
  # use kh2reg.py3 python3 script to turn known_hosts format into .reg
  $argsArray = "kh2reg.py3","${name}-known_hosts.txt"
  try {
    $output = & python.exe $argsArray
  }catch {
    write-host "ERROR executing Python, make sure it is in the PATH.  Test from command line using > python.exe --version"
    exit (3)
  }
  if($LASTEXITCODE -ne 0) {
    write-host "ERROR running python to convert known_hosts format for ${name} to reg"
    exit(4)
  }
  Set-Content "${name}-known_hosts.reg" $output
  
  
  # use reg.exe to import file into registry
  $argsArray = "IMPORT","${name}-known_hosts.reg"
  & reg.exe $argsArray
  write-host "Registry import on ${name}-known_hosts.reg finished with exit code $LASTEXITCODE"  
  if($LASTEXITCODE -ne 0) {
    write-host "ERROR doing registry import on ${name}.reg"
    exit(5)
  }
  
}





