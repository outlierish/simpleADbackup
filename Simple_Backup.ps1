# Create the backup of AD & land it on D Drive of local

wbadmin start backup -backuptarget:D: -allcritical -systemstate -vssfull -quiet

# Zip the Backup File
write-host "Zipping the backup file"

$source = "D:\WindowsImageBackup"
$destination = "D:\backups\WindowsImageBackup.zip"
 If(Test-path $destination) {Remove-item $destination}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($source, $destination) 

# Copy backup file to remote location (make this refer to a text file so multiple backup locations can be specified)
# make a text file with destination locations
# This should just be a function

write-host "Copying to backup locations"

function copytoremote
{
$server_names = Get-Content "D:\backup_config\backup_dest_servers.txt"
Foreach ($server in $server_names){
    $remote = "\\$server\C$\backup_archive\WindowsImageBackup.zip"
        If(Test-path $remote) {Remove-item $remote}
    Copy-Item "D:\backups\WindowsImageBackup.zip" -Destination "\\$server\C$\backup_archive" -Recurse
}
}
copytoremote

# Calculate second hash in all locations (make this refer to a text file so multiple backup locations can be specified)
# Compare Hash 1 to Hash 2 (&etc if multiple locations are specified)

Write-Host "Comparing hashes to verify successful copy"

$hashprime = Get-FileHash D:\backups\WindowsImageBackup.zip -Algorithm MD5
$server_names = Get-Content "D:\backup_config\backup_dest_servers.txt"
Foreach ($server in $server_names){
        $hashdest1 = Get-FileHash \\$server\c$\backup_archive\WindowsImageBackup.zip -Algorithm MD5
# hash check loop
        $Stoploop = $false
        [int]$Retrycount = "0"
        do {
            try {
# What to do if Hash 2 (or later) compares True
# "If the hashes matched Hash file should be created in the target location
# and be named as the original file but with additional “.hash” extension"
		        If (($hashprime).Hash -eq ($hashdest1).Hash){
                    Write-Host $server " copied successfully"
                    $hashfile = "\\$server\c$\backup_archive\WindowsImageBackup.hash"
                    If(Test-path $hashfile) {Remove-item $hashfile}
                    New-Item \\$server\c$\backup_archive\WindowsImageBackup.hash -type file -force -value $hashdest1
                     }
		        $Stoploop = $true
		        }
	        catch {
		        if ($Retrycount -gt 3){
			        Write-Host "Could not copy files after 3 retries."
			        $Stoploop = $true
		        }
		        else {
# What to do if Hash 2 (or later) compares False
# Copy should have a retry mechanism (number of retries should be based on configuration)
			        Write-Host "backup to " $server " failed, retrying..."
			        copytoremote
			        $Retrycount = $Retrycount + 1
		        }
	        }
        }
        While ($Stoploop -eq $false)
}