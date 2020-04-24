#Requires -Version 3.0

<#
.SYNOPSIS
This script siwtch to Back Up mode Oracle Database before starting backup software .
CommonFunctions.ps1 , SQLs.ps1 , ChangeServiceStatus.ps1 are required.

<Common Parameters> is not supported.

Oracle Databaseをバックアップ前にバックアップモードへ切替するスクリプトです。

<Common Parameters>はサポートしていません

.DESCRIPTION
This script siwtch to Backup mode Oracle Database before starting backup software.
The script loads SQLs.ps1, place SQLs.ps1 previously.
OracleDB2NormalMode.ps1 is offered also, you may use it with this script.

Oracle Databaseをバックアップするには、予めデータベースの停止、またはバックアップモードへ切替が必要です。
従来はデータベースの停止(Shutdown Immediate)で実装する例が大半ですが、停止はセッションが存在すると停止しない等で障害となる例もあります。
そのため本スクリプトはOracle Databaseを停止するのではなく、表領域をバックアップモードへ切替してバックアップを開始する運用を前提として作成しています。

セットで使用するSQLs.PS1を読み込み、実行します。予め配置してください。
対になるバックアップモードから通常モードへ切替するスクリプトを用意しておりますので、セットで運用してください。


配置例

.\OracleDB2NormalMode.ps1
.\OracleDB2BackUpMode.ps1
.\ChangeServiceStatus.ps1
.\CommonFunctions.ps1
..\SQL\SQLs.PS1
..\Log\SQL.LOG


.EXAMPLE

.\OracleDB2BackUpMode -BackUpFlagPath ..\Flag\BackUp.FLG

Switch all tables of Oracle SID specified at Windows enviroment variable to Backup Mode.
At first check backup flag existence placed in ..\Flag folder.
If the flag file exists, terminate as ERROR.
Authentification to connecting to Oracle is used OS authentification with OS user running the script.
At last stop Listener.

Windowsサービス名OracleServiceMCDB、インスタンス名MCDBのOracle Databaseの全ての表領域をバックアップモードへ切替します。
Oracle Databaseの認証はOS認証を用います。このスクリプトが実行されるOSユーザで認証します。
バックアップ中フラグ..\Flag\BackUp.FLGの存在を確認し、存在した場合はバックアップ中と判定して異常終了します。
切替後にListenerを停止します。

.\OracleDB2BackUpMode -oracleSerivce MCDB -BackUpFlagPath ..\Flag\BackUp.FLG -NoStopListener -ExecUser FOO -ExecUserPassword BAR -PasswordAuthorization

Switch all tables of Oracle SID MCDB to Backup Mode.
Authentification to connecting to Oracle is used password authentification.
Oracle user is used 'FOO', Oracle user password is used 'BAR'
The script dose not stop Listener.

Windowsサービス名OracleServiceMCDB、インスタンス名MCDBのOracle Databaseの全ての表領域をバックアップモードへ切替します。
OracleDatabaseの認証はパスワード認証を用いています。ユーザID BackUpUpser、パスワード FOOBARでログイン認証します。
バックアップ中フラグ..\Flag\BackUp.FLGの存在を確認し、存在した場合はバックアップ中と判定して異常終了します。
切替後にListenerは停止しません。


.PARAMETER OracleSID
Specify Oracle_SID.
Should set '$Env:ORACLE_SID' by default.

対象のOracleSIDを指定します。


.PARAMETER OracleService
This parameter is planed to obsolute.

RMAN Logを削除する対象のOracleSIDを指定します。
このパラメータは廃止予定です。


.PARAMETER OracleHomeBinPath
Specify Oracle 'BIN' path in the child path Oracle home. 
Should set "$Env:ORACLE_HOME +'\BIN'" by default.

Oracle Home配下のBINフォルダまでのパスを指定します。
通常は標準設定である$Env:ORACLE_HOME +'\BIN'（Powershellでの表記）で良いのですが、OSで環境変数%ORACLE_HOME%が未設定環境では当該を設定してください。

.PARAMETER SQLLogPath
Specify path of SQL log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.

.PARAMETER SQLCommandsPath
予め用意した、実行するSQL文群を記述したps1ファイルのパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。

.PARAMETER BackUpFlagPath
バックアップ中を示すフラグファイルのパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。


.PARAMETER PasswordAuthorization
Specify authentification with password authorization.
Should use OS authentification.

パスワード認証を指定します。
OS認証が使えない時に使用する事を推奨します。

.PARAMETER ExecUser
Specify Oracle User to connect. 
Should use OS authentification.

パスワード認証時のユーザを設定します。
OS認証が使えない時に使用する事を推奨します。

.PARAMETER ExecUserPassword
Specify Oracle user Password to connect. 
Should use OS authentification.

パスワード認証時のユーザパスワードを設定します。
OS認証が使えない時に使用する事を推奨します。


.PARAMETER NoChangeToBackUpMode
バックアップモードへの切替不要を指定します。
バックアップソフトウエアによっては、バックアップソフトウエアがOracleをバックアップモードへ切替します。
その場合は当スイッチをOnにして下さい。

.PARAMETER NoStopListener
リスナー停止不要を指定します。
業務断面が必要な場合、バックアップ前にリスナーを停止しますが、業務断面が不要or無停止とする場合は当スイッチをOnにして下さい。




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

#>

Param(

[String][parameter(Position = 0)][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

[String][parameter(Position = 1)]$SQLLogPath = '.\SC_Logs\SQL.log',

[String]$BackUpFlagPath = '.\Lock\BkUpDB.flg',

[String][parameter(Position = 2)]$SQLCommandsPath = '.\SQL\SQLs.ps1',

[String][parameter(Position = 3)]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,


[Switch]$NoChangeToBackUpMode,
[Switch]$NoStopListener,


[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',

[Switch]$PasswordAuthorization ,


#Planed to obsolute
[Switch]$NoCheckBackUpFlag = $TRUE ,
#Planed to obsolute


[Boolean]$Log2Console = $TRUE ,
[Switch]$NoLog2Console ,

[Boolean]$Log2File = $FALSE ,
[Switch]$NoLog2File ,

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]
[ValidateNotNullOrEmpty()]$LogPath ,

[String]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss' ,
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
    Write-Output "Fail to load CommonFunctions.ps1 Please verfy existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }

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


#パラメータの確認

#OracleBINフォルダの指定、存在確認

    $OracleHomeBinPath = $OracleHomeBinPath | ConvertTo-AbsolutePath -Name  '-oracleHomeBinPath'

    $OracleHomeBinPath | Test-Container -Name '-oracleHomeBinPath' -IfNoExistFinalize > $NULL


#BackUpFlagフォルダの指定、存在確認


    IF (-not($NoCheckBackUpFlag)) {

        $BackUpFlagPath = $BackUpFlagPath | ConvertTo-AbsolutePath -ObjectName  '-BackUpFlagPath'

        $BackUpFlagPath | Split-Path -Parent | Test-Container -Name 'Parent Folder of -BackUpFlagPath' -IfNoExistFinalize > $NULL
        }


#SQLLogファイルの指定、存在、書き込み権限確認

    $SQLLogPath = $SQLLogPath | ConvertTo-AbsolutePath -ObjectName '-SQLLogPath'

    $SQLLogPath | Test-LogPath -Name '-SQLLogPath' > $NULL


#SQLコマンド群の指定、存在確認、Load

    $SQLCommandsPath = $SQLCommandsPath | ConvertTo-AbsolutePath -ObjectName '-SQLCommandPath'

    $SQLCommandsPath | Test-Leaf -Name '-SQLCommandsPath' -IfNoExistFinalize > $NULL


    Try {

        . $SQLCommandsPath
        }

        Catch [Exception] {
        Write-Log -Type Error -EventID $ErrorEventID -Message "Fail to load SQLs in -SQLCommandsPath"
        Finalize $ErrorReturnCode
        }

    Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to load SQLs Version $($SQLsVersion) in -SQLCommandsPath"


#Oracle起動確認

    $targetWindowsOracleService = "OracleService" + $OracleSID

    IF (-not(Test-ServiceStatus -ServiceName $targetWindowsOracleService -Health Running)) {

        Write-Log -Type Error -EventID $ErrorEventID -Message "Windows Service [$($targetWindowsOracleService)] is not running or dose not exist."
        Finalize $ErrorReturnCode

        } else {
        Write-Log -EventID $InfoEventID -Type Information -Message "Windows Service [$($targetWindowsOracleService)] is running."
        }


#処理開始メッセージ出力

Write-Log -EventID $InfoEventID -Type Information -Message "All parameters are valid."

Write-Log -EventID $InfoEventID -Type Information -Message "To start to switch Oracle Database to Back Up Mode."

}

function Finalize {

Param(
[parameter(mandatory=$TRUE)][int]$ReturnCode
)

Pop-Location

 Invoke-PostFinalize $ReturnCode


}

#####################   ここから本体  ######################


[boolean]$ErrorFlag = $FALSE
[boolean]$WarningFlag = $FALSE
[boolean]$ContinueFlag = $FALSE
[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0
[int][ValidateRange(0,2147483647)]$OverRideCount = 0
[int][ValidateRange(0,2147483647)]$ContinueCount = 0

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.6"



#初期設定、パラメータ確認、起動メッセージ出力

. Initialize


Push-Location $OracleHomeBinPath

 
#planed to be obsolute バックアップ実行中かを確認

    IF ($NoCheckBackUpFlag) {

        Write-Log -EventID $InfoEventID -Type Information -Message "Specified -NoCheckBackUpFlag option, thus skip to check status with backup flag."
        
        
        } elseIF (Test-Leaf -CheckPath $BackUpFlagPath -ObjectName 'Backup Flag') {

            Write-Log -EventID $ErrorEventID -Type Error -Message "Running Back Up now. Can not start duplicate execution."
            Finalize $ErrorReturnCode
            }
#planed to be obsolute バックアップ実行中かを確認
    

#セッション情報を出力

    Write-Log -EventID $InfoEventID -Type Information -Message "Export Session Info."

    $invokeResult = Invoke-SQL -SQLCommand $SessionCheck -SQLName "Check Sessions" -SQLLogPath $SQLLogPath
 
    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to Export Session Info."

        } else {
        Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to Export Session Info."
        Finalize $ErrorReturnCode
        }


#Redo Log強制書き出し

  Write-Log -EventID $InfoEventID -Type Information -Message "Export Redo Log."

    $invokeResult = Invoke-SQL -SQLCommand $ExportRedoLog -SQLName "Export Redo Log" -SQLLogPath $SQLLogPath

    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -Type Success -Message "Successfully complete to Export Redo Log."
        
        } else {
        Write-Log -EventID $ErrorEventID -Type Error -Message "Failed to Export Redo Log."
        Finalize $ErrorReturnCode
        }


#BackUp/Normal Modeどちらかを確認

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



#Back Up Modeへ切替

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



#Listner停止

    $returnMessage = LSNRCTL.exe status  2>&1

    [String]$listenerStatus = $returnMessage

    Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode


    Switch -Regex ($listenerStatus) { 

        'インスタンスがあります' {

            Write-Log -EventID $InfoEventID -Type Information -Message "Listener is running."
            $needToStopListener = $TRUE
            }

        'リスナーがありません' {
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


Finalize $NormalReturnCode
