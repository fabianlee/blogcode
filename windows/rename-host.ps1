param([String]$newname = "win2k19-dc1")
$computerName = Get-WmiObject Win32_ComputerSystem
$computername.Rename($newname)

write-output "name changed to $newname, going to reboot in 3 seconds..."
start-sleep -seconds 3

restart-computer
