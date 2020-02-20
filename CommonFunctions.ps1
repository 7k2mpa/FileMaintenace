#Requires -Version 5.0
#If you wolud NOT use '-PreAction compress or archive' in FileMaintenance.ps1 , you could change '-Version 5.0' to '-Version 3.0'

<#

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

$Script:CommonFunctionsVersion = '20200130_1050'

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
#[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis

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


    IF(($Log2EventLog -OR $ForceConsoleEventLog) -and -NOT($ForceConsole) ){

        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType $EventType -EventId $EventID -Message "[$($SHELLNAME)] $($EventMessage)"
        }


    IF($Log2Console -or $ForceConsole -or $ForceConsoleEventLog){

        $ConsoleWrite = $EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
        Write-Host $ConsoleWrite
        }   


    IF($Log2File -and -NOT($ForceConsole -or $ForceConsoleEventLog )){

        $LogFormattedDate = (Get-Date).ToString($LogDateFormat)
        $LogWrite = $LogFormattedDate+" "+$SHELLNAME+" "+$EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
        Write-Output $LogWrite | Out-File -FilePath $LogPath -Append -Encoding $LogFileEncode
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



#イベントソース未設定時の処理
#この確認が終わるまではログ出力可能か確定しないのでコンソール出力を強制

function CheckEventLogSource{

    IF (-NOT($Log2EventLog)){
        Return
        }


$ForceConsole = $TRUE

    TRY{

        If (-NOT([System.Diagnostics.Eventlog]::SourceExists($ProviderName) ) ){
        #新規イベントソースを設定
           
            New-EventLog -LogName $EventLogLogName -Source $ProviderName  -ErrorAction Stop
            $ForceConsoleEventLog = $TRUE    
            Logging -EventID $InfoEventID -EventType Information -EventMessage "新規イベントソース[$($ProviderName)]を[$($EventLogLogName)]へ登録しました"
            }
       
    }
    Catch [Exception]{
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "EventLogにSouce $($ProviderName)が存在しないため、新規作成を試みましたが失敗しました。新規Sourceの作成は実行ユーザが管理者権限を保有している必要があります。一度Powershellを管理者権限で開いて手動でこのプログラムを実行してください。"
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "起動時エラーメッセージ : $Error[0]"
    Exit $ErrorReturnCode
    }

$ForceConsole = $false
$ForceConsoleEventLog = $false

}


#ログファイル出力先確認
#この確認が終わるまではログ出力可能か確定しないのでEventLogとコンソール出力を強制

function CheckLogFilePath{

    IF (-NOT($Log2File)){
        Return
        }

$ForceConsleEventLog = $TRUE    

    $LogPath = ConvertToAbsolutePath -CheckPath $LogPath -ObjectName '-LogPath'

    CheckLogPath -CheckPath $LogPath -ObjectName '-LogPath' > $NULL
    
$ForceConsoleEventLog = $false

}






function TryAction {
    
    Param(

#    [parameter(mandatory=$true)][String]
#    [ValidateSet("Move", "Copy", "Delete" , "AddTimeStamp" , "NullClear" ,"Compress" , "CompressAndAddTimeStamp" `
#     , "MakeNewFolder" ,"MakeNewFileWithValue" , "Rename" , "Archive" , "ArchiveAndAddTimeStamp" `
#     , "7zCompress" , "7zZipCompress" , "7zArchive" , "7zZipArchive")]$ActionType,

    [parameter(mandatory=$true)][String]
    [ValidatePattern("^(Move|Copy|Delete|AddTimeStamp|NullClear|Rename|MakeNew(FileWithValue|Folder)|(7z|7zZip|^)(Compress|Archive)(AndAddTimeStamp|$))$")]$ActionType,

#    [ValidatePattern("^(Move|Copy|Delete|AddTimeStamp|NullClear|Rename|(MakeNew(FileWithValue|Folder))|((7z|7zZip|$)(Compress|Archive)(AndAddTimeStamp|$))$")]$ActionType,

    [parameter(mandatory=$true)][String]$ActionFrom,
    [String]$ActionTo,
    [parameter(mandatory=$true)][String]$ActionError,
    [String]$FileValue,
    [Switch]$NoContinueOverRide

    )

    IF (-NOT($ActionType -match "^(Delete|NullClear|MakeNewFolder|Rename)$" ) -and ($Null -eq $ActionTo)){

        Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Function TryAction内部エラー。${ActionType}では$'$ActionTo'の指定が必要です"
        Finalize $InternalErrorReturnCode
        }


    IF($NoAction){
    
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "-NoActionが指定されているため、${ActionError}の[${ActionType}]は実行しませんでした"
        $Script:NormalFlag = $TRUE

        IF($OverRideFlag){
            $Script:OverRideCount ++
            $Script:InLoopOverRideCount ++
            $Script:OverRideFlag = $False
            }

        Return
        }

      
    Try{
  

       Switch -Regex ($ActionType){



        '^(Copy|AddTimeStamp)$'
            {
            Copy-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $Null -ErrorAction Stop
            }

        '^(Move|Rename)$'
            {
            Move-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $Null -ErrorAction Stop
            }

        '^Delete$'
            {
            Remove-Item -LiteralPath $ActionFrom -Force > $Null -ErrorAction Stop
            }
                       
        '^NullClear$'
            {
            Clear-Content -LiteralPath $ActionFrom -Force > $Null -ErrorAction Stop
            }

        '^(Compress|CompressAndAddTimeStamp)$'
            {

           $ActionTo = $ActionTo -replace "\[" , "````["

#            $ActionTo = "``"+$ActionTo

#          echo $ActionTo
#           exit
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Force > $Null  -ErrorAction Stop
            }                  
                                       
        '^MakeNewFolder$'
            {
            New-Item -ItemType Directory -Path $ActionFrom > $Null  -ErrorAction Stop
            }

        '^MakeNewFileWithValue$'
            {
            New-Item -ItemType File -Path $ActionFrom -Value $FileValue > $Null -ErrorAction Stop
            }

        '^(Archive|ArchiveAndAddTimeStamp)$'
            {
            $ActionTo = $ActionTo -replace "\[" , "````["

#                        echo $ActionTo
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Update > $Null  -ErrorAction Stop
            }                  


        '^((7z|7zZip)(Archive|Compress))$'
            {

            Push-Location -LiteralPath $7zFolderPath

            IF($ActionType -match '7zZip'){
                
                $7zType = 'zip'
                
                }else{
                $7zType = '7z'
                }

            Switch -Regex ($ActionType){
            
                'Compress'{
                    [String]$ErrorDetail = .\7z a $ActionTo $ActionFrom -t"$7zType" 2>&1 
                    }

                'Archive'{
                    [String]$ErrorDetail = .\7z u $ActionTo $ActionFrom -t"$7zType" 2>&1  
                    }
            
                Default{
                    Pop-Location
                    Throw "internal error in 7Zip Section"
                    }            
                }

#            IF($ActionType -match 'Compress'){

#                [String]$ErrorDetail = .\7z a $ActionTo $ActionFrom -t"$7zType" 2>&1 
#                }elseIF($ActionType -match 'Archive'){
            
#            [String]$ErrorDetail = .\7z u $ActionTo $ActionFrom -t"$7zType" 2>&1             
#            }else{Throw "internal error in 7ZipSection"}


            Pop-Location
            $ProcessError = $TRUE
            IF($LASTEXITCODE -ne 0){

                Throw "error in 7zip"            
                }
            }

#        '^(7zCompress|7zZipCompress)$'
#            {
            
#            echo '7zip'

#            Push-Location -LiteralPath $7zFolderPath
 #           .\7z a $ActionTo $ActionFrom | Tee-Object -Variable ProcessError

#            IF($ActionType -match '7zZip'){$7zType = 'zip'}else{$7zType = '7z'}

#             echo $7zType
#             [String]$ErrorDetail = .\7z a $ActionTo $ActionFrom -t"$7zType" 2>&1 
#            echo $ErrorDetail
#            $ErrorDetail = .\7z a $ActionToo $ActionFromm | ForEach-Object {Write-Output $_}
#            $ErrorDetail = .\7z a $ActionToo $ActionFromm

#            Pop-Location
#            $ProcessError = $TRUE
#            IF($LASTEXITCODE -ne 0){
#            Throw "error in 7zip"
            
#            }


 #           }
                                           
        Default                                 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Function TryAction内部エラー。判定式にbugがあります"
            Finalize $InternalErrorReturnCode
            }
      }       
   
   
   
    }   
    catch [Exception]{
       
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "${ActionError}の[${ActionType}]に失敗しました"
        IF(-NOT($ProcessError)){
            $ErrorDetail = $Error[0] | Out-String
            }
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "起動時エラーメッセージ : $ErrorDetail"
        $Script:ErrorFlag = $TRUE

        If(($Continue) -AND (-NOT($NoContinueOverRide))){
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]のため処理を継続します。"
            $Script:WarningFlag = $TRUE
            $Script:ContinueFlag = $TRUE
            Return
            }

        #Continueしない場合は終了処理へ進む
        IF($ForceEndLoop){
            $Script:ErrorFlag = $TRUE
            $Script:ForceFinalize = $TRUE
            Break
            }else{
            Finalize $ErrorReturnCode
            }
   
    }


   IF($ActionType -match '^(Compress|CompressAndAddTimeStamp|AddTimeStamp|Copy|Move|Rename|Archive|ArchiveAndAddTimeStamp)$' ){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ActionTo)を作成しました"
        }


    IF($OverRideFlag){
        $Script:OverRideCount ++
        $Script:InLoopOverRideCount ++
        $Script:OverRideFlag = $False
        }
           
    Logging -EventID $SuccessEventID -EventType Success -EventMessage "${ActionError}の[${ActionType}]に成功しました"
    $Script:NormalFlag = $TRUE

}




#相対パスから絶対パスへ変換
#相対パスは.\ または ..\から始めて下さい。
#このfunctionは検査対象パスがNull , emptyの場合、異常終了します。確認が必要なパスのみを検査して下さい。
#* ?等のNTFSに使用できない文字がパスに含まれている場合は異常終了します
#[]のPowershellでワイルドカードとして扱われる文字は、ワイルドカードとして扱いません。LiteralPathとしてそのまま処理します
#なおTryActionはワイルドカード[]を扱いません。LiteralPathとしてそのまま処理します

Function ConvertToAbsolutePath {

Param(
[String]$CheckPath,
[parameter(mandatory=$true)][String]$ObjectName

)



    IF ([String]::IsNullOrEmpty($CheckPath)){
           
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) の指定は必須です"
                    Finalize $ErrorReturnCode
                    }

    #Windowsではパス区切に/も使用できる。しかしながら、処理を簡単にするため\に統一する

    $CheckPath = $CheckPath.Replace('/','\')

    IF(Test-Path -LiteralPath $CheckPath -IsValid){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]は有効なパス表記です"
   
        }else{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)]は有効なパス表記ではありません。存在しないドライブを指定している、NTFSに使用できない文字列が含まれてないか等を確認して下さい"
        Finalize $ErrorReturnCode
        }



    Switch -Regex ($CheckPath){

    "^\.+\\.*"{
       
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]は相対パス表記です"

        $ConvertedCheckPath = Join-Path -Path $DatumPath -ChildPath $CheckPath | ForEach-Object {[System.IO.Path]::GetFullPath($_)}
         
        Logging -EventID $InfoEventID -EventType Information -EventMessage "スクリプトが配置されているフォルダ[$($DatumPath)]、[$($CheckPath)]とを結合した絶対パス表記[$($ConvertedCheckPath)]に変換します"

        $CheckPath = $ConvertedCheckPath

        }

        "^[c-zC-Z]:\\.*"{

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]は絶対パス表記です"


        }
        Default{
      
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)]は相対パス、絶対パス表記ではありません"
        Finalize $ErrorReturnCode
        }
    }

    #パス末尾に\\が連続すると処理が複雑になるので、使わせない

    IF($CheckPath -match '\\\\'){
 
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Windowsパス指定で区切記号\の重複は許容されていますが、本プログラムでは都合上使用しません。重複した\を削除します"

            For ( $i = 0 ; $i -lt $CheckPath.Length-1 ; $i++ )        
            {
            $CheckPath = $CheckPath.Replace('\\','\')
            }

        Logging -EventID $InfoEventID -EventType Information -EventMessage "重複した\を削除した$ObjectName[$($CheckPath)]に変換しました"
        }


    #パスがフォルダで末尾に\が存在した場合は削除する。末尾の\有無で結果は一緒なのだが、統一しないと文字列数が異なるためパス文字列切り出しが誤動作する。

    IF($CheckPath.Substring($CheckPath.Length -1 , 1) -eq '\'){
    
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Windowsパス指定で末尾\は許容されていますが、本プログラムでは都合上使用しません。末尾\を削除します"
            $CheckPath = $CheckPath.Substring(0 , $CheckPath.Length -1)
            }


    #TEST-Path -isvalidはコロン:の含まれているPathを正しく判定しないので個別に判定

    IF ((Split-Path $CheckPath -noQualifier) -match '(\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "$ObjectName にNTFSで使用できない文字を指定しています"
                Finalize $ErrorReturnCode
                }


    #Windows予約語がパスに含まれているか判定

    IF($CheckPath -match '\\(AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])(\\|$|\..*$)'){

                Logging -EventType Error -EventID $ErrorEventID -EventMessage "$ObjectName のパスにWindows予約語を含んでいます。以下は予約語のためWindowsでファイル、フォルダ名称に使用できません(AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])"
                Finalize $ErrorReturnCode
                }        





    Return $CheckPath

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
#引数$Healthで状態(Running|Stopped)を指定してください。戻り値は指定状態で$TRUEまたは非指定状態$False
#サービス起動、停止しても状態推移には時間が掛かります。このfunctionは一定時間$Span、一定回数$UpTo、状態確認を繰り返します
#起動が遅いサービスは$Spanを大きくしてください

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
       
        }elseIF($Counter -eq $Upto){

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
      Start-sleep $Span

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


    If (Test-Path -LiteralPath $CheckPath -PathType Container){

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

    If (Test-Path -LiteralPath $CheckPath -PathType Leaf){

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


function CheckLogPath {


Param(

[String]$CheckPath,
[String]$ObjectName ,
[String]$FileValue = $NULL

)
    #ログ出力先ファイルの親フォルダが存在しなければ異常終了

    Split-Path $CheckPath | ForEach-Object {CheckContainer -CheckPath $_ -ObjectName $ObjectName -IfNoExistFinalize > $NULL}

    #ログ出力先（予定）ファイルと同一名称のフォルダが存在していれば異常終了

    If(Test-Path -LiteralPath $CheckPath -PathType Container){
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "既に同一名称フォルダ$($CheckLeaf)が存在します"        
        Finalize $ErrorReturnCode
        }


    If(Test-Path -LiteralPath $CheckPath -PathType Leaf){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckPath)]への書込権限を確認します"
        $LogFormattedDate = (Get-Date).ToString($LogDateFormat)
        $LogWrite = $LogFormattedDate+" "+$SHELLNAME+" Write Permission Check"
        

        Try{
            Write-Output $LogWrite | Out-File -FilePath $CheckPath -Append -Encoding $LogFileEncode
            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckPath)]への書込に成功しました"
            }
        Catch [Exception]{
            Logging -EventType Error -EventID $ErrorEventID -EventMessage  "$($ObjectName) [$($CheckPath)]への書込に失敗しました"
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "起動時エラーメッセージ : $Error[0]"
            Finalize $ErrorReturnCode
            }
     
     }else{
            TryAction -ActionType MakeNewFileWithValue -ActionFrom $CheckPath -ActionError $CheckPath -FileValue $FileValue
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
$ForceConsole = $false
$ForceConsoleEventLog = $false

#ReturnCode確認

. CheckReturnCode


#イベントソース未設定時の処理

. CheckEventLogSource


#ログファイル出力先確認

. CheckLogFilePath



#ここはfunctionなので変数はfunction内でのものとなる。スクリプト全体に反映するにはスコープを明示的に$Script:変数名とする

#ログ抑止フラグ処理

IF($NoLog2EventLog){[boolean]$Script:Log2EventLog = $False}
IF($NoLog2Console){[boolean]$Script:Log2Console = $False}
IF($NoLog2File){[boolean]$Script:Log2File = $False}


Logging -EventID $InfoEventID -EventType Information -EventMessage "${SHELLNAME} Version $($Version)を起動します"

Logging -EventID $InfoEventID -EventType Information -EventMessage "CommonFunctions.ps1 Version $($CommonFunctionsVersion)をLoadしました"

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

    $ScriptExecUser = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name

    $LogFormattedDate = (Get-Date).ToString($LogDateFormat)

    $SQLLog = $Null



#Powershellではヒアドキュメントの改行はLFとして処理される
#しかしながら、他のOracleからの出力はLF&CRのため、Windowsメモ帳で開くと改行コードが混在して正しく処理されない
#よって、明示的にCRを追加してSQLLogで改行コードが混在しないようにする
#Sakura Editor等では改行コード混在も正しく処理される

$LogWrite = @"
`r
`r
----------------------------`r
DATE: $LogFormattedDate`r
SHELL: $SHELLNAME`r
SQL: $SQLName`r
`r
OS User: $ScriptExecUser`r
`r
SQL Exec User: $ExecUser`r
Password Authrization [$PasswordAuthorization]`r
`r
"@


Write-Output $LogWrite | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode

Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization){

    $SQLLog = $SQLCommand | SQLPlus $ExecUser/$ExecUserPassword@OracleSerivce as sysdba

    }else{
    $SQLLog = $SQLCommand | SQLPlus / as sysdba
    }

Write-Output $SQLLog | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode


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
    $SQLLog = $SQLLog -replace "`r","" |  ForEach-Object {$_ -split "`n"}

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


function AddTimeStampToFileName{

    Param
    (
    [String]$TimeStampFormat,
    [String]$TargetFileName
    )


    $FormattedDate = (Get-Date).ToString($TimeStampFormat)
    $ExtensionString = [System.IO.Path]::GetExtension($TargetFileName)
    $FileNameWithOutExtentionString = [System.IO.Path]::GetFileNameWithoutExtension($TargetFileName)

    Return $FileNameWithOutExtentionString+$FormattedDate+$ExtensionString

}


function CheckUserName {

Param(
[parameter(mandatory=$true)][String]$CheckUserName,
[String]$ObjectName 
)

    Switch -Regex ($CheckUserName){

    '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckUserName)] is valid"
        Return $TRUE     
        }

    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckUserName)] is invalid"
        Finalize $ErroReturnCode
        }

    }

}

function CheckDomainName {

Param(
[parameter(mandatory=$true)][String]$CheckDomainName,
[String]$ObjectName 
)

    Switch -Regex ($CheckDomainName){

    '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckDomainName)] is valid"
        Return $TRUE     
        }

    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckDomainName)] is invalid"
        Finalize $ErroReturnCode
        }

    }

}


function CheckHostname {

Param(
[parameter(mandatory=$true)][String]$CheckHostName,
[String]$ObjectName 
)

    Switch -Regex ($CheckHostName){

    '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckHostName)] is valid IP Address"
        Return $TRUE     
        }
    '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckHostName)] is valid Hostname"
        Return $TRUE                
        }
    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckHostName)] is invalid Hostname"
        Finalize $ErroReturnCode
        }

    }

#ValidIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";

#ValidHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";

}
