#Requires -Version 3.0

<#
.SYNOPSIS

This script switches to Normal mode(Ending Backup Mode) Oracle Database after finishing backup software.
CommonFunctions.ps1 , SQLs.ps1 are required.

<Common Parameters> is not supported.



.DESCRIPTION

This script switches to Normal mode(Ending Backup Mode) Oracle Database after finishing backup software.
The script loads SQLs.ps1, place SQLs.ps1 previously.
OracleDB2BackUpMode.ps1 is offered also, you may use it with this script.
If Windows Oracle service or Listener service is stopped, start them automatically.

Sample Path setting

.\OracleDB2NormalMode.ps1
.\OracleDB2BackUpMode.ps1
.\ChangeServiceStatus.ps1
.\CommonFunctions.ps1
..\SQL\SQLs.PS1
..\Log\SQL.LOG

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to suppress or to output individually. 



.EXAMPLE

.\OracleDB2NormalMode

Switch all tables of Oracle SID specified at Windows enviroment variable to Normal Mode.
Authentification to connecting to Oracle is used OS authentification with OS user running the script.
If Windows Oracle service or Listener service, start them automatically.


.\OracleDBNormalMode -OracleSID MCDB -ExecUser FOO -ExecUserPassword BAR -PasswordAuthorization

Switch all tables of Oracle SID MCDB to Normal Mode.
Authentification to connecting to Oracle is used password authentification.
Oracle user is used 'FOO', Oracle user password is used 'BAR'
If Windows Oracle service or Listener service, start them automatically.



.PARAMETER OracleSID

Specify Oracle_SID.
Should set [$Env:ORACLE_SID] by default.


.PARAMETER OracleHomeBinPath

Specify Oracle 'BIN' path in the child path Oracle home. 
Should set [$Env:ORACLE_HOME +'\BIN'] by default.


.PARAMETER StartServicePath

Specify path of ChangeServiceStatus.ps1
Specification is required.
Can specify relative or absolute path format.

 
.PARAMETER SQLLogPath

Specify path of SQL log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.


.PARAMETER SQLCommandsPath

Specify path of SQLs.ps1
Specification is required.
Can specify relative or absolute path format.


.PARAMETER ControlFileDotCtlPATH

Specify to export controle file path ending with .ctl
Specification is required.
Can specify relative or absolute path format.


.PARAMETER ControlFileDotBkPATH

Specify to export controle file path ending with .bk
Specification is required.
Can specify relative or absolute path format.


.PARAMETER PasswordAuthorization

Specify authentification with password authorization.
Should use OS authentification.
Should use for test only.


.PARAMETER ExecUser

Specify Oracle User to connect. 
Should use OS authentification.


.PARAMETER ExecUserPassword

Specify Oracle user Password to connect. 
Should use OS authentification.



.PARAMETER CommonConfigPath

Specify common configuration file path in relative path format.
Only this parameter, you can specify the path with only relative path format.
With this parameter, you can specify same event id for utility scripts with common config file.
If you want to cancel using common config file specified in Param section of the script, specify this argument with NULL or empty string.


.PARAMETER Log2EventLog

Specify if you want to output log to Windows Event Log.
[$TRUE] is default.


.PARAMETER NoLog2EventLog

Specify if you want to suppress log to Windows Event Log.
Specification overrides -Log2EventLog


.PARAMETER ProviderName

Specify provider name of Windows Event Log.
[Infra] is default.


.PARAMETER EventLogLogName

Specify log name of Windows Event Log.
[Application] is default.


.PARAMETER Log2Console

Specify if you want to output log to PowerShell console.
[$TRUE] is default.


.PARAMETER NoLog2Console

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2Console


.PARAMETER Log2File

Specify if you want to output log to text log.
[$FALSE] is default.


.PARAMETER NoLog2File

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2File


.PARAMETER LogPath

Specify the path of text log file.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.
[$NULL] is default.

If the log file dose not exist, the script makes a new file.
If the log file exists, the script writes log additionally.


.PARAMETER LogDateFormat

Specicy time stamp format in the text log.
[yyyy-MM-dd-HH:mm:ss] is default.


.PARAMETER LogFileEncode

Specify the character encode in the log file.
[Default] is default and it works as ShiftJIS.


.PARAMETER NormalReturnCode

Specify Normal Return code.
[0] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER WarningReturnCode

Specify Warning Return code.
[1] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER ErrorReturnCode

Specify Error Return code.
[8] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER InternalErrorReturnCode

Specify Internal Error Return code.
[16] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER InfoEventID

Specify information event id in the log.
[1] is default.


.PARAMETER InfoLoopStartEventID

Specify start loop event id in the log.
[2] is default.


.PARAMETER InfoLoopEndEventID

Specify end loop event id in the log.
[3] is default.


.PARAMETER StartEventID

Specify start script id in the log.
[8] is default.


.PARAMETER EndEventID

Specify end script event id in the log.
[9] is default.


.PARAMETER WarningEventID

Specify Warning event id in the log.
[10] is default.


.PARAMETER SuccessEventID

Specify Successfully complete event id in the log.
[73] is default.


.PARAMETER InternalErrorEventID

Specify Internal Error event id in the log.
[99] is default.


.PARAMETER ErrorEventID

Specify Error event id in the log.
[100] is default.


.PARAMETER ErrorAsWarning

Specfy if you want to return WARNING exit code when the script terminate with an Error.


.PARAMETER WarningAsNormal

Specify if you want to return NORMAL exit code when the script terminate with a Warning.


.PARAMETER ExecutableUser

Specify the users who are allowed to execute the script in regular expression.
[.*] is default and all users are allowed to execute.
Parameter must be quoted with single quote'
Escape the back slash in the separeter of a domain name.
example [domain\\.*]



.NOTES

Copyright 2020 Masayuki Sudo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



.LINK

https://github.com/7k2mpa/FileMaintenace



.OUTPUTS

System.Int. Return Code.
#>

#!!! start of definition !!!#
Param(

[String][parameter(Position = 0)][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

[String][parameter(Position = 1)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$SQLLogPath = '.\SC_Logs\SQL.log' ,

[String][parameter(Position = 2)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$SQLCommandsPath = '.\SQL\SQLs.ps1' ,

[String][parameter(Position = 3)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[String][parameter(Position = 4)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$controlfiledotctlPATH = '.\SC_Logs\file_bk.ctl' ,
[String][parameter(Position = 5)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$controlfiledotbkPATH  = '.\SC_Logs\controlfile.bk' ,

[String][parameter(Position = 6)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$StartServicePath = '.\ChangeServiceStatus.ps1' ,


[int][ValidateRange(1,65535)]$RetrySpanSec = 20 ,
[int][ValidateRange(1,65535)]$RetryTimes = 15 ,


[String]$ExecUser = 'hogehoge' ,
[String]$ExecUserPassword = 'hogehoge' ,
[Switch]$PasswordAuthorization ,

#[String]$TimeStampFormat = "_yyyyMMdd_HHmmss" ,



#[String][ValidatePattern('^(|\0|(\.+\\)(?!.*(\/|:|\?|`"|<|>|\||\*))).*$')]$CommonConfigPath = '.\CommonConfig.ps1' , #MUST specify with relative path format
[String][ValidatePattern('^(|\0|(\.+\\)(?!.*(\/|:|\?|`"|<|>|\||\*))).*$')]$CommonConfigPath = $NULL ,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String][ValidateNotNullOrEmpty()]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[Boolean]$Log2Console = $TRUE ,
[Switch]$NoLog2Console ,

[Boolean]$Log2File = $FALSE ,
[Switch]$NoLog2File ,

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath ,

[String][ValidateNotNullOrEmpty()]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss' ,
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default' , #Default ShiftJIS


[Int][ValidateRange(0,2147483647)]$NormalReturnCode        =  0 ,
[Int][ValidateRange(0,2147483647)]$WarningReturnCode       =  1 ,
[Int][ValidateRange(0,2147483647)]$ErrorReturnCode         =  8 ,
[Int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16 ,

[Int][ValidateRange(1,65535)]$InfoEventID          =   1 ,
[Int][ValidateRange(1,65535)]$InfoLoopStartEventID =   2 ,
[Int][ValidateRange(1,65535)]$InfoLoopEndEventID   =   3 ,
[int][ValidateRange(1,65535)]$StartEventID         =   8 ,
[int][ValidateRange(1,65535)]$EndEventID           =   9 ,
[Int][ValidateRange(1,65535)]$WarningEventID       =  10 ,
[Int][ValidateRange(1,65535)]$SuccessEventID       =  73 ,
[Int][ValidateRange(1,65535)]$InternalErrorEventID =  99 ,
[Int][ValidateRange(1,65535)]$ErrorEventID         = 100 ,

[Switch]$ErrorAsWarning ,
[Switch]$WarningAsNormal ,

[Regex]$ExecutableUser = '.*'

)


################# CommonFunctions.ps1 Load  #######################
# If you want to place CommonFunctions.ps1 in differnt path, modify

Try {
    ."$PSScriptRoot\CommonFunctions.ps1"

    IF ($LASTEXITCODE -eq 99) {
        Exit 1
    }
}
Catch [Exception] {
    Write-Error "Fail to load CommonFunctions.ps1 Please verify existence of CommonFunctions.ps1 in the same folder."
    Exit 1
}

#!!! end of definition !!!


################# functions  #######################

function Initialize {

$ShellName = $PSCommandPath | Split-Path -Leaf

<#
PreInitialization for basic logging functions
Already egistered Event Source in Windows Event Log?
Log File output path
Validate Return Codes
Validate Execution user
Output Script Starting messages
#>
. Invoke-PreInitialize


#If passed PreInitilization, validate only business logics.

#validate parameters

#Validate Oracle BIN

$OracleHomeBinPath = $OracleHomeBinPath |
                        ConvertTo-AbsolutePath -Name  '-OracleHomeBinPath' |
                        Test-PathEx -Type Container -Name '-OracleHomeBinPath' -IfFalseFinalize -PassThrough


#Validate SQL Log File

$SQLLogPath = $SQLLogPath |
                ConvertTo-AbsolutePath -ObjectName '-SQLLogPath' |
                Test-PathEx -Type Log -Name '-SQLLogPath' -IfFalseFinalize -Passthrough


#Validate SQL command File

$SQLCommandsPath = $SQLCommandsPath |
                        ConvertTo-AbsolutePath -Name '-SQLCommandPath' |
                        Test-PathEx -Type Leaf -Name '-SQLCommandsPath' -IfFalseFinalize -PassThrough

    Try {
        . $SQLCommandsPath
        }

        Catch [Exception] {
        Write-Log -Type Error -EventID $ErrorEventID -Message  "Fail to load SQLs in -SQLCommandsPath"
        Finalize $ErrorReturnCode
        }

    Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to load SQLs Version $($SQLsVersion) in -SQLCommandsPath"


#Validate StartService script path for Starting Oracle service

$StartServicePath = $StartServicePath |
                        ConvertTo-AbsolutePath -Name '-StartServicePath' |
                        Test-PathEx -Type Leaf -Name '-StartServicePath' -IfFalseFinalize -PassThrough


#Test existence Oracle service

    $targetWindowsOracleService = "OracleService" + $OracleSID

    IF (-not(Test-ServiceExist -ServiceName $targetWindowsOracleService)) {

        Write-Log -Type Error -EventID $ErrorEventID -Message "Windows Service [$($targetWindowsOracleService)] dose not exist."
        Finalize $ErrorReturnCode
        }


#Validate output path of ControlFile

    $controlfiledotctlPATH = $controlfiledotctlPATH | ConvertTo-AbsolutePath -Name '-controlfiledotctlPATH '

    $ControlfiledotctlPATH | Split-Path -Parent | Test-PathEx -Type Container -Name 'Parent Folder of -controlfiledotctlPATH' -IfFalseFinalize > $NULL

    $controlfiledotbkPATH = $controlfiledotbkPATH | ConvertTo-AbsolutePath -Name '-controlfiledotbkPATH '

    $ControlfiledotbkPATH | Split-Path  -Parent | Test-PathEx -Type Container -Name 'Parent Folder of -controlfiledotbkPATH' -IfFalseFinalize > $NULL


#output starting messages

Write-Log -EventID $InfoEventID -Type Information -Message "All parameters are valid."

Write-Log -EventID $InfoEventID -Type Information -Message "To start to switch Oracle Database to Normal Mode. (to end BackUp Mode)"

}

function Finalize {

Param(
[parameter(position = 0, mandatory)][int]$ReturnCode
)

Pop-Location

 Invoke-PostFinalize $ReturnCode


}


#####################  main  ######################

[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0


[Boolean]$NeedToStartListener = $TRUE
[String]$ListenerStatus = $NULL

$DatumPath = $PSScriptRoot

$Version = "3.1.1"


#initialize, validate parameters, output starting message

. Initialize


Push-Location $OracleHomeBinPath


#Get status of listener and start listener

$returnMessage = LSNRCTL.exe status  2>&1

[String]$listenerStatus = $returnMessage

Write-Output $returnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode

    Switch -Regex ($ListenerStatus) { 

        '(インスタンスがあります|has \d+ instance\(s\))' {

            Write-Log -EventID $InfoEventID -Type Information -Message "Listener is running."
            $needToStartListener = $FALSE
            }

        '(リスナーがありません|no listener)' {
            Write-Log -EventID $InfoEventID -Type Information -Message "Listener is stopped."
            $needToStartListener = $TRUE
            }   

        Default {
            Write-Log -EventID $WarningEventID -Type Warning -Message "Listener status is unknown."
            $needToStartListener = $TRUE
            $WarningCount ++
            }     
    }


    IF ($needToStartListener) {
    
        $returnMessage = LSNRCTL.exe START 2>&1 

        Write-Output $returnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode
    
 
        IF ($LASTEXITCODE -eq 0) {
            Write-Log -EventID $SuccessEventID -Type Success -Message "Successfulley complete to start Listener."
            
            } else {
            Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to start Listener."
            Finalize $ErrorReturnCode
            }

        }


#Test Oracle Windows serivce, and start   

    IF (Test-ServiceStatus -ServiceName $targetWindowsOracleService -Health Running -Span 0 -UpTo 1) {
        Write-Log -EventID $InfoEventID -Type Information -Message "Windows Service [$($targetWindowsOracleService)] is already running."
        
        } else {
        $serviceCommand = "$StartServicePath -Service $targetWindowsOracleService -Status Running -RetrySpanSec $RetrySpanSec -RetryTimes $RetryTimes"
        
        Try {
            Write-Log -EventID $InfoEventID -Type Information -Message "Start Windows Serive [$($targetWindowsOracleService)] with [$($StartServicePath)]"
            Invoke-Expression $serviceCommand        
            }

        catch [Exception] {
            Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to start script [$($StartServicePath)]"
            $errorDetail = $ERROR[0] | Out-String
            Write-Log -EventID $ErrorEventID -Type Error -Message "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
            }            
            
        IF ($LASTEXITCODE -ne 0) {
            Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to start Windows service [$($targetWindowsOracleService)]"
            Finalize $ErrorReturnCode
            }
        }


#Get status of DB instance

    $invokeResult = Invoke-SQL -SQLCommand $DBStatus -SQLName 'DB Status Check' -SQLLogPath $SQLLogPath

    IF (($invokeResult.Status) -or ($invokeResult.log -match 'ORA-01034')) {

            Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to check Oracle Database Status."
                
            } else {
            Write-Log -EventID $InfoEventID -Type Information -Message "Failed to check Oracle Database Status."
            $WarningCount ++
            }


    Switch -Regex ($invokeResult.log) {

        'OPEN' {

            Write-Log -EventID $InfoEventID -Type Information -Message "Oracle instance SID [$($OracleSID)] is already OPEN."            
            }
       
        '(STARTED|MOUNTED)' {

            Write-Log -EventID $ErrorEventID -Type Error -Message "Oracle instance SID [$($OracleSID)] is MOUNT or NOMOUNT. Shutdown and start up manually."
            Finalize $ErrorReturnCode            
            } 

        default {

            Write-Log -EventID $InfoEventID -Type Information -Message "Oracle instance SID [$($OracleSID)] is not OPEN."        
            Write-Log -EventID $InfoEventID -Type Information -Message "Switch Oracle instance SID [$($OracleSID)] to OPEN."

            $invokeResult = Invoke-SQL -SQLCommand $DBStart -SQLName 'Oracle DB Instance OPEN' -SQLLogPath $SQLLogPath

                IF ($invokeResult.Status) {

                    Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to switch Oracle instance to OPEN."
                
                    } else {
                    Write-Log -EventID $InfoEventID -Type Information -Message "Failed to switch Oracle instance to OPEN."
                    $ErrorCount ++
                    }
            }
    }


#Get status in which BackUp/Normal Mode

    Write-Log -EventID $InfoEventID -Type Information -Message "Check Back Up Mode"

    $status = Test-OracleBackUpMode

      IF ($LASTEXITCODE -ne 0) {

        Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to Check Back Up Mode."
        Finalize $ErrorReturnCode

        } else { 
        Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to Check Back Up Mode."
        }


    Switch ($status) {

            {($_.Normal) -and -not($_.Backup)} {

                Write-Log -EventID $InfoEventID -Type Information -Message "Oracle Database is running in Normal Mode(ending backup mode)"
                }

            {($_.Backup) -and -not($_.Normal)} {

                Write-Log -EventID $InfoEventID -Type Information -Message "Oracle Database is running in Backup Mode. Switch to Normal Mode(Ending Backup Mode)"

                $invokeResult = Invoke-SQL -SQLCommand $DBBackUpModeOff -SQLName "Switch to Normal Mode" -SQLLogPath $SQLLogPath

                IF ($invokeResult.Status) {
        
                    Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to switch to Normal Mode(Ending Backup Mode)"
        
                    } else {        
                    Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to switch to Normal Mode(Ending Backup Mode)"
                    $ErrorCount ++
                    }                
                }

            Default {

                Write-Log -EventID $ErrorEventID -Type Error -Message "Oracle Database is running in UNKNOWN mode."
                $ErrorCount ++                
                }
    }


#Export control file

#replace the paths in SQL.ps1

    $DBExportControlFile = $DBExportControlFile.Replace('&controlfiledotctlPATH' , $controlfiledotctlPATH)
    $DBExportControlFile = $DBExportControlFile.Replace('&controlfiledotbkPATH'  , $controlfiledotbkPATH)

    $invokeResult = Invoke-SQL -SQLCommand $DBExportControlFile -SQLName 'DBExportControlFile'  -SQLLogPath $SQLLogPath

    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to export Oracle Control Files."

        } else {         
        Write-Log -EventID $WarningEventID -Type Warning -Message "Failed to export Oracle Control Files."
        $WarningCount ++
        }


#export Redo Log

    $invokeResult = Invoke-SQL -SQLCommand $ExportRedoLog  -SQLName 'ExportRedoLog'  -SQLLogPath $SQLLogPath 

    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to export Redo Log."
        
        } else {
        Write-Log -EventID $WarningEventID -Type Warning -Message "Failed to export Redo Log."
        $WarningCount ++
        }


Finalize -ReturnCode $NormalReturnCode
