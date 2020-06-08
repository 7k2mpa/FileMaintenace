#Requires -Version 3.0

<#
.SYNOPSIS

This script switches Oracle Database to Back Up mode before starting backup software .
CommonFunctions.ps1 , SQLs.ps1 , ChangeServiceStatus.ps1 are required.

<Common Parameters> is not supported.



.DESCRIPTION

This script switches Oracle Database to Backup mode before starting backup software.
The script loads SQLs.ps1, place SQLs.ps1 previously.
OracleDB2NormalMode.ps1 is offered also, you may use it with this script.

sample path setting

.\OracleDB2NormalMode.ps1
.\OracleDB2BackUpMode.ps1
.\ChangeServiceStatus.ps1
.\CommonFunctions.ps1
..\SQL\SQLs.PS1
..\Log\SQL.LOG

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to suppress or to output individually. 



.EXAMPLE

.\OracleDB2BackUpMode -BackUpFlagPath ..\Flag\BackUp.FLG

Switch all tables of Oracle SID specified at Windows enviroment variable to Backup Mode.
At first check backup flag existence placed in ..\Flag folder.
If the flag file exists, terminate as ERROR.
Authentification to connecting to Oracle is used OS authentification with OS user running the script.
At last stop Listener.


.EXAMPLE

.\OracleDB2BackUpMode -oracleSerivce MCDB -BackUpFlagPath ..\Flag\BackUp.FLG -NoStopListener -ExecUser FOO -ExecUserPassword BAR -PasswordAuthorization

Switch all tables of Oracle SID MCDB to Backup Mode.
Authentification to connecting to Oracle is used password authentification.
Oracle user is used 'FOO', Oracle user password is used 'BAR'
The script dose not stop Listener.



.PARAMETER OracleSID

Specify Oracle_SID.
Should set [$Env:ORACLE_SID] by default.


.PARAMETER OracleService
This parameter is planed to obsolute.

RMAN Logを削除する対象のOracleSIDを指定します。
このパラメータは廃止予定です。


.PARAMETER OracleHomeBinPath

Specify Oracle 'BIN' path in the child path Oracle home. 
Should set [$Env:ORACLE_HOME +'\BIN'] by default.


.PARAMETER SQLLogPath

Specify path of SQL log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.

.PARAMETER SQLCommandsPath

Specify path of SQLs.ps1.
Specification is required.
Can specify relative or absolute path format.


.PARAMETER BackUpFlagPath
planed to be obsolute
バックアップ中を示すフラグファイルのパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。


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


.PARAMETER NoChangeToBackUpMode

Specify if you do not want to switch to BackUp Mode.
Some backup software use Oracle VSS when starting backup, thus you do not need to switch to BackUp Mode.


.PARAMETER NoStopListener

Specify if you do not want to stop listener.



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

[String][parameter(Position = 1)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$SQLLogPath = '.\SC_Logs\SQL.log',

[String][parameter(Position = 2)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$SQLCommandsPath = '.\SQL\SQLs.ps1',

[String][parameter(Position = 3)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,


[Switch]$NoChangeToBackUpMode,
[Switch]$NoStopListener,


[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',

[Switch]$PasswordAuthorization ,


#Planed to obsolute
[Switch]$NoCheckBackUpFlag = $TRUE ,
[String]$BackUpFlagPath = '.\Lock\BkUpDB.flg',
#Planed to obsolute


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

Try{
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
Catch [Exception]{
    Write-Output "Fail to load CommonFunctions.ps1 Please verify existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }

#!!! end of difenition !!!


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
                        ConvertTo-AbsolutePath -Name  '-oracleHomeBinPath' |
                        Test-PathEx -Type Container -Name '-oracleHomeBinPath' -IfFalseFinalize -PassThrough


#Validate BackUpFlag Folder

    IF (-not($NoCheckBackUpFlag)) {

        $BackUpFlagPath = $BackUpFlagPath | ConvertTo-AbsolutePath -Name  '-BackUpFlagPath'

        $BackUpFlagPath | Split-Path -Parent | Test-PathEx -Type Container -Name 'Parent Folder of -BackUpFlagPath' -IfFalseFinalize > $NULL
        }


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
        Write-Log -Type Error -EventID $ErrorEventID -Message "Fail to load SQLs in -SQLCommandsPath"
        Finalize $ErrorReturnCode
        }

    Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to load SQLs Version $($SQLsVersion) in -SQLCommandsPath"


#Test Oracle service in starting

    $targetWindowsOracleService = "OracleService" + $OracleSID

    IF (-not(Test-ServiceStatus -ServiceName $targetWindowsOracleService -Health Running)) {

        Write-Log -Type Error -EventID $ErrorEventID -Message "Windows Service [$($targetWindowsOracleService)] is not running or dose not exist."
        Finalize $ErrorReturnCode

        } else {
        Write-Log -EventID $InfoEventID -Type Information -Message "Windows Service [$($targetWindowsOracleService)] is running."
        }


#output starting messages

Write-Log -EventID $InfoEventID -Type Information -Message "All parameters are valid."

Write-Log -EventID $InfoEventID -Type Information -Message "To start to switch Oracle Database to Back Up Mode."

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
[int][ValidateRange(0,2147483647)]$OverRideCount = 0
[int][ValidateRange(0,2147483647)]$ContinueCount = 0

$DatumPath = $PSScriptRoot

$Version = "2.1.0-beta.2"


#initialize, validate parameters, output starting message

. Initialize


Push-Location $OracleHomeBinPath

 
#planed to be obsolute バックアップ実行中かを確認

    IF ($NoCheckBackUpFlag) {

        Write-Log -EventID $InfoEventID -Type Information -Message "Specified -NoCheckBackUpFlag option, thus skip to check status with backup flag."
        
        
        } elseIF (Test-PathEx -Type Leaf -Path $BackUpFlagPath -Name 'Backup Flag') {

            Write-Log -EventID $ErrorEventID -Type Error -Message "Running Back Up now. Can not start duplicate execution."
            Finalize $ErrorReturnCode
            }
#planed to be obsolute バックアップ実行中かを確認
    

#Export DB session information

    Write-Log -EventID $InfoEventID -Type Information -Message "Export Session Info."

    $invokeResult = Invoke-SQL -SQLCommand $SessionCheck -SQLName "Check Sessions" -SQLLogPath $SQLLogPath
 
    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to Export Session Info."

        } else {
        Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to Export Session Info."
        Finalize $ErrorReturnCode
        }


#Output Redo Log

  Write-Log -EventID $InfoEventID -Type Information -Message "Export Redo Log."

    $invokeResult = Invoke-SQL -SQLCommand $ExportRedoLog -SQLName "Export Redo Log" -SQLLogPath $SQLLogPath

    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to Export Redo Log."
        
        } else {
        Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to Export Redo Log."
        Finalize $ErrorReturnCode
        }


#get status in which BackUp/Normal Mode

    Write-Log -EventID $InfoEventID -Type Information -Message "Check Database running status in which mode"

    $status = Test-OracleBackUpMode

      IF ($LASTEXITCODE -ne 0) {

        Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to Check Database running status."
        Finalize $ErrorReturnCode
        
        } else {
        Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to Check Database running status."
        }




    IF (($status.BackUp) -and (-not($status.Normal))) {
 
        Write-Log -EventID $WarningEventID -Type Warning -Message "Oracle Database running status is Backup Mode already."
        $WarningCount ++
 
        } elseIF (-not(($status.BackUp) -xor ($status.Normal))) {
 
            Write-Log -EventID $ErrorEventID -Type Error -Message "Oracle Database running status is unknown."
            Finalize $ErrorReturnCode
            }



    IF (-not($status.BackUp) -and ($status.Normal)) {
 
        Write-Log -EventID $InfoEventID -Type Information -Message "Oracle Database running status is Normal Mode."
        }



#Switch to Back Up Mode

    IF ($NoChangeToBackUpMode) {

        Write-Log -EventID $InfoEventID -Type Information -Message "Specified -NoChangeToBackUpMode option, thus do not switch to BackUpMode."

        } else {
        Write-Log -EventID $InfoEventID -Type Information -Message "Switch to Back Up Mode"

        $invokeResult = Invoke-SQL -SQLCommand $DBBackUpModeOn -SQLName "Switch to Back Up Mode" -SQLLogPath $SQLLogPath

        IF ($invokeResult.Status) {

            Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to switch to Back Up Mode."
            
            } else {
            Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to switch to Back Up Mode."
            Finalize $ErrorReturnCode            
            }
    }


#Stop Listner

    $returnMessage = LSNRCTL.exe status  2>&1

    [String]$listenerStatus = $returnMessage

    Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode


    Switch -Regex ($listenerStatus) { 

        '(インスタンスがあります|has \d+ instance\(s\))' {

            Write-Log -EventID $InfoEventID -Type Information -Message "Listener is running."
            $needToStopListener = $TRUE
            }

        '(リスナーがありません|no listener)' {
            Write-Log -EventID $InfoEventID -Type Information -Message "Listener is stopped."
            $needToStopListener = $FALSE
            }   

        Default {
            Write-Log -EventID $WarningEventID -Type Warning -Message "Listener status is unknown."
            $needToStopListener = $TRUE
            }     
     }


    IF ($NoStopListener) {

        Write-Log -EventID $InfoEventID -Type Information -Message "Specified -NoStopListener option, thus do not stop Listener."

        } else {

        IF ($needToStopListener) {

            Write-Log -EventID $InfoEventID -Type Information -Message "Stop Listener."
            $returnMessage = LSNRCTL.exe STOP 2>&1 

            Write-Output $returnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode

            IF ($LASTEXITCODE -ne 0) {

                Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to stop Listener."
                Finalize $ErrorReturnCode

                } else {
                Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to stop Listener."
                }
            
            } else {
            Write-Log -EventID $InfoEventID -Type Information -Message "Listener is stopped already, process next step."
            }
    }


Finalize -ReturnCode $NormalReturnCode
