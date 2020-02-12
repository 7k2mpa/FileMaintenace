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

.\OracleDB2BackUpMode -OracleSerivce MCDB -BackUpFlagPath ..\Flag\BackUp.FLG

Windowsサービス名OracleServiceMCDB、インスタンス名MCDBのOracle Databaseの全ての表領域をバックアップモードへ切替します。
Oracle Databaseの認証はOS認証を用います。このスクリプトが実行されるOSユーザで認証します。
バックアップ中フラグ..\Flag\BackUp.FLGの存在を確認し、存在した場合はバックアップ中と判定して異常終了します。
切替後にListenerを停止します。

.\OracleDB2BackUpMode -OracleSerivce MCDB -BackUpFlagPath ..\Flag\BackUp.FLG -NoStopListener -ExecUser BackUpUser -ExecUserPassword FOOBAR -PasswordAuthorization

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
　Event Log出力を抑止します。-Log2EventLog $Falseと等価です。
Log2EventLogより優先します。

.PARAMETER ProviderName
　Windows Event Log出力のプロバイダ名を指定します。デフォルトは[Infra]です。

.PARAMETER EventLogLogName
　Windows Event Log出力のログ名をしています。デフォルトは[Application]です。

.PARAMETER Log2Console 
　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console
　コンソールログ出力を抑止します。-Log2Console $Falseと等価です。
Log2Consoleより優先します。

.PARAMETER Log2File
　ログフィルへの出力を制御します。デフォルトは$Falseでログファイル出力しません。

.PARAMETER NoLog2File
　ログファイル出力を抑止します。-Log2File $Falseと等価です。
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


#>


Param(

[String]$ExecUser = 'foo',
[String]$ExecUserPassword = 'hogehoge',
[parameter(mandatory=$true , HelpMessage = 'Oracle Service(ex. MCDB) 全てのHelpはGet-Help FileMaintenance.ps1')][String]$OracleService ,
#[String]$OracleService = 'MCDB',

#[parameter(mandatory=$true)][String]$Schema  ,
[String]$Schema = 'MCFRAME' ,

[String]$HostName = $Env:COMPUTERNAME,

[String]$DumpDirectoryObject='MCFDATA_PUMP_DIR' ,

#[String]$OracleHomeBinPath = 'D:\TEST' ,
[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[Switch]$PasswordAuthorization ,

[String][ValidatePattern('^(?!.*(\\|\/|:|\?|`"|<|>|\|)).*$')]$TimeStampFormat = '_yyyyMMdd_HHmmss',

[String]$DumpFile = $HostName+"_"+$Schema+"_PUMP.dmp",
[String]$LogFile  = $HostName+"_"+$Schema+"_PUMP.log",

[Switch]$AddtimeStamp,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console =$TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[C-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\|)).*$')]$LogPath ,
[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss",
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis

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

Try{

    #CommonFunctions.ps1の配置先を変更した場合は、ここを変更。同一フォルダに配置前提
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "CommonFunctions.ps1 のLoadに失敗しました。CommonFunctions.ps1がこのファイルと同一フォルダに存在するか確認してください"
    Exit 1
    }


################ 設定が必要なのはここまで ##################

################# 共通部品、関数  #######################


function Initialize {

$SHELLNAME=Split-Path $PSCommandPath -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#パラメータの確認

#指定フォルダの有無を確認

   $OracleHomeBinPath = ConvertToAbsolutePath -CheckPath $OracleHomeBinPath -ObjectName  '-OracleHomeBinPath'

   CheckContainer -CheckPath $OracleHomeBinPath -ObjectName '-OracleHomeBinPath' -IfNoExistFinalize > $NULL


        

#対象のOracleがサービス起動しているか確認

    $TargetOracleService = "OracleService"+$OracleService

    $ServiceStatus = CheckServiceStatus -ServiceName $TargetOracleService -Health Running

    IF (-NOT($ServiceStatus)){


        Logging -EventType Error -EventID $ErrorEventID -EventMessage "対象のOracleServiceが起動していません。"
        Finalize $ErrorReturnCode
        }else{
        Logging -EventID $InfoEventID -EventType Information -EventMessage "対象のOracle Serviceは正常に起動しています"
        }
     

#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle Data Pumpを開始します"

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

Pop-Location

EndingProcess $ReturnCode


}

#####################   ここから本体  ######################

$Version = '20200207_1615'

$DatumPath = $PSScriptRoot


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize



    IF($AddTimeStamp){

        $DumpFile = AddTimeStampToFileName -TimeStampFormat $TimeStampFormat -TargetFileName $DumpFile
        $LogFile = AddTimeStampToFileName -TimeStampFormat $TimeStampFormat -TargetFileName $LogFile

    }



    IF ($PasswordAuthorization){

        $ExecCommand = $ExecUser+"/"+$ExecUserPassword+"@"+$OracleService+" Directory="+$DumpDirectoryObject+" Schemas="+$Schema+" DumpFile="+$DumpFile+" LogFile="+$LogFile+" Reuse_DumpFiles=y"
    
    }else{

        $ExecCommand = "`' /@"+$OracleService+" as sysdba `' Directory="+$DumpDirectoryObject+" Schemas="+$Schema+" DumpFile="+$DumpFile+" LogFile="+$LogFile+" Reuse_DumpFiles=y "

    }

#echo $ExecCommand


#$ExecCommand = [ScriptBlock]::Create($ExecCommand)

#exit

# Invoke-NativeApplication -ScriptBlock $ExecCommand

Push-Location $OracleHomeBinPath

$Process = Start-Process .\expdp -ArgumentList $ExecCommand -Wait -NoNewWindow -PassThru 

#Invoke-NativeApplicationSafe -ScriptBlock $ExecCommand


IF ($Process.ExitCode -ne 0){


#IF ($LastExitCode -ne 0){

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Oracle Data Pumpに失敗しました"
	    Finalize $ErrorReturnCode



        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Oracle Data Pumpに成功しました"
        Finalize $NormalReturnCode
        }
                   

