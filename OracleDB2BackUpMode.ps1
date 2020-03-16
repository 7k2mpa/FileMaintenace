#Requires -Version 3.0

<#
.SYNOPSIS
Oracle Databaseをバックアップ前にバックアップモードへ切替するスクリプトです。

<Common Parameters>はサポートしていません

.DESCRIPTION
Oracle Databaseをバックアップするには、予めデータベースの停止、またはバックアップモードへ切替が必要です。
従来はデータベースの停止(Shutdown Immediate)で実装する例が大半ですが、停止はセッションが存在すると停止しない等で障害となる例もあります。
そのため本スクリプトはOracle Databaseを停止するのではなく、表領域をバックアップモードへ切替してバックアップを開始する運用を前提として作成しています。

セットで使用するSQLs.PS1を読み込み、実行します。予め配置してください。
対になるバックアップモードから通常モードへ切替するスクリプトを用意しておりますので、セットで運用してください。


配置例

.\OracleDB2NormalMode.ps1
.\OracleDB2BackUpMode.ps1
.\StartService.ps1
.\CommonFunctions.ps1
..\SQL\SQLs.PS1
..\Log\SQL.LOG
..\Lock\BkUp.flg



.EXAMPLE

.\OracleDB2BackUpMode -oracleSerivce MCDB -BackUpFlagPath ..\Flag\BackUp.FLG

Windowsサービス名OracleServiceMCDB、インスタンス名MCDBのOracle Databaseの全ての表領域をバックアップモードへ切替します。
Oracle Databaseの認証はOS認証を用います。このスクリプトが実行されるOSユーザで認証します。
バックアップ中フラグ..\Flag\BackUp.FLGの存在を確認し、存在した場合はバックアップ中と判定して異常終了します。
切替後にListenerを停止します。

.\OracleDB2BackUpMode -oracleSerivce MCDB -BackUpFlagPath ..\Flag\BackUp.FLG -NoStopListener -ExecUser BackUpUser -ExecUserPassword FOOBAR -PasswordAuthorization

Windowsサービス名OracleServiceMCDB、インスタンス名MCDBのOracle Databaseの全ての表領域をバックアップモードへ切替します。
OracleDatabaseの認証はパスワード認証を用いています。ユーザID BackUpUpser、パスワード FOOBARでログイン認証します。
バックアップ中フラグ..\Flag\BackUp.FLGの存在を確認し、存在した場合はバックアップ中と判定して異常終了します。
切替後にListenerは停止しません。



.PARAMETER OracleService
制御するORACLEのサービス名（通常はOracleServiceにSIDを付加したもの）を指定します。
通常は環境変数ORACLE_SIDで良いですが、未設定の環境では個別に指定が必要です。

.PARAMETER OracleHomeBinPath
Oracleの各種BINが格納されているフォルダパスを指定します。
通常は環境変数ORACLE_HOME\BINで良いですが、未設定の環境では個別に指定が必要です。
.PARAMETER SQLLogPath
実行するSQL文群のログ出力先を指定します。
指定は必須です。


.PARAMETER SQLCommandsPath
予め用意した、実行するSQL文群を記述したps1ファイルのパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。

.PARAMETER BackUpFlagPath
バックアップ中を示すフラグファイルのパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。


.PARAMETER ExecUser
Oracleユーザ認証時のユーザ名を指定します。
OS認証使えない時に使用する事を推奨します。

.PARAMETER ExecUserPassword
Oracleユーザ認証時のパスワードを指定します。
OS認証が使えない時に使用する事を推奨します。

.PARAMETER PasswordAuthorization
Oracleへユーザ/パスワード認証でログオンする事を指定します。
OS認証が使えない時に使用する事を推奨します。


.PARAMETER NoChangeToBackUpMode
バックアップモードへの切替不要を指定します。
バックアップソフトウエアによっては、バックアップソフトウエアがOracleをバックアップモードへ切替します。
その場合は当スイッチをOnにして下さい。

.PARAMETER NoStopListener
リスナー停止不要を指定します。
業務断面が必要な場合、バックアップ前にリスナーを停止しますが、業務断面が不要or無停止とする場合は当スイッチをOnにして下さい。




.PARAMETER Log2EventLog
　Windows Event Logへの出力を制御します。
デフォルトは$TRUEでEvent Log出力します。

.PARAMETER NoLog2EventLog
　Event Log出力を抑止します。-Log2EventLog $FALSEと等価です。
Log2EventLogより優先します。

.PARAMETER ProviderName
　Windows Event Log出力のプロバイダ名を指定します。デフォルトは[Infra]です。

.PARAMETER EventLogLogName
　Windows Event Log出力のログ名をしています。デフォルトは[Application]です。

.PARAMETER Log2Console 
　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console
　コンソールログ出力を抑止します。-Log2Console $FALSEと等価です。
Log2Consoleより優先します。

.PARAMETER Log2File
　ログフィルへの出力を制御します。デフォルトは$FALSEでログファイル出力しません。

.PARAMETER NoLog2File
　ログファイル出力を抑止します。-Log2File $FALSEと等価です。
Log2Fileより優先します。

.PARAMETER LogPath
　ログファイル出力パスを指定します。デフォルトは$NULLです。
相対、絶対パスで指定可能です。
ファイルが存在しない場合は新規作成します。
ファイルが既存の場合は追記します。

.PARAMETER LogDateFormat
　ログファイル出力に含まれる日時表示フォーマットを指定します。デフォルトは[yyyy-MM-dd-HH:mm:ss]形式です。

.PARAMETER NormalReturnCode
　正常終了時のリターンコードを指定します。デフォルトは0です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER WarningReturnCode
　警告終了時のリターンコードを指定します。デフォルトは1です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER ErrorReturnCode
　異常終了時のリターンコードを指定します。デフォルトは8です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER InternalErrorReturnCode
　プログラム内部異常終了時のリターンコードを指定します。デフォルトは16です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER InfoEventID
　Event Log出力でInformationに対するEvent IDを指定します。デフォルトは1です。

.PARAMETER WarningEventID
　Event Log出力でWarningに対するEvent IDを指定します。デフォルトは10です。

.PARAMETER SuccessErrorEventID
　Event Log出力でSuccessに対するEvent IDを指定します。デフォルトは73です。

.PARAMETER InternalErrorEventID
　Event Log出力でInternal Errorに対するEvent IDを指定します。デフォルトは99です。

.PARAMETER ErrorEventID
　Event Log出力でErrorに対するEvent IDを指定します。デフォルトは100です。

.PARAMETER ErrorAsWarning
　異常終了しても警告終了のReturnCodeを返します。

.PARAMETER WarningAsNormal
　警告終了しても正常終了のReturnCodeを返します。

.PARAMETER ExecutableUser
　このプログラムを実行可能なユーザを正規表現で指定します。
デフォルトは[.*]で全てのユーザが実行可能です。　
記述はシングルクオーテーションで括って下さい。
正規表現のため、ドメインのバックスラッシュは[domain\\.*]の様にバックスラッシュでエスケープして下さい。　

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

[String]$OracleSID = $Env:ORACLE_SID ,
[String]$OracleService ,

[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[String]$SQLLogPath = '.\SC_Logs\SQL.log',
[String]$BackUpFlagPath = '.\Lock\BkUpDB.flg',

[Switch]$NoCheckBackUpFlag = $TRUE ,

[String]$SQLCommandsPath = '.\SQL\SQLs.ps1',

[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',

[Switch]$PasswordAuthorization ,



[Switch]$NoChangeToBackUpMode,
[Switch]$NoStopListener,

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis



[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $FALSE,
[Switch]$NoLog2File,
[String]$LogPath = $NULL,
[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss",

[int][ValidateRange(0,2147483647)]$NormalReturnCode = 0,
[int][ValidateRange(0,2147483647)]$WarningReturnCode = 1,
[int][ValidateRange(0,2147483647)]$ErrorReturnCode = 8,
[int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16,

[int][ValidateRange(1,65535)]$InfoEventID = 1,
[int][ValidateRange(1,65535)]$WarningEventID = 10,
[int][ValidateRange(1,65535)]$SuccessEventID = 73,
[int][ValidateRange(1,65535)]$InternalErrorEventID = 99,
[int][ValidateRange(1,65535)]$ErrorEventID = 100,

[Switch]$ErrorAsWarning,
[Switch]$WarningAsNormal,

[Regex]$ExecutableUser ='.*'

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

$ShellName = Split-Path -Path $PSCommandPath -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い

#For Backward compatibility

    IF ( (-not($OracleSID)) -and ($OracleService))  {
            $OracleSID = $OracleSerivce
            } 

#パラメータの確認

#OracleBINフォルダの指定、存在確認

    $OracleHomeBinPath = ConvertToAbsolutePath -CheckPath $OracleHomeBinPath -ObjectName  '-oracleHomeBinPath'

    CheckContainer -CheckPath $OracleHomeBinPath -ObjectName '-oracleHomeBinPath' -IfNoExistFinalize > $NULL


#BackUpFlagフォルダの指定、存在確認


    IF (-not($NoCheckBackUpFlag)) {

        $BackUpFlagPath = ConvertToAbsolutePath -CheckPath $BackUpFlagPath -ObjectName  '-BackUpFlagPath'

        Split-Path $BackUpFlagPath | ForEach-Object {CheckContainer -CheckPath $_ -ObjectName 'Parent Folder of -BackUpFlagPath' -IfNoExistFinalize > $NULL}

        }


#SQLLogファイルの指定、存在、書き込み権限確認

    $SQLLogPath = ConvertToAbsolutePath -CheckPath $SQLLogPath -ObjectName '-SQLLogPath'

    CheckLogPath -CheckPath $SQLLogPath -ObjectName '-SQLLogPath' > $NULL


#SQLコマンド群の指定、存在確認、Load

    $SQLCommandsPath = ConvertToAbsolutePath -CheckPath $SQLCommandsPath -ObjectName '-SQLCommandPath'

    CheckLeaf -CheckPath $SQLCommandsPath -ObjectName '-SQLCommandsPath' -IfNoExistFinalize > $NULL


    Try {

        . $SQLCommandsPath
        }

        Catch [Exception] {
        Logging -EventType Error -EventID $ErrorEventID -EventMessage  "Fail to load SQLs in -SQLCommandsPath"
        Finalize $ErrorReturnCode
    }

    Logging -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to load SQLs Version $($SQLsVersion) in -SQLCommandsPath"


#Oracle起動確認

    $targetWindowsOracleService = "OracleService"+$OracleSID

    IF (-not(CheckServiceStatus -ServiceName $targetWindowsOracleService -Health Running)) {

        Logging -EventType Error -EventID $ErrorEventID -EventMessage "Windows Service [$($targetWindowsOracleService)] is not running or dose not exist."
        Finalize $ErrorReturnCode
        }else{
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Windows Service [$($targetWindowsOracleService)] is running."
        }


#処理開始メッセージ出力

Logging -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Logging -EventID $InfoEventID -EventType Information -EventMessage "To start to switch Oracle Database to Back Up Mode."

}

function Finalize {

Param(
[parameter(mandatory=$TRUE)][int]$ReturnCode
)

Pop-Location

EndingProcess $ReturnCode


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

$Version = '20200207_1615'



#初期設定、パラメータ確認、起動メッセージ出力

. Initialize


Push-Location $OracleHomeBinPath


#バックアップ実行中かを確認

    IF ($NoCheckBackUpFlag) {

        Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -NoCheckBackUpFlag option,thus skip to check status with backup flag."
        
        
        }elseIF (CheckLeaf -CheckPath $BackUpFlagPath -ObjectName 'Backup Flag') {

            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Running Back Up now. Can not start duplicate execution."
            Finalize $ErrorReturnCode
            }
    

#セッション情報を出力

    Logging -EventID $InfoEventID -EventType Information -EventMessage "Export Session Info."

    $execSQLReturnCode =  . ExecSQL -SQLCommand $SessionCheck -SQLName "Check Sessions" -SQLLogPath $SQLLogPath
 
    IF ($execSQLReturnCode) {

        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to Export Session Info."

        }else{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Failed to Export Session Info."
	    Finalize $ErrorReturnCode
        
        }


#Redo Log強制書き出し

  Logging -EventID $InfoEventID -EventType Information -EventMessage "Export Redo Log."

    $execSQLReturnCode = . ExecSQL -SQLCommand $ExportRedoLog -SQLName "Export Redo Log" -SQLLogPath $SQLLogPath

    IF ($execSQLReturnCode) {

        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to Export Redo Log."
        
        }else{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Failed to Export Redo Log."
	    Finalize $ErrorReturnCode

        }





#BackUp/Normal Modeどちらかを確認

    Logging -EventID $InfoEventID -EventType Information -EventMessage "Check Database running status in which mode"

  . CheckOracleBackUpMode > $NULL

      IF ($LASTEXITCODE -ne 0) {

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Failed to Check Database running status ."
	    Finalize $ErrorReturnCode
        
        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to Check Database running status."
        }




    IF (($BackUpModeFlag) -and (-not($NormalModeFlag))) {
 
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "Oracle Database running status is Backup Mode already."
        $WarningCount ++
 
        }elseIF (-not  (($BackUpModeFlag) -xor ($NormalModeFlag))) {
 
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Oracle Database running status is unknown."
            Finalize $ErrorReturnCode
            }



    IF (-not($BackUpModeFlag) -and ($NormalModeFlag)) {
 
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle Database running status is Normal Mode."


#Back Up Modeへ切替

    IF ($NoChangeToBackUpMode) {

        Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -NoChangeToBackUpMode option, thus do not switch to BackUpMode."

        }else{
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Switch to Back Up Mode"

        $execSQLReturnCode = . ExecSQL -SQLCommand $DBBackUpModeOn -SQLName "Switch to Back Up Mode" -SQLLogPath $SQLLogPath

        IF ($execSQLReturnCode) {

            Logging -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to switch to Back Up Mode."
            
            }else{
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Failed to switch to Back Up Mode."

	        Finalize $ErrorReturnCode
            
            }

    }

}


#Listner停止

    $returnMessage = LSNRCTL.exe status  2>&1

    [String]$listenerStatus = $returnMessage

    Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode


    Switch -Regex ($listenerStatus) { 

        'インスタンスがあります' {

            Logging -EventID $InfoEventID -EventType Information -EventMessage "Listener is running."
            $needToStopListener = $TRUE
            }

        'リスナーがありません' {
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Listener is stopped."
            $needToStopListener = $FALSE
            }   

        Default {
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "Listener status is unknown."
            $needToStopListener = $TRUE
            }     
     }


    IF ($NoStopListener) {

        Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -NoStopListener option, thus do not stop Listener."

        }else{

        IF ($needToStopListener) {

            Logging -EventID $InfoEventID -EventType Information -EventMessage "Stop Listener"
            $returnMessage = LSNRCTL.exe STOP 2>&1 

            Write-Output $returnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode

            IF ($LASTEXITCODE -ne 0) {

                Logging -EventID $ErrorEventID -EventType Error -EventMessage "Failed to stop Listener."
                Finalize $ErrorReturnCode

                }else{
                Logging -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to stop Listener."
                }
            
            }else{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Listener is stopped already, process next step."
            }
    }


Finalize $NormalReturnCode