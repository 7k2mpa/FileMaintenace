#Requires -Version 3.0






[String]$DBStart = @'

WHENEVER SQLERROR EXIT 1
startup

'@

[String]$DBStatus = @'

WHENEVER SQLERROR EXIT 1
select STATUS from v$instance;


'@

[String]$DBShutDown = @'

WHENEVER SQLERROR EXIT 1
alter session set events 'immediate trace name systemstate level 266';
alter session set events 'immediate trace name systemstate level 266';
alter session set events 'immediate trace name systemstate level 266'; 
shutdown immediate;


'@

[String]$DBExportControlFile = @"

WHENEVER SQLERROR EXIT 1
alter database backup controlfile to 'D:\Scripts\Infra\SC_Logs\file_bk.ctl';
alter database backup controlfile to trace as 'D:\Scripts\Infra\SC_Logs\controlfile.bk';


"@


[String]$DBCheckBackUpMode = @'

WHENEVER SQLERROR EXIT 1
select * from v$backup status;


'@


[String]$DBBackUpModeOn = @'

WHENEVER SQLERROR EXIT 1
alter database begin backup;
select * from v$backup status;


'@



[String]$DBBackUpModeOff = @'

WHENEVER SQLERROR EXIT 1
alter database end backup;
select * from v$backup status;


'@

[String]$ListnerRegist = @'

alter system register;


'@

[String]$SessionCheck = @'

SELECT sid,serial#,username,status,machine,program,sql_id FROM v$session WHERE username IS NOT NULL and sid != USERENV('SID');


'@


[String]$ExportRedoLog = @'

WHENEVER SQLERROR EXIT 1
alter system archive log current;


'@
