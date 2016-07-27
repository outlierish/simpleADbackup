# Simple AD Backup
Simple AD backup system using powershell

Running this application requires at least Powershell 4.

Notes:

1. The application requires that you have created a text file specifying the hostnames or IP addresses of servers on your network that will recieve the backup files. The application expects that the text file is named backup_dest_servers.txt and the path to it is "D:\backup_config\backup_dest_servers.txt" This can be changed in the application directly.

2. The application expects to find a folder on the local server in the D drive called "backups" and a folder on the remote server(s) on the C drive called "backup_archive". 

3. The application deletes and re-creates existing backup files at this time.

4. Right now, the only way to specify how may times to retry the copy to remote servers is in the program directly on line 57. 


--Things I thought might be good to extend it from here--

1. Have the application make the directories it needs
2. Have the application append a date or some other number to the filename so it doesn't overwrite older data
3. Possibly change the text of the file with the destination servernames in it to include the entire path, which would make it possible to backup in different places, or at least remove the need to edit the code to change the backup location
