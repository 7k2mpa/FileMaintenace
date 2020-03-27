#Requires -Version 3.0

<#
.SYNOPSIS
指定したプログラムを設定ファイルに書かれたパラメータを読み込んで実行します。
正常終了に遷移するまで、指定秒数間隔で指定回数実行します。


実行にはCommonFunctions.ps1が必要です。


<Common Parameters>はサポートしていません

.DESCRIPTION
指定したプログラムを設定ファイルに書かれたパラメータを読み込んで実行します。
正常終了に遷移するまで、指定秒数間隔で指定回数実行します。
指定したプログラムが正常終了した場合、本プログラムは正常終了します。
指定したプログラムが警告終了した場合、本プログラムは指定秒数間隔で指定回数指定したプログラムを再実行します。
指定回数を超過した場合は警告終了します。

指定したプログラムが異常終了した場合、本プログラムは異常終了します。


設定ファイルは任意に設定可能です。
設定ファイルの1行目のみを指定したプログラムに渡して実行します。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。



設定ファイル例です。
例えば以下をLoopWrapperCommand.txtに保存します。
これを-CommandPath .\CheckFlag.ps1 -CommandFile .\LoopWrapperCommand.txtを引数として本プログラムを実行しますｌ

---　
-CheckFolder .\Lock -CheckFile BkupDB.flg
---



.EXAMPLE

LoopWrapper.ps1 -CommandPath .\CheckFlag.ps1 -CommandFile .\Command.txt
　このプログラムと同一フォルダに存在するCheckFlag.ps1を起動します。
起動する際に渡すパラメータは設定ファイルComman.txtの1行目です。

CheckFlag.ps1が正常終了すると、本プログラムは正常終了します。

CheckFlag.ps1が警告終了すると、本プログラムは指定秒数間隔で指定回数CheckFlag.ps1を再実行します。
CheckFlag.ps1はフラグファイルが存在しないと正常終了、存在すると警告終了します。
この設定では、フラグファイルが削除されるまで本プログラムは指定回数ループ継続します。
指定回数を超過した場合は警告終了します。


CheckFlag.ps1が異常終了すると、本プログラムは異常終了します。


.EXAMPLE

LoopWrapper.ps1 -CommandPath .\CheckFlag.ps1 -CommandFile .\Command.txt -Span 60 -UpTo 120
　このプログラムと同一フォルダに存在するCheckFlag.ps1を起動します。
起動する際に渡すパラメータは設定ファイルComman.txtの1行目です。

CheckFlag.ps1が正常終了すると、本プログラムは正常終了します。

CheckFlag.ps1が警告終了すると、本プログラムは指定秒数間隔で指定回数CheckFlag.ps1を再実行します。
60秒間隔で120回試行します。

CheckFlag.ps1はフラグファイルが存在しないと正常終了、存在すると警告終了します。
この設定では、フラグファイルが削除されるまで本プログラムは指定回数ループ継続します。

指定回数を超過した場合は警告終了します。


CheckFlag.ps1が異常終了すると、本プログラムは異常終了します。



.PARAMETER CommandPath
　起動するプログラムパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
ワイルドカード*は使用できません。

.PARAMETER CommandFile
　起動するプログラムに渡すコマンドファイルを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
ワイルドカード*は使用できません。

.PARAMETER CommandFileEncode
　コマンドファイルの文字コードを指定します。
デフォルトは[Default]でShif-Jisです。


.PARAMETER Span
再実行時の間隔を秒数で指定します。
デフォルトは10秒です。

.PARAMETER UpTo
再実行の試行回数を指定します。
デフォルトは1000回です。

.PARAMETER Continue
起動したプログラムが異常終了してもループ処理を継続します。



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
相対パス表記は、.から始める表記にして下さい。（例 .\Log\Log.txt , ..\Script\log\log.txt）
ワイルドカード* ? []は使用できません。
フォルダ、ファイル名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。
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

[parameter(position=0, mandatory=$true , HelpMessage = '起動対象のpowershellプログラムを指定(ex. .\FileMaintenance.ps1) 全てのHelpはGet-Help Wrapper.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*\.ps1$')]$CommandPath ,
[parameter(position=1, mandatory=$true , HelpMessage = 'powershellプログラムに指定するコマンドファイルを指定(ex. .\Command.txt) 全てのHelpはGet-Help Wrapper.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommandFile,


[parameter(position=2)][ValidateRange(1,65535)][int]$Span = 10,
[parameter(position=3)][ValidateRange(1,65535)][int]$UpTo = 1000,

[Switch]$Continue,

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default', #Default指定はShift-Jis


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath ,
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath = ..\Log\FileMaintenance.log ,
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
    Write-Output "Fail to load CommonFunctions.ps1 Please verfy existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }


################ 設定が必要なのはここまで ##################



################# 共通部品、関数  #######################

function Initialize {

$ShellName = Split-Path -Path $PSCommandPath -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. Invoke-PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#パラメータの確認


#コマンドの有無を確認


    $CommandPath = $CommandPath | ConvertTo-AbsolutePath -ObjectName '-CommandPath'

    Test-Leaf -CheckPath $CommandPath -ObjectName '-CommandPath' -IfNoExistFinalize > $NULL

#コマンドファイルの有無を確認
    

    $CommandFile = $CommandFile | ConvertTo-AbsolutePath -ObjectName '-CommandFile'

    Test-Leaf -CheckPath $CommandFile -ObjectName '-CommandFile' -IfNoExistFinalize > $NULL


#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Starting to exec command [$($CommandPath)]です"

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)




 Invoke-PostFinalize $ReturnCode

}



#####################   ここから本体  ######################

$DatumPath = $PSScriptRoot

$Version = '20200224_1640'

#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

    Try {

        $line = @(Get-Content $CommandFile -Encoding $CommandFileEncode -TotalCount 1  -ErrorAction Stop)
        }
                    catch [Exception]
                    {
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to load -CommandFile"
                    $errorDetail = $Error[0] | Out-String
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
                    Finalize $ErrorReturnCode
                    }




For ( $i = 1 ; $i -le $UpTo ; $i++ ){

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute 1st line in [$($CommandFile)]"
    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Try times [$($i)/$($UpTo)]"

        Try {
        
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute command [$($CommandPath)] with arguments [$($line)]"
            Invoke-Expression "$CommandPath $Line" -ErrorAction Stop

            }

            catch [Exception]{

            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute [$($CommandPath)]"
            $errorDetail = $Error[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
            }

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Result of execution [$($CommandFile)] is [$($LASTEXITCODE)]"
                    

        #終了コードで分岐
        Switch ($LastExitCode) {

                        #条件1 異常終了
                        {$_ -ge $ErrorReturnCode} {
 
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "An ERROR termination occurred at line 1 in -CommandFile [$($CommandFile)]"
       
                            IF ($Continue) {
                                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Will try again, because option -Continue[$($Continue)] is used." 
                                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Wait for [$($Span)] seconds."
                                Start-Sleep -Seconds $Span
                                Break     
     
                                }else{
                                Finalize $ErrorReturnCode
                                }
                            }

                    
                        #条件2 警告終了
                        {$_ -ge $WarningReturnCode} {
                            

                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "A WARNING termination occurred at line 1 in [$($CommandFile)] , will try again. " 
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Waint for [$($Span)] seconds."
                            Start-Sleep -Seconds $Span                             
                            }

                        
                        #条件3 正常終了
                        Default {

                            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Completed successfully in [$($i)] times try."                        
                            Finalize $NormalReturnCode
                            }
        }
    
  

#対象群の処理ループ終端
}

Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Although with [$($UpTo)] times retry, did not complete successfully. Thus terminate as WARNING." 

Finalize $WarningReturnCode