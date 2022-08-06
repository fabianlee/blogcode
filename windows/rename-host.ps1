$name = "win2k19-dc1"
$computerName = Get-WmiObject Win32_ComputerSystem
$computername.Rename($name)
