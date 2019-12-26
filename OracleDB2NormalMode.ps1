#Requires -Version 3.0

<#
.SYNOPSIS
Oracle Databaseをバックアップ後に通常モードへ切替するスクリプトです。

はサポートしていません

.DESCRIPTION
Oracle Databaseをバックアップ後は、状態に応じた起動処理が必要です。
このスクリプトはWindowsのOracleサービス起動、インスタンス起動、リスナー起動、表領域をバックアップモードから通常モードへの切替等の一連の手順を状態判定しながら自動的に行います。

セットで使用するSQLs.PS1を読み込み、実行します。予め配置してください。
セットで開発しているStartService.ps1が必要です。予め配置してください。
対になっている通常モードからバックアップモードへ切替するスクリプトを用意しておりますので、セットで運用してください。


配置例

.\OracleDB2NormalMode.ps1
.\OracleDB2BackUpMode.ps1
.\StartService.ps1
.\CommonFunctions.ps1
..\SQL\SQLs.PS1
..\Log\SQL.LOG
..\Lock\BkUp.flg

.EXAMPLE

.\OracleDB2NormalMode -OracleSerivce MCDB

Windowsサービス名OracleServiceMCDB、インスタンス名MCDBのOracle Databaseの全ての表領域を通常モードへ切替します。
Oracle Databaseの認証はOS認証を用います。このスクリプトが実行されるOSユーザで認証します。


.\OracleDB2NormalMode -OracleSerivce MCDB -ExecUser BackUpUser -ExecUserPassword FOOBAR -PasswordAuthorization

Windowsサービス名OracleServiceMCDB、インスタンス名MCDBのOracle Databaseの全ての表領域を通常モードへ切替します。
OracleDatabaseの認証はパスワード認証を用いています。ユーザID BackUpUpser、パスワード FOOBARでログイン認証します。




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

[String][String]$SQLCommandsPath = '..\SQL\SQLs.ps1',

[String]$StartServicePath = '.\StartService.ps1' ,

[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',
[Switch]$PasswordAuthorization ,


[int][parameter(HelpMessage = 'Oracleサービス起動のリトライ待ち時間(ex. 30(sec))Oracleは起動に時間が掛かるので30秒を推奨 全てのHelpはGet-Help StartService.ps1')][ValidateRange(1,65535)]$RetrySpanSec = 30,
[int][parameter(HelpMessage = 'Oracleサービス起動のリトライ待ち時間の繰返.回数(ex. 10(times))Oracleは起動に時間が掛かるので10回を推奨 全てのHelpはGet-Help StartService.ps1')][ValidateRange(1,65535)]$RetryTimes = 10,



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


#Oracleサービス起動用のStartService.ps1の存在確認

    $StartServicePath = ConvertToAbsolutePath -CheckPath $StartServicePath -ObjectName '-StartServicePath'

    CheckLeaf -CheckPath $StartServicePath -ObjectName '-StartServicePath' -IfNoExistFinalize > $NULL



#Oracleサービス存在確認

    $TargetOracleService = "OracleService"+$OracleService

    IF(-NOT(CheckServiceExist -ServiceName $TargetOracleService)){

        Logging -EventType Error -EventID $ErrorEventID -EventMessage "対象のOracleServiceが存在しません"
        Finalize $ErrorReturnCode

        }
       


#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

Logging -EventID $InfoEventID -EventType Information -EventMessage "OracleをBackUpModeからNormalModeへ変更します"

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

Pop-Location

EndingProcess $ReturnCode


}

#####################   ここから本体  ######################

[boolean]$ErrorFlag = $False
[boolean]$WarningFlag = $False
[boolean]$ContinueFlag = $False
[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0
[int][ValidateRange(0,2147483647)]$OverRideCount = 0
[int][ValidateRange(0,2147483647)]$ContinueCount = 0

[Boolean]$NeedToStartListener = $TRUE
[String]$ListenerStatus = $Null

${THIS_FILE}=$MyInvocation.MyCommand.Path       　　                    #フルパス
${THIS_PATH}=Split-Path -Parent ($MyInvocation.MyCommand.Path)          #このファイルのパス
${SHELLNAME}=[System.IO.Path]::GetFileNameWithoutExtension($THIS_FILE)  # シェル名


$FormattedDate = (Get-Date).ToString($TimeStampFormat)

${Version} = '0.9.14'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize



Push-Location $OracleHomeBinPath


#リスナー起動状態を確認、必要に応じて起動

$ReturnMessage = lsnrctl status  2>&1

[String]$ListenerStatus = $ReturnMessage

Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append

    Switch -Regex ($ListenerStatus){

        'インスタンスがあります'{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "Listenerは起動済"
            $NeedToStartListener = $False
            }

        'リスナーがありません'{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Listenerは停止中"
            $NeedToStartListener = $TRUE
            }  

        Default{
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "Listenerの状態は不明"
            $NeedToStartListener = $TRUE
            }
    
     }


    IF($NeedToStartListener){
   
        $ReturnMessage = LSNRCTL START

        Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append
   


        IF($LastExitCode -eq 0){
            Logging -EventID $SuccessEventID -EventType Success -EventMessage "Listenerは起動に成功しました"
           
            }else{
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Listenerは起動に失敗しました"
            Finalize $ErrorReturnCode
            }

    }



#Windowsサービス起動状態を確認、必要に応じて起動   


    $ServiceStatus = CheckServiceStatus -ServiceName $TargetOracleService -Health Running -Span 0 -UpTo 1


    IF ($ServiceStatus){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($TargetOracleService)]は既に起動しています"
       
        }else{
       

       $ServiceCommand = "$StartServicePath -Service $TargetOracleService -RetrySpanSec $RetrySpanSec -RetryTimes $RetryTimes"


        Try{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "Windowsサービス [$($TargetOracleService)]起動を開始します"
            Invoke-Expression $ServiceCommand
       
        }
        catch [Exception]{

            Logging -EventID $ErrorEventID -EventType Error -EventMessage "[$($StartServicePath)]の起動に失敗しました。"
            $ErrorDetail = $Error[0] | Out-String
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "起動時エラーメッセージ : $ErrorDetail"
            Finalize $ErrorReturnCode
        }

           
           
            IF($LastExitCode -ne 0){
                Logging -EventID $ErrorEventID -EventType Error -EventMessage "Windowsサービス [$($TargetOracleService)]起動に失敗しました"
                Finalize $ErrorReturnCode
                }
        }


#DBインスタンス起動状態確認

       . ExecSQL -SQLCommand $DBStatus -SQLName 'DB Status Check' -SQLLogPath $SQLLogPath >$Null



             IF ($LastExitCode -ne 0){

                Logging -EventID $InfoEventID -EventType Information -EventMessage "DB Status Checkに失敗しました"

#        Finalize $ErrorReturnCode
               
                }else{
                Logging -EventID $SuccessEventID -EventType Success -EventMessage "DB Status Checkに成功しました"
                }

      

        IF($SQLLog -match 'OPEN'){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle [$($TargetOracleService)]は既に起動しています"
       
            }else{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle [$($TargetOracleService)]は起動していません"       
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle [$($TargetOracleService)]を起動します"
            ExecSQL -SQLCommand $DBStart -SQLName 'DB Instance Start' -SQLLogPath $SQLLogPath > $Null
            }



#BackUp/Normal Modeどちらかを確認

    Logging -EventID $InfoEventID -EventType Information -EventMessage "Check Back Up Mode"

. CheckOracleBackUpMode > $Null

      IF ($LastExitCode -ne 0){

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Check Back Up Modeに失敗しました"

        Finalize $ErrorReturnCode
        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Check Back Up Modeに成功しました"
        }



 IF(-NOT($BackUpModeFlag) -and ($NormalModeFlag)){

    Logging -EventID $InfoEventID -EventType Information -EventMessage "既に通常モードです"
    }

 IF(-NOT (($BackUpModeFlag) -xor ($NormalModeFlag))){

    ogging -EventID $ErrorEventID -EventType Error -EventMessage "状態が不明です"
    $ErrorCount ++


    }elseif(($BackUpModeFlag) -and (-NOT($NormalModeFlag))){


        Logging -EventID $InfoEventID -EventType Information -EventMessage "バックアップモードです。通常モードへ切替ます"


      . ExecSQL -SQLCommand $DBBackUpModeOff -SQLName "Change to Normal Mode" -SQLLogPath $SQLLogPath > $Null

        IF ($LastExitCode -ne 0){

            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Change to Normal Modeに失敗しました"

            $ErrorCount ++

        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Change to Normal Modeに成功しました"
        }


 }


#コントロールファイル書き出し

. ExecSQL -SQLCommand $DBExportControlFile -SQLName 'DBExportControlFile'  -SQLLogPath $SQLLogPath > $Null


      IF ($LastExitCode -ne 0){

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "DBExportControlFileに失敗しました"

        $WarningCount ++

        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "DBExportControlFileに成功しました"
        }


#Redo Log 強制書き出し



. ExecSQL -SQLCommand $ExportRedoLog  -SQLName 'ExportRedoLog'  -SQLLogPath $SQLLogPath > $Null


      IF ($LastExitCode -ne 0){

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "ExportRedoLogに失敗しました"

        $WarningCount ++

        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "ExportRedoLogに成功しました"
        }





Finalize $NormalReturnCode
