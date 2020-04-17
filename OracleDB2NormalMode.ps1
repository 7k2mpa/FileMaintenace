#Requires -Version 3.0

<#
.SYNOPSIS
This script siwtch to Normal mode(Ending Backup Mode) Oracle Database after finishing backup software.
CommonFunctions.ps1 is required.

<Common Parameters> is not supported.


Oracle Databaseをバックアップ後に通常モードへ切替するスクリプトです。

<Common Parameters>はサポートしていません

.DESCRIPTION
This script siwtch to Normal mode(Ending Backup Mode) Oracle Database after finishing backup software.
The script loads SQLs.ps1, place SQLs.ps1 previously.
OracleDB2BackUpMode.ps1 is offered also, you may use it with this script.
If Windows Oracle service or Listener service is stopped, start them automatically.

Oracle Databaseをバックアップするには、予めデータベースの停止、またはバックアップモードへ切替が必要です。
従来はデータベースの停止(Shutdown Immediate)で実装する例が大半ですが、停止はセッションが存在すると停止しない等で障害となる例もあります。
そのため本スクリプトはOracle Databaseを停止するのではなく、表領域をバックアップモードへ切替してバックアップを開始する運用を前提として作成しています。

セットで使用するSQLs.PS1を読み込み、実行します。予め配置してください。
対になるバックアップモードから通常モードへ切替するスクリプトを用意しておりますので、セットで運用してください。


Sample Path setting

.\OracleDB2NormalMode.ps1
.\OracleDB2BackUpMode.ps1
.\StartService.ps1
.\CommonFunctions.ps1
..\SQL\SQLs.PS1
..\Log\SQL.LOG
..\Lock\BkUp.flg



.EXAMPLE

.\OracleDB2NormalMode

Switch all tables of Oracle SID specified at Windows enviroment variable to Normal Mode.
Authentification to connecting to Oracle is used OS authentification with OS user running the script.
If Windows Oracle service or Listener service, start them automatically.

Windows環境変数Oracle_SIDに設定された全ての表領域を通常モードへ切替します。
Oracle Databaseの認証はOS認証を用います。このスクリプトが実行されるOSユーザで認証します。
Oracleサービス、Listenerが停止していた場合は起動します。


.\OracleDBNormalMode -OracleSID MCDB -ExecUser FOO -ExecUserPassword BAR -PasswordAuthorization

Switch all tables of Oracle SID MCDB to Normal Mode.
Authentification to connecting to Oracle is used password authentification.
Oracle user is used 'FOO', Oracle user password is used 'BAR'
If Windows Oracle service or Listener service, start them automatically.


Oracle SID MCDBのOracle Databaseの全ての表領域を通常モードへ切替します。
OracleDatabaseの認証はパスワード認証を用いています。ユーザID FOO、パスワード BARでログイン認証します。



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

.PARAMETER StartServicePath
Specify path of StartService.ps1
Specification is required.
Can specify relative or absolute path format.

StartService.ps1のパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。

.PARAMETER SQLLogPath
Specify path of SQL log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.
                                                                                        
.PARAMETER SQLCommandsPath
Specify path of SQLs.ps1
Specification is required.
Can specify relative or absolute path format.

予め用意した、実行するSQL文群を記述したps1ファイルのパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。


.PARAMETER ControlFileDotCtlPATH
Specify to export controle file path ending with .ctl
Specification is required.
Can specify relative or absolute path format.

.CTL形式のコントロールファイルを出力するパスを指定します。

.PARAMETER ControlFileDotBkPATH
Specify to export controle file path ending with .bk
Specification is required.
Can specify relative or absolute path format.

.BK形式のコントロールファイルを出力するパスを指定します。

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



[String][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

[String]$SQLLogPath = '.\SC_Logs\SQL.log',

[String]$SQLCommandsPath = '.\SQL\SQLs.ps1',

[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',
[Switch]$PasswordAuthorization ,

[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[String]$StartServicePath = '.\ChangeServiceStatus.ps1' ,

[int][ValidateRange(1,65535)]$RetrySpanSec = 20,
[int][ValidateRange(1,65535)]$RetryTimes = 15,

[String]$TimeStampFormat = "_yyyyMMdd_HHmmss",

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis

[String]$controlfiledotctlPATH = '.\SC_Logs\file_bk.ctl' ,
[String]$controlfiledotbkPATH  = '.\SC_Logs\controlfile.bk',

[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $FALSE,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath ,
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

    $OracleHomeBinPath = $OracleHomeBinPath | ConvertTo-AbsolutePath -Name  '-OracleHomeBinPath'

    $OracleHomeBinPath | Test-Container -Name '-OracleHomeBinPath' -IfNoExistFinalize > $NULL


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
        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage  "Fail to load SQLs in -SQLCommandsPath"
        Finalize $ErrorReturnCode
        }

    Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to load SQLs Version $($SQLsVersion) in -SQLCommandsPath"


#Oracleサービス起動用のStartService.ps1の存在確認

    $StartServicePath = $StartServicePath | ConvertTo-AbsolutePath -Name '-StartServicePath'

    $StartServicePath | Test-Leaf -Name '-StartServicePath' -IfNoExistFinalize > $NULL



#Oracleサービス存在確認

    $targetWindowsOracleService = "OracleService"+$OracleSID

    IF (-not(Test-ServiceExist -ServiceName $targetWindowsOracleService)) {

        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "Windows Service [$($targetWindowsOracleService)] dose not exist."
        Finalize $ErrorReturnCode
        }

#ControlFile出力先pathの存在確認


    $controlfiledotctlPATH = $controlfiledotctlPATH | ConvertTo-AbsolutePath -Name '-controlfiledotctlPATH '

    $ControlfiledotctlPATH | Split-Path -Parent | Test-Container -Name 'Parent Folder of -controlfiledotctlPATH' -IfNoExistFinalize > $NULL

    $controlfiledotbkPATH = $controlfiledotbkPATH | ConvertTo-AbsolutePath -Name '-controlfiledotbkPATH '

    $ControlfiledotbkPATH | Split-Path  -Parent | Test-Container -Name 'Parent Folder of -controlfiledotbkPATH' -IfNoExistFinalize > $NULL



#処理開始メッセージ出力

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "To start to switch Oracle Database to Normal Mode. (to end BackUp Mode)"

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

[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0


[Boolean]$NeedToStartListener = $TRUE
[String]$ListenerStatus = $NULL

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.1"


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize



Push-Location $OracleHomeBinPath


#リスナー起動状態を確認、必要に応じて起動

$returnMessage = LSNRCTL.exe status  2>&1

[String]$listenerStatus = $returnMessage

Write-Output $returnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode

    Switch -Regex ($ListenerStatus) { 

        'インスタンスがあります' {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Listener is running."
            $needToStartListener = $FALSE
            }

        'リスナーがありません' {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Listener is stopped."
            $needToStartListener = $TRUE
            }   

        Default {
            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Listener status is unknown."
            $needToStartListener = $TRUE
            }     
     }


    IF ($needToStartListener) {
    
        $returnMessage = LSNRCTL.exe START

        Write-Output $returnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode
    
 
        IF ($LASTEXITCODE -eq 0) {
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfulley complete to start Listener."
            
            } else {
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to start Listener."
            Finalize $ErrorReturnCode
            }

    }


#Windowsサービス起動状態を確認、必要に応じて起動    


    IF (Test-ServiceStatus -ServiceName $targetWindowsOracleService -Health Running -Span 0 -UpTo 1) {
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Windows Service [$($targetWindowsOracleService)] is already running."
        
        } else {
        $serviceCommand = "$StartServicePath -Service $targetWindowsOracleService -Status Running -RetrySpanSec $RetrySpanSec -RetryTimes $RetryTimes"
        
        Try {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start Windows Serive [$($targetWindowsOracleService)] with [$($StartServicePath)]"
            Invoke-Expression $serviceCommand        
            }

        catch [Exception] {
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to start script [$($StartServicePath)]"
            $errorDetail = $ERROR[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
            }            
            
        IF ($LASTEXITCODE -ne 0) {
                Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to start Windows service [$($targetWindowsOracleService)]"
                Finalize $ErrorReturnCode
                }
        }


#DBインスタンス状態確認

    $invokeResult = Invoke-SQL -SQLCommand $DBStatus -SQLName 'DB Status Check' -SQLLogPath $SQLLogPath

    IF (($invokeResult.Status) -OR ($invokeResult.log -match 'ORA-01034')) {

            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to check Oracle Database Status."
                
            } else {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Failed to check Oracle Database Status."
            }


        IF ($invokeResult.log -match 'OPEN') {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Oracle instance SID [$($OracleSID)] is already OPEN."
         
  
        }elseIF ($invokeResult.log -match '(STARTED|MOUNTED)') {
            
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Oracle instance SID [$($OracleSID)] is MOUNT or NOMOUNT. Shutdown and start up manually."
            Finalize $ErrorReturnCode

        } else {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Oracle instance SID [$($OracleSID)] is not OPEN."        
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Switch Oracle instance SID [$($OracleSID)] to OPEN."

            $invokeResult = Invoke-SQL -SQLCommand $DBStart -SQLName 'Oracle DB Instance OPEN' -SQLLogPath $SQLLogPath

                IF ($invokeResult.Status) {

                    Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to switch Oracle instance to OPEN."
                
                    } else {
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Failed to switch Oracle instance to OPEN."
                    $ErrorCount ++
                    }
            }




#BackUp/Normal Modeどちらかを確認

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Check Back Up Mode"

    $status = Test-OracleBackUpMode

      IF ($LASTEXITCODE -ne 0) {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to Check Back Up Mode."

        Finalize $ErrorReturnCode
        } else { 
        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to Check Back Up Mode."
        }


 IF (-not($status.BackUp) -and ($status.Normal)) {
 
    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Oracle Database is running in Normal Mode(ending backup mode)"
    }

 IF (-not( ($status.BackUp) -xor ($status.Normal) )) {

    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Oracle Database is running in UNKNOWN mode."
    $ErrorCount ++
 
    } elseIF (($status.BackUp) -and (-not($status.Normal))) {
 
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Oracle Database is running in Backup Mode. Switch to Normal Mode(Ending Backup Mode)"

        $invokeResult = Invoke-SQL -SQLCommand $DBBackUpModeOff -SQLName "Switch to Normal Mode" -SQLLogPath $SQLLogPath

        IF ($invokeResult.Status) {

            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to switch to Normal Mode(Ending Backup Mode)"

            } else {        
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to switch to Normal Mode(Ending Backup Mode)"
            $ErrorCount ++
            }
 }


#コントロールファイル書き出し

#SQL.ps1の置換変数表示になっている対象部分を置換

    $DBExportControlFile = $DBExportControlFile.Replace('&controlfiledotctlPATH' , $controlfiledotctlPATH)
    $DBExportControlFile = $DBExportControlFile.Replace('&controlfiledotbkPATH'  , $controlfiledotbkPATH)

    $invokeResult = Invoke-SQL -SQLCommand $DBExportControlFile -SQLName 'DBExportControlFile'  -SQLLogPath $SQLLogPath

    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to export Oracle Control Files."

        } else {         
        Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Failed to export Oracle Control Files"
        $WarningCount ++
        }


#Redo Log 強制書き出し

    $invokeResult = Invoke-SQL -SQLCommand $ExportRedoLog  -SQLName 'ExportRedoLog'  -SQLLogPath $SQLLogPath 

    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to export Redo Log."
        
        } else {
        Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Failed to export Redo Log."
        $WarningCount ++
        }


Finalize $NormalReturnCode
