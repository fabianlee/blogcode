param($first,$second)

write-host "hello world with params $first and $second" -foregroundcolor yellow
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
write-host "script root at $scriptDir"

set-content $scriptDir\test.log "hello world with params $first and $second" 
