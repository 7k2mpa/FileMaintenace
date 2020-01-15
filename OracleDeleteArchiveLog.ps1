﻿#Requires -Version 3.0

<#
.SYNOPSIS
指定日以前のOracle Archive Logを削除するツールです。
Oracleの仕様上、Oracleから古いArchive Logは認識されなくなりますが、ファイルシステム上のファイルは削除されません。
別途、OSコマンドやFileMaintenance.ps1でファイルを削除してください。 

<Common Parameters>はサポートしていません

.DESCRIPTION
指定日以前のOracle Archive Logを削除するツールです。
セットで使用するDeleteArchivelog.rmanを読み込み、実行します。予め配置してください。
実行の際に、何日前を削除するか、引数で指定が可能です。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。


配置例


.\OracleDeleteArchiveLog.ps1
.\CommonFunctions.ps1
..\SQL\DeleteArchiveLog.rman
..\Log\RMAN.LOG




.EXAMPLE

OracleDeleteArchiveLog.ps1 -OracleService MCFRAME -OracleRmanLogPath ..\Log\RMAN.log -Days 7

Oracleサービス名MCFRAME（OS上のサービス名OracleMCFRAME）のインスタンスの7日以前のarchive logを削除します。
RMAN実行結果のログは本スクリプト配置から見て、相対パスの..\Log\Rman.logに出力します。
Rman.logが存在しない場合はファイルを新規作成します。
RMAN実行時の認証はOS認証となり、このスクリプトを実行しているユーザがスクリプト実行ユーザとなります。
当該実行ユーザに対してOracle Administration Assistant for Windowsを使って、管理者権限を付与しておいて下さい。
$ORACLE_HOME\network\admin\sqlnet.ora ファイルに以下の記述が必要です。
SQLNET.AUTHENTICATION_SERVICES = (NTS)


.EXAMPLE

OracleDeleteArchiveLog.ps1 -OracleService MCFRAME -OracleRmanLogPath ..\Log\RMAN.log -Days 7 -PaswordAuthorization -ExecUser foo -ExecUserPassword bar

Oracleサービス名MCFRAME（OS上のサービス名OracleMCFRAME）のインスタンスの7日以前のarchive logを削除します。
RMAN実行結果のログは本スクリプト配置から見て、相対パスの..\Log\Rman.logに出力します。
Rman.logが存在しない場合はファイルを新規作成します。
RMAN実行時の認証はパスワード認証となり、-ExecUser、-ExecUserPasswordで指定されたユーザfoo、パスワードbarでOracleへ接続します。
セキュリティの観点から極力OS認証を利用される事を推奨します。





.PARAMETER OracleService
RMAN Logを削除する対象のOracleサービスを指定します。
必須パラメータです。


.PARAMETER OracleHomeBinPath
Oracle Home配下のBINフォルダまでのパスを指定します。
通常は標準設定である$Env:ORACLE_HOME +'\BIN'（Powershellでの表記）で良いのですが、OSで環境変数%ORACLE_HOME%が未設定環境では当該を設定してください。


.PARAMETER ExecRMANPath
実行するRMANファイルのパスを指定します。
相対パス、絶対パスでの指定が可能です。


.PARAMETER OracleRmanLogPath
RMAN実行時のログ出力先ファイルパスを指定します。
ログ出力先ファイルが存在しない場合は新規作成します。
相対パス、絶対パスでの指定が可能です。


.PARAMETER Days
削除対象にするRMANの経過日数を指定します。


.PARAMETER PasswordAuthorization
パスワード認証を指定します。
OS認証が使えない時に使用する事を推奨します。

.PARAMETER ExecUser
パスワード認証時のユーザを設定します。
OS認証が使えない時に使用する事を推奨します。

.PARAMETER ExecUserPassword
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



#>

Param(

[String]$OracleService = $Env:ORACLE_SID ,
#[parameter(mandatory=$true)][String]$OracleService,

[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$ExecRMANPath = '..\SQL\DeleteArchiveLog.rman' ,

[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$OracleRmanLogPath = '..\Log\RMAN.log',

[parameter(mandatory=$true)][int][ValidateRange(1,65535)]$Days = 1,


[Switch]$PasswordAuthorization ,
[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',



[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis

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

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#パラメータの確認

#OracleBINフォルダの指定、存在確認


    $OracleHomeBinPath = ConvertToAbsolutePath -CheckPath $OracleHomeBinPath -ObjectName  '-OracleHomeBinPath'

    CheckContainer -CheckPath $OracleHomeBinPath -ObjectName '-OracleHomeBinPath' -IfNoExistFinalize > $NULL

#OracleRmanLogファイルの指定、存在、書き込み権限確認



    $OracleRmanLogPath = ConvertToAbsolutePath -CheckPath $OracleRmanLogPath -ObjectName '-OracleRmanLogPath'

    If(-NOT(CheckLeaf -CheckPath $OracleRmanLogPath -ObjectName 'ログファイル -OracleRmanLogPath')){

        TryAction -ActionType MakeNewFileWithValue -ActionFrom $OracleRmanLogPath -ActionError $OracleRmanLogPath -FileValue $Null
        }


#実行するRMANファイルの存在確認
   
    $ExecRmanPath = ConvertToAbsolutePath -CheckPath $ExecRmanPath -ObjectName '-ExecRmanPath'


    CheckLeaf -CheckPath $ExecRmanPath -ObjectName '-ExecRmanPath' -IfNoExistFinalize > $Null


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

Logging -EventID $InfoEventID -EventType Information -EventMessage "$($DAYS)日前のArchiveLog削除を開始します"

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

Pop-Location

EndingProcess $ReturnCode


}

#####################   ここから本体  ######################


${THIS_FILE}=$MyInvocation.MyCommand.Path       　　                    #フルパス
${THIS_PATH}=Split-Path -Parent ($MyInvocation.MyCommand.Path)          #このファイルのパス
${SHELLNAME}=[System.IO.Path]::GetFileNameWithoutExtension($THIS_FILE)  # シェル名

${Version} = '0.9.15'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize


    Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization){

        $RmanLog = RMAN target $ExecUser/$ExecUserPassword@$OracleSerivce CMDFILE "$ExecRMANPath" $Days
        Write-Output $RmanLog | Out-File -FilePath $OracleRmanLogPath -Append  -Encoding $LogFileEncode
        }else{
        $RmanLog = RMAN target / CMDFILE "$ExecRMANPath" $Days
        Write-Output $RmanLog | Out-File -FilePath $OracleRmanLogPath -Append  -Encoding $LogFileEncode
        }


    IF ($LastExitCode -ne 0){

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($DAYS)日前のArchiveLog削除に失敗しました"

	    Finalize $ErrorReturnCode
        }


Logging -EventID $InfoEventID -EventType Information -EventMessage "$($DAYS)日前のArchiveLog削除に成功しました。なお、この削除はOracleから認識されなくする処理です。実ファイル削除は別途必要です"


    Finalize $NormalReturnCode                   

