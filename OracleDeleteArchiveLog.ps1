#Requires -Version 3.0

<#
.SYNOPSIS

This script deletes Oracle Achive logs older than specified days.
Archive log files are deleted in Oracle RMAN records only and you need to delete log files in the file system with OS's delete command.
CommonFunctions.ps1 , DeleteArachiveLog.rman are required.

<Common Parameters> is not supported.



.DESCRIPTION 

This script deletes Oracle Achive logs older than specified days.
The script loads DeleteArchivelog.rman, place DeleteArchivelog.rman previously.
You can specify how old days to delte with arugument.

With OS authentication, $env:ORACLE_SID is used for connecting to RMAN.
If you connect another target, set $env:ORACLE_SID before start the script.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 

Sample Path setting

.\OracleDeleteArchiveLog.ps1
.\CommonFunctions.ps1
..\SQL\DeleteArchiveLog.rman
..\Log\RMAN.LOG



.EXAMPLE

OracleDeleteArchiveLog.ps1 -OracleRmanLogPath ..\Log\RMAN.log -Days 7

Delete archivelog older than 7days in Oracle SID set previously.
Output log to relative path ..\Log\Rman.log for RMAN execution result.
If Rman.log file dose not exist, create a new log file.
Authentification for connecting is with OS authetification, thus the user running the script is authetificated.
Add administrator priviledge for the user at Oracle Administration Assistant for Windows.

Specify parameter on
$ORACLE_HOME\network\admin\sqlnet.ora 

SQLNET.AUTHENTICATION_SERVICES = (NTS)


.EXAMPLE

OracleDeleteArchiveLog.ps1 -OracleSID MCFRAME -OracleRmanLogPath ..\Log\RMAN.log -Days 7 -PaswordAuthorization -ExecUser foo -ExecUserPassword bar

Delete archivelog older than 7days in Oracle SID MCFRAME(Windows Service name OracleServiceMCFRAME)
Output log to relative path ..\Log\Rman.log for RMAN execution result.
If Rman.log file dose not exist, create a new log file.
Authentification for connecting is with plain text user 'foo' and password 'bar'.
Recommend OS authentification for security.



.PARAMETER OracleSID

Specify Oracle_SID for deleting RMAN log.
Should set [$Env:ORACLE_SID] by default.


.PARAMETER OracleService
This parameter is planed to obsolute.

RMAN Logを削除する対象のOracleSIDを指定します。
このパラメータは廃止予定です。


.PARAMETER OracleHomeBinPath

Specify Oracle 'BIN' path in the child path Oracle home. 
Should set [$Env:ORACLE_HOME +'\BIN'] by default.


.PARAMETER ExecRMANPath

Specify path of DeleteArchiveLog.rman
Can specify relative or absolute path format.


.PARAMETER OracleRmanLogPath

Specify path of RMAN log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.


.PARAMETER Days

Specify days to delete.


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

Param(

[int]
[parameter(Position = 0, mandatory)][ValidateRange(1,65535)]$Days = 1 ,

[String]
[parameter(Position = 1)][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

[String]
[parameter(Position = 2)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$OracleRMANLogPath = '.\SC_Logs\RMAN.log' ,

[String]
[parameter(Position = 3)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$ExecRMANPath = '.\SQL\DeleteArchiveLog.rman' ,

[String]
[parameter(Position = 4)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,


[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',

[Switch]$PasswordAuthorization ,


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

Try {

    #CommonFunctions.ps1の配置先を変更した場合は、ここを変更。同一フォルダに配置前提
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception] {
    Write-Output "Fail to load CommonFunctions.ps1 Please verify existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }

################ 設定が必要なのはここまで ##################



################# 共通部品、関数  #######################


function Initialize {

$ShellName = $PSCommandPath | Split-Path -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. Invoke-PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#Validate Parameters

#Validate Oracle BIN

$OracleHomeBinPath = $OracleHomeBinPath |
                        ConvertTo-AbsolutePath -Name  '-OracleHomeBinPath' |
                        Test-Container -Name '-OracleHomeBinPath' -IfNoExistFinalize -PassThrough


#Validate Oracle RMAN Log File

$OracleRMANLogPath = $OracleRMANLogPath |
                        ConvertTo-AbsolutePath -Name '-OracleRmanLogPath' |
                        Test-LogPath -Name '-OracleRMANLLogPath' -PassThrough



#Validate Oracle RMAN command File
   
$ExecRmanPath = $ExecRmanPath
                    ConvertTo-AbsolutePath -Name '-ExecRmanPath' |
                    Test-Leaf -Name '-ExecRmanPath' -IfNoExistFinalize -PassThrough



#対象のOracleがサービス起動しているか確認

    $targetWindowsOracleService = "OracleService"+$OracleSID

    IF (-not($targetWindowsOracleService | Test-ServiceStatus -Status Running)) {

        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "Windows Service [$($targetWindowsOracleService)] is not running or dose not exist."
        Finalize $ErrorReturnCode
        } else {
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Windows Service [$($targetWindowsOracleService)] is running."
        }
     



#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to delete Oracle archive logs older than $($Days)days."

}

function Finalize {

Param(
[parameter(position = 0, mandatory)][int]$ReturnCode
)

Pop-Location

 Invoke-PostFinalize $ReturnCode
}

#####################   ここから本体  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.2"


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

    Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization) {

        $rmanLog = RMAN.exe target $ExecUser/$ExecUserPassword@$OracleSID CMDFILE "$ExecRMANPath" $Days
        Write-Output $rmanLog | Out-File -FilePath $OracleRMANLogPath -Append  -Encoding $LogFileEncode
 
        } else {
        $rmanLog = RMAN.exe target / CMDFILE "$ExecRMANPath" $Days
        Write-Output $rmanLog | Out-File -FilePath $OracleRMANLogPath -Append  -Encoding $LogFileEncode
        }


    IF ($LASTEXITCODE -ne 0) {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to delete Oracle archive logs older than $($Days)days."

        Finalize $ErrorReturnCode
        }


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Successfully completed to delete Oracle archive logs older than $($Days)days."
Write-Log -EventID $InfoEventID -EventType Information -EventMessage "!!REMIND they were deleted in Oracle RMAN records and you need to delete log files in the file system with OS's delete command!!"
 

Finalize $NormalReturnCode
