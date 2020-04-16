#Requires -Version 3.0

<#
.SYNOPSIS
This script deletes Oracle Achive logs older than specified days.
Archive log files are deleted in Oracle RMAN records only and you need to delete log files in the file system with OS's delete command.
CommonFunctions.ps1 is required.

<Common Parameters> is not supported.


指定日以前のOracle Archive Logを削除するツールです。
Oracleの仕様上、Oracleから古いArchive Logは認識されなくなりますが、ファイルシステム上のファイルは削除されません。
別途、OSコマンドやFileMaintenance.ps1でファイルを削除してください。 

<Common Parameters>はサポートしていません

.DESCRIPTION 
This script deletes Oracle Achive logs older than specified days.
The script loads DeleteArchivelog.rman, place DeleteArchivelog.rman previously.
You can specify how old days to delte with arugument.

With OS authentication, $env:ORACLE_SID is used for connecting to RMAN.
If you connect another target, set $env:ORACLE_SID before start the script.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


指定日以前のOracle Archive Logを削除するツールです。
セットで使用するDeleteArchivelog.rmanを読み込み、実行します。予め配置してください。
実行の際に、何日前を削除するか、引数で指定が可能です。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。


File Path sample

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


予め設定済OracleSIDのインスタンスの7日以前のarchive logを削除します。
RMAN実行結果のログは本スクリプト配置から見て、相対パスの..\Log\Rman.logに出力します。
Rman.logが存在しない場合はファイルを新規作成します。
RMAN実行時の認証はOS認証となり、このスクリプトを実行しているユーザがスクリプト実行ユーザとなります。
当該実行ユーザに対してOracle Administration Assistant for Windowsを使って、管理者権限を付与しておいて下さい。
$ORACLE_HOME\network\admin\sqlnet.ora ファイルに以下の記述が必要です。
SQLNET.AUTHENTICATION_SERVICES = (NTS)


.EXAMPLE

OracleDeleteArchiveLog.ps1 -OracleSID MCFRAME -OracleRmanLogPath ..\Log\RMAN.log -Days 7 -PaswordAuthorization -ExecUser foo -ExecUserPassword bar

Delete archivelog older than 7days in Oracle SID MCFRAME(Windows Service name OracleServiceMCFRAME)
Output log to relative path ..\Log\Rman.log for RMAN execution result.
If Rman.log file dose not exist, create a new log file.
Authentification for connecting is with plain text user 'foo' and password 'bar'.
Recommend OS authentification for security.


Oracleサービス名MCFRAME（OS上のサービス名OracleMCFRAME）のインスタンスの7日以前のarchive logを削除します。
RMAN実行結果のログは本スクリプト配置から見て、相対パスの..\Log\Rman.logに出力します。
Rman.logが存在しない場合はファイルを新規作成します。
RMAN実行時の認証はパスワード認証となり、-ExecUser、-ExecUserPasswordで指定されたユーザfoo、パスワードbarでOracleへ接続します。
セキュリティの観点から極力OS認証を利用される事を推奨します。



.PARAMETER OracleSID
Specify Oracle_SID for deleting RMAN log.
Should set '$Env:ORACLE_SID' by default.

RMAN Logを削除する対象のOracleSIDを指定します。


.PARAMETER OracleService
This parameter is planed to obsolute.

RMAN Logを削除する対象のOracleSIDを指定します。
このパラメータは廃止予定です。


.PARAMETER OracleHomeBinPath
Specify Oracle 'BIN' path in the child path Oracle home. 
Should set "$Env:ORACLE_HOME +'\BIN'" by default.

Oracle Home配下のBINフォルダまでのパスを指定します。
通常は標準設定である$Env:ORACLE_HOME +'\BIN'（Powershellでの表記）で良いのですが、OSで環境変数%ORACLE_HOME%が未設定環境では当該を設定してください。


.PARAMETER ExecRMANPath
Specify path of DeleteArchiveLog.rman
Can specify relative or absolute path format.

実行するRMANファイルのパスを指定します。
相対パス、絶対パスでの指定が可能です。


.PARAMETER OracleRmanLogPath
Specify path of RMAN log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.


RMAN実行時のログ出力先ファイルパスを指定します。
ログ出力先ファイルが存在しない場合は新規作成します。
相対パス、絶対パスでの指定が可能です。


.PARAMETER Days
Specify days to delete.

削除対象にするRMANの経過日数を指定します。


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
　Event Log出力を抑止します。-Log2EventLog $Falseと等価です。

.PARAMETER ProviderName
　Windows Event Log出力のプロバイダ名を指定します。デフォルトは[Infra]です。

.PARAMETER EventLogLogName
　Windows Event Log出力のログ名をしています。デフォルトは[Application]です。

.PARAMETER Log2Console 
　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console
　コンソールログ出力を抑止します。-Log2Console $Falseと等価です。

.PARAMETER Log2File
　ログフィルへの出力を制御します。デフォルトは$Falseでログファイル出力しません。

.PARAMETER NoLog2File
　ログファイル出力を抑止します。-Log2File $Falseと等価です。

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

[int][parameter(Position = 0, mandatory)][ValidateRange(1,65535)]$Days = 1 ,

[String][parameter(Position = 1)][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

[String][parameter(Position = 2)][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$OracleRMANLogPath = '.\SC_Logs\RMAN.log' ,

[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$ExecRMANPath = '.\SQL\DeleteArchiveLog.rman' ,

[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,


[Switch]$PasswordAuthorization ,
[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',


[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default for ShiftJIS

[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
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


#パラメータの確認

#OracleBINフォルダの指定、存在確認

    $OracleHomeBinPath = $OracleHomeBinPath | ConvertTo-AbsolutePath -Name  '-OracleHomeBinPath'

    $OracleHomeBinPath | Test-Container -Name '-OracleHomeBinPath' -IfNoExistFinalize > $NULL

#OracleRmanLogファイルの指定、存在、書き込み権限確認

    $OracleRMANLogPath = $OracleRMANLogPath | ConvertTo-AbsolutePath -Name '-OracleRmanLogPath'

    $OracleRMANLogPath | Test-LogPath -Name '-OracleRMANLLogPath' > $NULL


#実行するRMANファイルの存在確認
   
    $ExecRmanPath = $ExecRmanPath  | ConvertTo-AbsolutePath -Name '-ExecRmanPath'

    $ExecRmanPath | Test-Leaf -Name '-ExecRmanPath' -IfNoExistFinalize > $NULL


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
[parameter(mandatory=$true)][int]$ReturnCode
)

Pop-Location

 Invoke-PostFinalize $ReturnCode
}

#####################   ここから本体  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.1"


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
