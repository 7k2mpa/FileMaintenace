#Requires -Version 3.0

Param(

[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',
[String]$OracleService = $Env:ORACLE_SID,
#[String]$OracleService = 'SSDBT',

[String]$SQLLogPath = '.\SC_Logs\SQL.log',
[String]$BackUpFlagPath = '.\Lock\BkUpDB.flg',

[String][String]$SQLCommandsPath = '.\SQL\SQLs.ps1',
[Switch]$PasswordAuthorization ,

[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[String]$StartServicePath = '.\StartService.ps1' ,

[int][ValidateRange(1,65535)]$RetrySpanSec = 20,
[int][ValidateRange(1,65535)]$RetryTimes = 15,

[String]$TimeStampFormat = "_yyyyMMdd_HHmmss",

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Unicode', #Default指定はShift-Jis



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

    $OracleHomeBinPath = ConvertToAbsolutePath -CheckPath $OracleHomeBinPath -ObjectName  '-OracleHomeBinPath'

    CheckContainer -CheckPath $OracleHomeBinPath -ObjectName '-OracleHomeBinPath' -IfNoExistFinalize > $NULL


#SQLLogファイルの指定、存在、書き込み権限確認


        $SQLLogPath = ConvertToAbsolutePath -CheckPath $SQLLogPath -ObjectName '-SQLLogPath'

        Split-Path $SQLLogPath | ForEach-Object {CheckContainer -CheckPath $_ -ObjectName '-SQLLogPathのParentフォルダ' -IfNoExistFinalize > $NULL}

    If(Test-Path -LiteralPath $SQLLogPath -PathType Leaf){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "-SQLLogPathの書込権限を確認します"
        $LogWrite = $LogFormattedDate+" "+$SHELLNAME+" Write Permission Check"
        

        Try{
            Write-Output $LogWrite | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode
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
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-SQLCommandsPathに指定されたSQL群のLoadに成功しました"
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

${Version} = '0.9.18'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize



Push-Location $OracleHomeBinPath


#リスナー起動状態を確認、必要に応じて起動

$ReturnMessage = lsnrctl status  2>&1

[String]$ListenerStatus = $ReturnMessage

Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode

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

        Write-Output $ReturnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode
    
 

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


#DBインスタンス状態確認

      $ExecSQLReturnCode =  . ExecSQL -SQLCommand $DBStatus -SQLName 'DB Status Check' -SQLLogPath $SQLLogPath


             IF (($ExecSQLReturnCode) -OR ( $SQLLog -match 'ORA-01034')){

                Logging -EventID $SuccessEventID -EventType Success -EventMessage "DB Status Checkに成功しました"
                
                }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage "DB Status Checkに失敗しました"
                }


        IF($SQLLog -match 'OPEN'){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle SID[$($OracleService)]は既にOPENしています"
         
  
        }elseIF($SQLLog -match '(STARTED|MOUNTED)'){
            
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Oracle SID[$($OracleService)]はMOUNTもしくはNOMOUNT状態です。明示的にSHUTDOWN後STARTUPして下さい"
            Finalize $ErrorReturnCode

        }else{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle SID[$($OracleService)]はOPENしていません"        
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle SID[$($OracleService)]をOPENします"


            $ExecSQLReturnCode = . ExecSQL -SQLCommand $DBStart -SQLName 'DB Instance OPEN' -SQLLogPath $SQLLogPath

                IF ($ExecSQLReturnCode){

                    Logging -EventID $SuccessEventID -EventType Success -EventMessage "DB Instance OPENに成功しました"
                
                    }else{
                    Logging -EventID $InfoEventID -EventType Information -EventMessage "DB Instance OPENに失敗しました"
                    $ErrorCount ++
                    }
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

    Logging -EventID $ErrorEventID -EventType Error -EventMessage "状態が不明です"
    $ErrorCount ++
 
 
    }elseif(($BackUpModeFlag) -and (-NOT($NormalModeFlag))){
 

        Logging -EventID $InfoEventID -EventType Information -EventMessage "バックアップモードです。通常モードへ切替ます"


      $ExecSQLReturnCode = . ExecSQL -SQLCommand $DBBackUpModeOff -SQLName "Change to Normal Mode" -SQLLogPath $SQLLogPath

        IF ($ExecSQLReturnCode){

            Logging -EventID $SuccessEventID -EventType Success -EventMessage "Change to Normal Modeに成功しました"

	        

        }else{
        
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Change to Normal Modeに失敗しました"
        $ErrorCount ++
        }


 }


#コントロールファイル書き出し

    $ExecSQLReturnCode = . ExecSQL -SQLCommand $DBExportControlFile -SQLName 'DBExportControlFile'  -SQLLogPath $SQLLogPath


      IF ($ExecSQLReturnCode){

        Logging -EventID $SuccessEventID -EventType Success -EventMessage "DBExportControlFileに成功しました"

	    

        }else{ 
        
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "DBExportControlFileに失敗しました"
        $WarningCount ++
        }


#Redo Log 強制書き出し



    $ExecSQLReturnCode = . ExecSQL -SQLCommand $ExportRedoLog  -SQLName 'ExportRedoLog'  -SQLLogPath $SQLLogPath 


      IF ($ExecSQLReturnCode){

        Logging -EventID $SuccessEventID -EventType Success -EventMessage "ExportRedoLogに成功しました"
	    

        }else{
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "ExportRedoLogに失敗しました"
        $WarningCount ++
        }





Finalize $NormalReturnCode
