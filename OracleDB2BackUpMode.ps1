#Requires -Version 3.0

<#
.SYNOPSIS
Oracle Databaseをバックアップ前にバックアップモードへ切替するスクリプトです。

はサポートしていません

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



#>

Param(


[String]$OracleService = $Env:ORACLE_SID,


[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[String]$SQLLogPath = '..\Log\SQL.log',
[String]$BackUpFlagPath = '..\Lock\BkUpDB.flg',

[String]$SQLCommandsPath = '..\SQL\SQLs.ps1',

[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',

[Switch]$PasswordAuthorization ,



[Switch]$NoChangeToBackUpMode,
[Switch]$NoStopListener,





[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
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

Try{

    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "CommonFunction.ps1のLoadに失敗しました"
    }


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

    CheckNullOrEmpty -CheckPath $OracleHomeBinPath -ObjectName '-OracleHomeBinPath' -IfNullOrEmptyFinalize > $NULL

    CheckContainer -CheckPath $OracleHomeBinPath -ObjectName '-OracleHomeBinPath' -IfNoExistFinalize > $NULL


#SQLLogファイルの指定、存在、書き込み権限確認


#    CheckNullOrEmpty -CheckPath $SQLLogPath -ObjectName '-SQLLogPath' -IfNullOrEmptyFinalize > $NULL

        $SQLLogPath = ConvertToAbsolutePath -CheckPath $SQLLogPath -ObjectName '-SQLLogPath'

    If(Test-Path -Path $SQLLogPath -PathType Leaf){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "-SQLLogPathの書込権限を確認します"
        $LogWrite = $LogFormattedDate+" "+$SHELLNAME+" Write Permission Check"
       

        Try{
            Write-Output $LogWrite | Out-File -FilePath $SQLLogPath -Append
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-SQLLogPathの書込に成功しました"
            }
        Catch [Exception]{
            Logging -EventType Error -EventID $ErrorEventID -EventMessage  "-SQLLogPathへの書込に失敗しました"
            Finalize $ErrorReturnCode
            }
    
     }else{
            TryAction -ActionType MakeNewFileWithValue -ActionFrom $SQLLogPath -ActionError $SQLLogPath -FileValue $Null
            }

#SQLコマンド群の指定、存在確認、Load

    $SQLCommandsPath = ConvertToAbsolutePath -CheckPath $SQLCommandsPath -ObjectName '-SQLCommandPath'

    CheckLeaf -CheckPath $SQLCommandsPath -ObjectName '-SQLCommandsPath' -IfNoExistFinalize > $NULL


    Try{

        . $SQLCommandsPath
        }
        Catch [Exception]{
        Logging -EventType Error -EventID $ErrorEventID -EventMessage  "-SQLCommandsPathに指定されたSQL群のLoadに失敗しました"
        Finalize $ErrorReturnCode
    }


#Oracle起動確認

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

Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle Back Up Mode切替開始します"

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

${Version} = '0.9.14'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize



  Push-Location $OracleHomeBinPath


#バックアップ実行中かを確認


  IF(CheckLeaf -CheckPath $BackUpFlagPath -ObjectName 'バックアップ実行中フラグ'){

   Logging -EventID $ErrorEventID -EventType Error -EventMessage "Back Up実行中です。重複実行は出来ません"
   Finalize $ErrorReturnCode
   }
   

#セッション情報を出力

    Logging -EventID $InfoEventID -EventType Information -EventMessage "Export Session Info"

    ExecSQL -SQLCommand $SessionCheck -SQLName "Check Sessions" -SQLLogPath $SQLLogPath > $Null

    IF ($LastExitCode -ne 0){

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Export Session Infoに失敗しました"

        Finalize $ErrorReturnCode
        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Export Session Infoに成功しました"
        }


#Redo Log強制書き出し

  Logging -EventID $InfoEventID -EventType Information -EventMessage "Export Redo Log"

  . ExecSQL -SQLCommand $ExportRedoLog -SQLName "Export Redo Log" -SQLLogPath $SQLLogPath > $Null

      IF ($LastExitCode -ne 0){

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Export Redo Logに失敗しました"

        Finalize $ErrorReturnCode
        }else{ Logging -EventID $SuccessEventID -EventType Success -EventMessage "Export Redo Logに成功しました"}





#BackUp/Normal Modeどちらかを確認

    Logging -EventID $InfoEventID -EventType Information -EventMessage "Check Back Up Mode"

  . CheckOracleBackUpMode > $Null

      IF ($LastExitCode -ne 0){

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Check Back Up Modeに失敗しました"

        Finalize $ErrorReturnCode
        }else{ Logging -EventID $SuccessEventID -EventType Success -EventMessage "Check Back Up Modeに成功しました"}




    IF(($BackUpModeFlag) -and (-NOT($NormalModeFlag))){

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "既にバックアップモードです"



        }elseif(-NOT  (($BackUpModeFlag) -xor ($NormalModeFlag))){

            Logging -EventID $ErrorEventID -EventType Error -EventMessage "状態が不明です"
            Finalize $ErrorReturnCode
            }



    IF(-NOT($BackUpModeFlag) -and ($NormalModeFlag)){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "通常モードです"




#Back Up Modeへ切替

    IF($NoChangeToBackUpMode){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "-NoChangeToBackUpModeが指定されているのでBackUpMode切替しません"

        }else{

        Logging -EventID $InfoEventID -EventType Information -EventMessage "Change to Back Up Mode"

      . ExecSQL -SQLCommand $DBBackUpModeOn -SQLName "Change to Back Up Mode" -SQLLogPath $SQLLogPath >$Null


        IF ($LastExitCode -ne 0){

            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Change to Back Up Modeに失敗しました"

            Finalize $ErrorReturnCode
           
            }else{
            Logging -EventID $SuccessEventID -EventType Success -EventMessage "Change to Back Up Modeに成功しました"
            }

    }

}


#Listner停止

$ReturnMessage = lsnrctl status  2>&1

[String]$ListenerStatus = $ReturnMessage

Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append

    Switch -Regex ($ListenerStatus){

        'インスタンスがあります'{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "Listenerは起動中"
            $NeedToStopListener = $TRUE
            }

        'リスナーがありません'{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Listenerは停止中"
            $NeedToStopListener = $False
            }  

        Default{
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "Listenerの状態は不明"
            $NeedToStopListener = $TRUE
            }
    
     }


    IF($NoStopListener){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "-NoStopListenerが指定されているのでListenerは停止しません"

        }else{


        IF($NeedToStopListener){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "Stop Listener"
            $ReturnMessage = LSNRCTL STOP 2>&1

            Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append

            IF ($LastExitCode -ne 0){

                Logging -EventID $ErrorEventID -EventType Error -EventMessage "Listener停止に失敗しました"
                Finalize $ErrorReturnCode
                }else{
                Logging -EventID $SuccessEventID -EventType Success -EventMessage "Listener停止に成功しました"
                }
        }else{
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Listenerは停止しているので、後続処理へ進みます"
        }
    }


Finalize $NormalReturnCode                  
