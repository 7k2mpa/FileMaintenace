## Summary

A set of useful utility scripts written in PowerShell for Microsoft Windows Platform.

 - [File Maintenance](#filemaintenanceps1)
 - [Windows Service Control](#changeservicestatusps1)
 - [Internet Information Server Control](#changeiisstateps1)
 - [UNC Path Mount](#mountdriveps1--unmountdriveps1)
 - [Oracle Database](#oracledb2backupmodeps1--oracledb2normalmodeps1--oraclearchivelogdeleteps1--oracleexportps1)
 - [arcserveUDP](#arcserveudpbackupps1)
 - [Check Flag](#checkflagps1)
 - [N2WS Backup](#n2wsbackupps1)

## Functions Detail

### FileMaintenance.ps1

Manage log and temp files with various methods including delete , copy , move , compress , archive , rename , nullclear , add time stamp to filename , delete old generation and delete empty folders.
You can select files and folders with various creiteria including file size , number of days elapsed , regular expression , path regular expression.

At once manage only one folder. With Wrapper.ps1 you can manage multiple folders.


### ChangeServiceStatus.ps1

Start and stop Windows service.
If you need script files StopService.ps1 and StartService.ps1 , change comment line at the parameter section.

### ChangeIISstate.ps1

Start and stop IIS site.

### MountDrive.ps1 / UnMountDrive.ps1

Mount and UnMount UNC path SMB file share.


### OracleDB2BackUpMode.ps1 / OracleDB2NormalMode.ps1 / OracleArchiveLogDelete.ps1 / OracleExport.ps1

After or before executing backup software, you run the scripts and start/stop Listener , change Oracle Mode (BackUp or Normal) , export control files.

Delete RMAN archive log.

Export Oracle Database with datapump.


### arcserveUDPbackup.ps1

Execute backup software [arcserveUDP](https://www.arcserve.com/data-protection-solutions/arcserve-udp/) CLI and kick backup job.

### CheckFlag.ps1

Check a Flag File and if the flag file exist(or dose not exist) , delete the flag file(or make a flag file)

### N2WSbackup.ps1

Start backup job and get backup result of [N2WS](https://n2ws.com/) backup appliance for AWS.


### Wrapper.ps1

Execute .ps1 script with an every command line in the command file in order.

### LoopWrapper.ps1

Execute .ps1 script at fixed intervals untill the script is ended with normal return code.

## Documents

Read [Wiki](https://github.com/7k2mpa/FileMaintenace/wiki)

You can read help with 'Get-Help' command.

## Copyright & License
Copyright &copy; 2020 Masayuki Sudo

Licensed under the [Apache License, Version 2.0][Apache]

see [LICENSE](./LICENSE.txt) also

[Apache]: http://www.apache.org/licenses/LICENSE-2.0
