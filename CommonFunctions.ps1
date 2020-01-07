#Requires -Version 3.0



#ログ等の変数を一括設定したい場合は以下を利用して下さい。
#
#各プログラムのParam変数設定、コマンドの引数、CommonFunctions.ps1の変数設定
#上記の順序で、後者の設定が優先されます。
#
#$LogPath等はこちらで設定する方が楽かも
#
#入力値は極力validationしていますが、Paramセクションで明示的に指定する場合はvalidationされません
#誤った値を指定しないように留意してください


#[boolean]$Log2EventLog = $TRUE,
#[Switch]$NoLog2EventLog,
#[String]$ProviderName = "Infra",
#[String][ValidateSet("Application")]$EventLogLogName = 'Application',

#[boolean]$Log2Console = $TRUE,
#[Switch]$NoLog2Console,
#[boolean]$Log2File = $False,
#[Switch]$NoLog2File,
#[String][ValidatePattern('^(\.+\\|[C-Z]:\\).*')]$LogPath ,
#[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss",

#[int][ValidateRange(0,2147483647)]$NormalReturnCode = 0,
#[int][ValidateRange(0,2147483647)]$WarningReturnCode = 1,
#[int][ValidateRange(0,2147483647)]$ErrorReturnCode = 8,
#[int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16,

#[int][ValidateRange(1,65535)]$InfoEventID = 1,
#[int][ValidateRange(1,65535)]$WarningEventID = 10,
#[int][ValidateRange(1,65535)]$SuccessEventID = 73,
#[int][ValidateRange(1,65535)]$InternalErrorEventID = 99,
#[int][ValidateRange(1,65535)]$ErrorEventID = 100,

#[Switch]$ErrorAsWarning,
#[Switch]$WarningAsNormal,

#[Regex]$ExecutableUser ='.*'




#ログ出力

function Logging{

    Param(
    [parameter(mandatory=$true)][ValidateRange(1,65535)][int]$EventID,
    [parameter(mandatory=$true)][String][ValidateSet("Information", "Warning", "Error" ,"Success")]$EventType,
    [parameter(mandatory=$true)][String]$EventMessage
    )


    IF($Log2EventLog){

    Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType $EventType -EventId $EventID -Message "[$($SHELLNAME)] $($EventMessage)"
    }


    IF($Log2Console){

    $ConsoleWrite = $EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
    Write-Host $ConsoleWrite
    }   


    IF($Log2File){
    $LogFormattedDate = (Get-Date).ToString($LogDateFormat)
    $LogWrite = $LogFormattedDate+" "+$SHELLNAME+" "+$EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
    Write-Output $LogWrite | Out-File -FilePath $LogPath -Append
    }   

}


#イベントソース未設定時の処理
#この確認が終わるまではFunction Loggingのログ出力可能か確定しないので、異常時はExitで抜ける

function CheckEventLogSource{

    Try{

           
        If ([System.Diagnostics.Eventlog]::SourceExists($ProviderName) -eq $false){
        #新規イベントソースを設定

           
            New-EventLog -LogName $EventLogLogName -Source $ProviderName  -ErrorAction Stop
            Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Information -EventId $InfoEventID -Message "[$($SHELLNAME)] 新規イベントソース[$(ProviderName)]を[$($EventLogLogName)]へ登録しました"
            }
       
    }
    Catch [Exception]{
    Write-Output "EventLogにSouce $($ProviderName)が存在しないため、新規作成を試みましたが失敗しました。新規Sourceの作成は実行ユーザが管理者権限を保有している必要があります。一度Powershellを管理者権限で開いて手動でこのプログラムを実行してください。"
    Write-Output "起動時エラーメッセージ : $Error[0]"
    Exit $ErrorReturnCode
    }
       
}


#ログファイル出力先確認
#この確認が終わるまではFunction Loggingのログ出力可能か確定しないので、異常時はExitで抜ける

function CheckLogFilePath{




    IF (-NOT($Log2File)){
        Return
        }


    IF(-NOT(Test-Path -Path $LogPath -IsValid)){

       Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID -Message "[$($LogPath)]は有効なパス表記ではありません。NTFSに使用できない文字列が含まれてないか等を確認して下さい"
       Write-Output  "[$($LogPath)]は有効なパス表記ではありません。NTFSに使用できない文字列が含まれてないか等を確認して下さい"
       Exit $ErrorReturnCode  

    }



        IF ([String]::IsNullOrEmpty($LogPath)){
           
            Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID -Message "[$($SHELLNAME)] -Log2File[$($Log2File)]を指定した時、ログ出力先 -LogPathの指定が必要です"
           
            Write-Output "-Log2File[$($Log2File)]を指定した時、ログ出力先 -LogPathの指定が必要です"
           
            Exit $ErrorReturnCode
            }




                #ログ出力先指定が相対パス&カレントパスがスクリプト配置先ではない可能性を考慮して、相対パス指定はスクリプト配置先を基準にしたパスに変換する

    Switch -Regex ($LogPath){

        "^\.+\\.*"{
       
            $Script:LogPath =  Join-Path ${THIS_PATH} $LogPath

            }

        "^[c-zC-Z]:\\.*"{
       
            }
      
        Default{
       
            Write-Output "-LogPath [-LogPath $($LogPath)]は相対パス、絶対パス表記ではありません"
            Exit $ErrorReturnCode
            }
    }


        IF(Test-Path -Path $LogPath -PathType Container){
                   Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID -Message "[$($SHELLNAME)] ログ出力先ファイル指定先に同一名称のフォルダが存在しています。"      
                   Write-Output "[$($SHELLNAME)] ログ出力先ファイル指定先に同一名称のフォルダが存在しています。"      
                  
                   Exit $ErrorReturnCode

                    #この時点で$LogPathには同名フォルダは存在しないので、同名ファイルが存在するかを確認する
                    }elseif(-NOT(TEST-Path -Path $LogPath -PathType Leaf) ){
                   
                        Try{
                            New-Item $LogPath -ItemType File > $NULL  -ErrorAction Stop

                            #新規作成に成功すれば、Loggingが使える
                            Logging -EventID $InfoEventID -EventType Information -EventMessage "[$($SHELLNAME)] ログ出力先ファイルが存在しません。$($LogPath)を新規作成します"
                        }
       
                        catch [Exception]{
                        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID -Message "[$($SHELLNAME)] ログ出力先ファイル$($LogPath)の作成に失敗しました。作成先フォルダが存在しないか、権限が不足しています"
                        Write-Output "ログ出力先ファイル$($LogPath)の作成に失敗しました。作成先フォルダが存在しないか、権限が不足しています"
                        Write-Output "起動時エラーメッセージ : $Error[0]"
                        Exit $ErrorReturnCode
                        }
                    }
   
}




#ReturnCode大小関係確認
#$ErrorReturnCode = 0設定等を考慮して異常時はExit 1で抜ける

function CheckReturnCode {

    IF(-NOT(($InternalErrorReturnCode -ge $WarningReturnCode) -AND ($ErrorReturnCode -ge $WarningReturnCode) -AND ($WarningReturnCode -ge $NormalReturnCode))){

    Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID "ReturnCodeの大小関係が正しく設定されていません。"
    Write-Output "ReturnCodeの大小関係が正しく設定されていません。"
    Exit 1
    }
}




function TryAction {
    
    Param(

    [parameter(mandatory=$true)][String][ValidateSet("Move", "Copy", "Delete" , "AddTimeStamp" , "NullClear" ,"Compress" , "CompressAndAddTimeStamp" , "MakeNewFolder" ,"MakeNewFileWithValue")]$ActionType,
    [parameter(mandatory=$true)][String]$ActionFrom,
    [String]$ActionTo,
    [parameter(mandatory=$true)][String]$ActionError,
    [String]$FileValue,
    [Switch]$NoContinueOverRide

    )

    IF (-NOT($ActionType -match "^(Delete|NullClear|MakeNewFolder)$" ) -and ($Null -eq $ActionTo)){

    Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Function TryAction内部エラー。${ActionType}では$'$ActionTo'の指定が必要です"
    Finalize $InternalErrorReturnCode
    }

      
    Try{
  

       Switch -Regex ($ActionType){



        '^(Copy|AddTimeStamp)$'
            {
            Copy-Item $ActionFrom $ActionTo -Force > $Null -ErrorAction Stop
            }

        '^Move$'
            {
            Move-Item $ActionFrom $ActionTo -Force > $Null -ErrorAction Stop
            }

        '^Delete$'
            {
            Remove-Item $ActionFrom -Force > $Null -ErrorAction Stop
            }
                       
        '^NullClear$'
            {
            Clear-Content $ActionFrom -Force > $Null -ErrorAction Stop
            }

        '^(Compress|CompressAndAddTimeStamp)$'
            {
            Compress-Archive -Path $ActionFrom -DestinationPath $ActionTo -Force > $Null  -ErrorAction Stop
            }                  
                                       
        '^MakeNewFolder$'
            {
            New-Item -ItemType Directory -Path $ActionFrom > $Null  -ErrorAction Stop
            }

        '^MakeNewFileWithValue$'
            {
            New-Item -ItemType File -Path $ActionFrom -Value $FileValue > $Null -ErrorAction Stop
            }
                                           
        Default                                 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Function TryAction内部エラー。判定式にbugがあります"
            Finalize $InternalErrorReturnCode
            }
      }       
   
   
   
    }   
    catch [Exception]{
       
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "${ActionError}の[${ActionType}]に失敗しました"
        $ErrorDetail = $Error[0] | Out-String
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "起動時エラーメッセージ : $ErrorDetail"
        $Script:ErrorFlag = $TRUE

        If(($Continue) -AND (-NOT($NoContinueOverRide))){
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]のため処理を継続します。"
            $Script:WarningFlag = $TRUE
            $Script:ContinueFlag = $TRUE

            #Continueの場合、処理継続はするが、処理は失敗しているのでFALSEを返す
            Return $Flase
            }

        #Continueしない場合は終了処理へ進む
        Finalize $ErrorReturnCode   
    }


   
    Logging -EventID $SuccessEventID -EventType Success -EventMessage "${ActionError}の[${ActionType}]に成功しました"
   

}




#相対パスから絶対パスへ変換

Function ConvertToAbsolutePath {

Param(
[parameter(mandatory=$true)][String]$CheckPath,
[parameter(mandatory=$true)][String]$ObjectName

)

    IF(Test-Path -Path $CheckPath -IsValid){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]は有効なパス表記です"
   
    }else{
       Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)]は有効なパス表記ではありません。NTFSに使用できない文字列が含まれてないか等を確認して下さい"
       Finalize $ErrorReturnCode  

    }


    Switch -Regex ($CheckPath){

    "^\.+\\.*"{
       
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]は相対パス表記です"

        Logging -EventID $InfoEventID -EventType Information -EventMessage "スクリプトが配置されているフォルダ[${THIS_PATH}]、[$($CheckPath)]と結合したパスに変換します"

        Return Join-Path ${THIS_PATH} $CheckPath

        }

        "^[c-zC-Z]:\\.*"{

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]は絶対パス表記です"

        Return $CheckPath

        }
       Default{
      
       Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)]は相対パス、絶対パス表記ではありません"
       Finalize $ErrorReturnCode
       }
    }

}





#終了

function EndingProcess{

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

    IF(($ErrorCount -gt 0) -OR ($ReturnCode -ge $ErrorReturnCode)){

        IF($ErrorAsWarning){
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "異常終了が発生しましたが、-ErrorAsWarning[$($ErrorAsWarning)]が指定されているため終了コードは[$($WarningReturnCode)]です"  
            $ReturnCode = $WarningReturnCode
           
            }else{
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "異常終了が発生したため終了コードは[$($ErrorReturnCode)]です"
            $ReturnCode = $ErrorReturnCode
            }

        }elseIF(($WarningCount -gt 0) -OR ($ReturnCode -ge $WarningReturnCode)){

            IF($WarningAsNormal){
                Logging -EventID $InfoEventID -EventType Information -EventMessage "警告終了が発生しましたが、-WarningAsNormal[$($WarningAsNormal)]が指定されているため終了コードは[$($NormalReturnCode)]です" 
                $ReturnCode = $NormalReturnCode
           
                }else{
                Logging -EventID $WarningEventID -EventType Warning -EventMessage "警告終了が発生したため終了コードは[$($WarningReturnCode)]です"
                $ReturnCode = $WarningReturnCode
                }
        
        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "正常終了しました。終了コードは[$($NormalReturnCode)]です"
        $ReturnCode = $NormalReturnCode
               
        }

    Logging -EventID $InfoEventID -EventType Information -EventMessage "${SHELLNAME} Version $($Version)を終了します"

Exit $ReturnCode

}


#サービス存在確認


function CheckServiceExist {

Param(
[parameter(mandatory=$true)][String]$ServiceName,
[Switch]$NoMessage
)


# サービス状態取得

    $Service = Get-Service | Where-Object {$_.Name -eq $serviceName}


    IF($Service.Status -Match "^$"){
        IF(-NOT($NoMessage)){Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($ServiceName)]が存在しません"}
        Return $False

        }else{

        IF(-NOT($NoMessage)){Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($ServiceName)]は存在します"}
        Return $TRUE
        }
}


#サービス状態確認


function CheckServiceStatus {

Param(
[parameter(mandatory=$true)][String]$ServiceName,
[String][ValidateSet("Running", "Stopped")]$Health = 'Running',
[int][ValidateRange(0,2147483647)]$Span = 3,
[int][ValidateRange(0,2147483647)]$UpTo = 10
)


# カウント用変数初期化
$Counter = 0


    # 無限ループ
    While ($true) {

      # チェック回数カウントアップ
      $Counter++

      # サービス存在確認
      IF(-NOT(CheckServiceExist $ServiceName -NoMessage)){
      Return $False
      }

      $Service = Get-Service | Where-Object {$_.Name -eq $ServiceName}

      # サービス状態判定
      IF ($Service.Status -eq $Health) {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($ServiceName)]は存在します。Status[$($Service.Status)]"
        Return $true
       
        }elseif ($Counter -eq $Upto){

            IF(($SPAN -eq 0) -AND ($UpTo -eq 1)){
                Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($ServiceName)]は存在します。Status[$($Service.Status)]"
                Return $False
                }else{

                Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($ServiceName)]は存在します。指定期間、回数が経過しましたがStatus[$($Health)]には遷移しませんでした。"
                return $false
                }
        }
     

      # 期待値でなく、チェック回数の上限に達していない場合は、指定間隔(秒)待機

      Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($ServiceName)]は存在します。Status[$($Health)]ではありません。$($SPAN)秒待機します。"
      sleep $Span

      # 無限ループに戻る

    }

}



function CheckNullOrEmpty {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNullOrEmptyFinalize,
[Switch]$NoMessage

)


   If (-NOT([String]::IsNullOrEmpty($CheckPath))){
                    Return $False
                    }else{

                    IF($IfNullOrEmptyFinalize){
           
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) の指定は必須です"
                    Finalize $ErrorReturnCode
                    }
               
              }

              Return $true
       
}


function CheckContainer {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNoExistFinalize

)

            If (Test-Path -Path $CheckPath -PathType Container){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)]は存在します"
            Return $true

            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)]は存在しません"
                IF($IfNoExistFinalize){
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) の指定は必須です"
                    Finalize $ErrorReturnCode
                    }else{
                    Return $false
                    }
        }
}


function CheckLeaf {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNoExistFinalize

)

            If (Test-Path -Path $CheckPath -PathType Leaf){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)]は存在します"
            Return $true

            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)]は存在しません"
                IF($IfNoExistFinalize){
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) の指定は必須です"
                    Finalize $ErrorReturnCode
                    }else{
                    Return $false
                    }
        }
}



function CheckPrivileges {

Param(
[parameter(mandatory=$true)][String]$CheckPath
)

    $FormattedDate = (Get-Date).ToString($TimeStampFormat)

    $TempItemPath = Join-Path $CheckPath ($FormattedDate+".tmp")

        Try{
            New-Item -Path $TempItemPath -ErrorAction Stop -Force >$Null
            Remove-Item -Path $TempItemPath -ErrorAction Stop -Force >$Null
            }

        catch [Exception]{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($CheckPath)に必要な権限が付与されていません"
        Return $false
        }



}


function CheckExecUser {

    $Script:ScriptExecUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    Logging -EventID $InfoEventID -EventType Information -EventMessage "実行ユーザは$($ScriptExecUser.Name)です"

    IF(-NOT($ScriptExecUser.Name -match $ExecutableUser)){
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "実行許可されていないユーザで起動しています。"
                Finalize $ErrorReturnCode
                }

}



function PreInitialize {

$error.clear()


#イベントソース未設定時の処理

. CheckEventLogSource


#ログファイル出力先確認

. CheckLogFilePath


#ReturnCode確認

. CheckReturnCode

#ここはfunctionなので変数はfunction内でのものとなる。スクリプト全体に反映するにはスコープを明示的に$Script:変数名とする

#ログ抑止フラグ処理

IF($NoLog2EventLog){[boolean]$Script:Log2EventLog = $False}
IF($NoLog2Console){[boolean]$Script:Log2Console = $False}
IF($NoLog2File){[boolean]$Script:Log2File = $False}


Logging -EventID $InfoEventID -EventType Information -EventMessage "${SHELLNAME} Version $($Version)を起動します"

Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータの確認を開始します"

. CheckExecUser

}


function ExecSQL {

Param(
[String]$SQLLogPath,
[parameter(mandatory=$true)][String]$SQLName,
[parameter(mandatory=$true)][String]$SQLCommand,

[Switch]$IfErrorFinalize

)

    $ScriptExecUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    $ScriptExecUser = $ScriptExecUser.Name

    $LogFormattedDate = (Get-Date).ToString($LogDateFormat)

$LogWrite = @"


----------------------------
DATE: $LogFormattedDate
SHELL: $SHELLNAME
SQL: $SQLName

OS User: $ScriptExecUser

SQL Exec User: $ExecUser
Password Authrization [$PasswordAuthorization]

"@

$SQLLog = $Null

Write-Output $LogWrite | Out-File -FilePath $SQLLogPath -Append

Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization){

    $SQLLog = $SQLCommand | SQLPlus $ExecUser/$ExecUserPassword@OracleSerivce as sysdba

    }else{
    $SQLLog = $SQLCommand | SQLPlus / as sysdba
    }

Write-Output $SQLLog | Out-File -FilePath $SQLLogPath -Append


Pop-Location


    IF ($LastExitCode -eq 0){

        Logging -EventID $SuccessEventID -EventType Success -EventMessage "SQL Command[$($SQLName)]実行に成功しました"
        Return $True

        }else{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "SQL Command[$($SQLName)]実行に失敗しました"
   
            IF($IfErrorFinalize){
            Finalize $ErrorReturnCode
            }
   
        Return $False
    }



}




function CheckOracleBackUpMode {


    Logging -EventID $InfoEventID -EventType Information -EventMessage "BackUpStatusを取得して、BackUp/Normalどちらのモードか判定します。Activeの行はBackUpモードです"
  . ExecSQL -SQLCommand $DBCheckBackUpMode -SQLName "DBCheckBackUpMode" -SQLLogPath $SQLLogPath > $Null

   
    #文字列配列に変換する
    $SQLLog = $SQLLog -replace "`r",""
    $SQLLog = $SQLLog -split "`n"

    $NormalModeCount = 0
    $BackUpModeCount = 0


    $i=1

    foreach ($Line in $SQLLog){

            IF ($Line -match 'NOT ACTIVE'){
            $NormalModeCount ++
            Logging -EventID $InfoEventID -EventType Information -EventMessage "[$Line][$i]行目 Normal Mode"
 
 
            }elseIF ($Line -match 'ACTIVE'){
            $BackUpModeCount ++
            Logging -EventID $InfoEventID -EventType Information -EventMessage "[$Line][$i]行目 BackUp Mode"
            }
 
    $i ++
    }


    Logging -EventID $InfoEventID -EventType Information -EventMessage "現在のOracle Databaseの動作モード...."

    IF (($BackUpModeCount -eq 0) -and ($NormalModeCount -gt 0)) {
 
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Normal Mode"
        $Script:NormalModeFlag = $TRUE
        $Script:BackUpModeFlag = $False
        Return

    }elseif(($BackUpModeCount -gt 0) -and ($NormalModeCount -eq 0)){
   
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Back Up Mode"
        $Script:NormalModeFlag = $False
        $Script:BackUpModeFlag = $TRUE
        Return


    }else{

        Logging -EventID $InfoEventID -EventType Information -EventMessage "??? Mode ???"
        $Script:NormalModeFlag = $False
        $Script:BackUpModeFlag = $False
        Return
    }


}



#https://github.com/mnaoumov/Invoke-NativeApplication

function Invoke-NativeApplication
{
    param
    (
        [ScriptBlock] $ScriptBlock,
        [int[]] $AllowedExitCodes = @(0),
        [switch] $IgnoreExitCode
    )

    $backupErrorActionPreference = $ErrorActionPreference

    $ErrorActionPreference = "Continue"
    try
    {
        if (Test-CalledFromPrompt)
        {
            $wrapperScriptBlock = { & $ScriptBlock }
        }
        else
        {
            $wrapperScriptBlock = { & $ScriptBlock 2>&1 }
        }

        & $wrapperScriptBlock | ForEach-Object -Process `
            {
                $isError = $_ -is [System.Management.Automation.ErrorRecord]
                "$_" | Add-Member -Name IsError -MemberType NoteProperty -Value $isError -PassThru
            }
        if ((-not $IgnoreExitCode) -and (Test-Path -Path Variable:LASTEXITCODE) -and ($AllowedExitCodes -notcontains $LASTEXITCODE))
        {
            throw "Execution failed with exit code $LASTEXITCODE"
        }
    }
    finally
    {
        $ErrorActionPreference = $backupErrorActionPreference
    }
}

function Invoke-NativeApplicationSafe
{
    param
    (
        [ScriptBlock] $ScriptBlock
    )

    Invoke-NativeApplication -ScriptBlock $ScriptBlock -IgnoreExitCode | `
        Where-Object -FilterScript { -not $_.IsError }
}

function Test-CalledFromPrompt
{
    (Get-PSCallStack)[-2].Command -eq "prompt"
}

Set-Alias -Name exec -Value Invoke-NativeApplication
Set-Alias -Name safeexec -Value Invoke-NativeApplicationSafe
