[Boolean]$Log2EventLog = $TRUE
#[Switch]$NoLog2EventLog
[String][ValidateNotNullOrEmpty()]$ProviderName = 'Infra' 
[String][ValidateSet("Application")]$EventLogLogName = 'Application' 

[Boolean]$Log2Console = $TRUE 
#[Switch]$NoLog2Console

[Boolean]$Log2File = $FALSE 
#[Switch]$NoLog2File

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath 

[String][ValidateNotNullOrEmpty()]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss' 
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default'  #Default ShiftJIS


[Int][ValidateRange(0,2147483647)]$NormalReturnCode        =  0 
[Int][ValidateRange(0,2147483647)]$WarningReturnCode       =  1 
[Int][ValidateRange(0,2147483647)]$ErrorReturnCode         =  8 
[Int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16 

[Int][ValidateRange(1,65535)]$InfoEventID          =   9999
[Int][ValidateRange(1,65535)]$InfoLoopStartEventID =   2 
[Int][ValidateRange(1,65535)]$InfoLoopEndEventID   =   3 
[int][ValidateRange(1,65535)]$StartEventID         =   8 
[int][ValidateRange(1,65535)]$EndEventID           =   9 
[Int][ValidateRange(1,65535)]$WarningEventID       =  10 
[Int][ValidateRange(1,65535)]$SuccessEventID       =  73 
[Int][ValidateRange(1,65535)]$InternalErrorEventID =  99 
[Int][ValidateRange(1,65535)]$ErrorEventID         = 100 

#[Switch]$ErrorAsWarning 
#[Switch]$WarningAsNormal 

[Regex]$ExecutableUser = '.*'
