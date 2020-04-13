#Requires -Version 3.0

<#
.SYNOPSIS

This script loads a configuration file including arguments, execute the other script with arguments in every lines.
CommonFunctions.ps1 is required.
You can process log files in multiple folders with FileMaintenance.ps1
<Common Parameters> is not supported.

指定したプログラムを設定ファイルに書かれたパラメータを読み込んで、順次呼び出すプログラムです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているFileMaintenance.ps1と併用すると複数のログ処理を一括実行できます。

<Common Parameters>はサポートしていません

.DESCRIPTION

This script loads a configuration file including arguments, execute the other script with arguments in every lines.
The configuration file can be set arbitrarily.
A line starting with # in the configuration file, it is proccessed as a comment.
An empty line in the configuration file, it is sikkiped.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 

設定ファイルから1行づつパラメータを読み込み、指定したプログラムに順次実行させます。

設定ファイルは任意に設定可能です。
設定ファイルの行頭を#とすると当該行はコメントとして処理されます。
設定ファイルの空白行はスキップします。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。

Sample Configuration file. 
Save the file as DailyMaintenance.txt, execute with option '-CommandPath [TargetScript.ps1] -CommandFile .\DailyMaintenance.txt'
---
#delete files older than 14days and end with .log.
-TargetFolder D:\IIS\LOG -RegularExpression '^.*\.log$' -Action Delete -Days 14

#move access log older 7days to Old_Log
-TargetFolder D:\AccessLog -MoveToFolder .\Old_Log -Days 7
---

設定ファイル例です。例えば以下をDailyMaintenance.txtに保存して-CommandFile .\DailyMaintenance.txtと指定して下さい。

---
#14日経過した.logで終わるファイルを削除
-TargetFolder D:\IIS\LOG -RegularExpression '^.*\.log$' -Action Delete -Days 14

#7日経過したアクセスログをOld_Logへ退避
-TargetFolder D:\AccessLog -MoveToFolder .\Old_Log -Days 7
---



.EXAMPLE

Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Command.txt

Execute .\FileMaintenance.ps1 in the same folder.
Load the parameter file .\Command.txt and execute .\FileMaintenance with arguments in the parameter file every lines.

このプログラムと同一フォルダに存在するFileMaintenance.ps1を起動します。
起動する際に渡すパラメータは設定ファイルComman.txtを1行づつ読み込み、順次実行します。


.EXAMPLE

Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Command.txt -Continue

Execute .\FileMaintenance.ps1 in the same folder.
Load the parameter file .\Command.txt and execute .\FileMaintenance with arguments in the parameter file every lines.
If ERROR termination occur in the line, do not terminate Wrapper.ps1 and execute FileMaintenance.ps1 with argument in the next line.

　このプログラムと同一フォルダに存在するFileMaintenance.ps1を起動します。
起動する際に渡すパラメータは設定ファイルComman.txtを1行づつ読み込み、順次実行します。
もし、FileMaintenance.ps1を実行した結果が異常終了となった場合は、Wrapper.ps1を異常終了させず、Command.txtの次行を読み込み継続処理をします。



.PARAMETER CommandPath

Specify the path of script to execute.
Specification is required.
Wild cards are not accepted.

　起動するプログラムパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
ワイルドカード*は使用できません。

.PARAMETER CommandFile

Specify the path of command file with arguments.
Specification is required.
Wild cards are not accepted.


　起動するプログラムに渡すコマンドファイルを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
ワイルドカード*は使用できません。

.PARAMETER CommandFileEncode

Specify encode chracter code in the command file.
[Default(ShitJIS)] is default.

　コマンドファイルの文字コードを指定します。
デフォルトは[Default]でShif-Jisです。


.PARAMETER Continue

If you want to execute script with argument next line in the command file ending the script with error.
[This script terminates with Error] is default.

　起動したプログラムが異常終了しても、コマンドファイルの次行を継続処理します。
デフォルトではそのまま異常終了します。



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

[String]
[parameter(position = 0, mandatory, HelpMessage = 'Specify path of powershell script to execute(ex. .\FileMaintenance.ps1)  or Get-Help Wrapper.ps1')]
[ValidateNotNullOrEmpty()]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("Path","LiteralPath","FullName")]$CommandPath ,

[String]
[parameter(position = 1, mandatory, HelpMessage = 'Specify path of command file including arguments(ex. .\Command.txt)  or Get-Help Wrapper.ps1')]
[ValidateNotNullOrEmpty()]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommandFile ,

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default' , #Default指定はShift-Jis

[Switch]$Continue ,

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

$ShellName = $PSCommandPath | Split-Path -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. Invoke-PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#パラメータの確認


#コマンドの有無を確認


    $CommandPath = $CommandPath | ConvertTo-AbsolutePath -ObjectName ' -CommandPath'

    $CommandPath | Test-Leaf -Name '-CommandPath' -IfNoExistFinalize > $NULL

#コマンドファイルの有無を確認
    

    $CommandFile = $CommandFile | ConvertTo-AbsolutePath -ObjectName '-CommandFile'

    $CommandFile | Test-Leaf -Name '-CommandFile' -IfNoExistFinalize > $NULL


#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to execute command [$($CommandPath)] with arguments [$($CommandFile)]"

}

function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)

    IF (-not(($NormalCount -eq 0) -and ($WarningCount -eq 0) -and ($ErrorCount -eq 0))) {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execution Results NORMAL[$($NormalCount)], WARNING[$($WarningCount)], ERROR[$($ErrorCount)]"

        If (($Continue) -and ($ErrorCount -gt 0)){
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "An ERROR termination occurred. Specified -Continue[${Continue}] option, thus will terminate with ERROR and had executed command of the next lines."
            }


    }


 Invoke-PostFinalize $ReturnCode

}



#####################   ここから本体  ######################

[int][ValidateRange(0,2147483647)]$NormalCount  = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$ErrorCount   = 0

$DatumPath = $PSScriptRoot

$Version = "2.0.0-beta.14"

#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

    Try {

        $lines = @(Get-Content $CommandFile -Encoding $CommandFileEncode -ErrorAction Stop)  
        }
        
        catch [Exception] {
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to load -CommandFile"
            $errorDetail = $ERROR[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
            }


For ( $i = 0 ; $i -lt $lines.Count; $i++ ) {

    $line = $lines[$i]

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)]"


    Switch -Regex ($line) {

        #分岐1 行頭#でコメント
        '^#.*$' {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Comment[$($line)]"
            }

        #分岐2 空白
        '^$' {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Empty Line"
            }

        #分岐3 コマンド実行
        default {

            Try{        
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute Command [$($CommandPath)] with arguments [$($line)]"
                    Invoke-Expression "$CommandPath $line" -ErrorAction Stop
                    }

                catch [Exception] {
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute [$($CommandPath)] and force to exit."
                    $errorDetail = $ERROR[0] | Out-String
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
                    Finalize $ErrorReturnCode
                    }

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execution Result is [$($LASTEXITCODE)] at line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)]"
                    

            #終了コードで分岐
            Switch ($LASTEXITCODE) {

                        #条件1 異常終了
                        {$_ -ge $ErrorReturnCode} {
 
                            $ErrorCount++
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "An ERROR termination occurred at line [$($i+1)/$($Lines.Count)] in -CommandFile [$($CommandFile)]"
       
                            IF ($Continue) {
                                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Specified -Continue[$($Continue)] option, thus execute next line."   
                                Break     
     
                                }else{
                                Finalize $ErrorReturnCode
                                }
                            }
                    
                        #条件2 警告終了
                        {$_ -ge $WarningReturnCode} {
                            
                            $WarningCount++
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "A WARNING termination occurred at line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)] Will execute next line." 
                            Break        
                            }
                        
                        #条件3 正常終了
                        Default {
                            $NormalCount++
                            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Completed successfully at line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)]"
                            }
                   }
    
   
                # 分岐3 コマンド実行 default終端 
                }

    #Switch -Regex ($Line)終端
    }

#対象群の処理ループ終端
}


#終了メッセージ出力。ここではNormalReturnCodeで呼び出すが、Finalizeでエラーカウントを見て処理してくれる

Finalize $NormalReturnCode
