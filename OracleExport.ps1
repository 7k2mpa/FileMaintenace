#Requires -Version 3.0

Param(

[String]$ExecUser = 'system',
[String]$ExecUserPassword = 'secmanager',
[parameter(mandatory=$true , HelpMessage = 'Oracle(ex. MCDB) 全てのHelpはGet-Help FileMaintenance.ps1')][String]$OracleService ,
#[String]$OracleService = 'MCF',

[parameter(mandatory=$true)][String]$Schema  ,
#[parameter(mandatory=$true)][String]$Schema = 'SECMCF' ,

[String]$HostName = $Env:COMPUTERNAME,

[String]$DumpDirectoryObject='TEMP_PUMP_DIR' ,

[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[Switch]$PasswordAuthorization ,

[String][ValidatePattern('^(?!.*(\\|\/|:|\?|`"|<|>|\|)).*$')]$TimeStampFormat = '_yyyyMMdd_HHmmss',




[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[C-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\|)).*$')]$LogPath ,
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

#指定フォルダの有無を確認

   $OracleHomeBinPath = ConvertToAbsolutePath -CheckPath $OracleHomeBinPath -ObjectName  '-OracleHomeBinPath'

#   CheckNullOrEmpty -CheckPath $OracleHomeBinPath -ObjectName '-OracleHomeBinPath' -IfNullOrEmptyFinalize > $NULL

   CheckContainer -CheckPath $OracleHomeBinPath -ObjectName '-OracleHomeBinPath' -IfNoExistFinalize > $NULL



#    $CheckOracleService = "CDPSvc"
#debug用のstoppedになっているサービス

    $TargetOracleService = "OracleService"+$OracleService

    $ServiceStatus = ServiceStatusCheck -ServiceName $TargetOracleService -Health Running


    IF (-NOT($ServiceStatus)){


        Logging -EventType Error -EventID $ErrorEventID -EventMessage "対象のOracleServiceが起動していません。"
        Finalize $ErrorReturnCode
        }else{
        Logging -EventID $InfoEventID -EventType Information -EventMessage "対象のOracle Serviceは正常に起動しています"
        }
       


#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

Logging -EventID $InfoEventID -EventType Information -EventMessage "DB Dumpを出力します"

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


$FormattedDate = (Get-Date).ToString($TimeStampFormat)

${Version} = '0.9.13'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

$DumpFile = $HostName+"_"+$Schema+"_PUMP"+$FormattedDate+".dmp"
$LogFile = $HostName+"_"+$Schema+"_PUMP"+$FormattedDate+".log"

Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization){

    expdp directory=$DumpDirectoryObject schemas=$Schema dumpfile=$DumpFile logfile=$LogFile reuse_dumpfiles=y 2>&1 >$Null
   
    }else{
    expdp $ExecUser/$ExecUserPassword@$OracleSerivce directory=$DumpDirectoryObject schemas=$Schema dumpfile=$DumpFile logfile=$LogFile reuse_dumpfiles=y 2>&1 >$Null
    }

IF ($LastExitCode -eq 0){

Logging -EventID $SuccessEventID -EventType Success -EventMessage "Oracle Data Pumpに成功しました"
Finalize $NormalReturnCode

      } else {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Oracle Data Pumpに失敗しました"
        Finalize $ErrorReturnCode
        }
