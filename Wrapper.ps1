#Requires -Version 3.0

<#
.SYNOPSIS

This script loads a configuration file including arguments, execute the other script with arguments in every lines.
CommonFunctions.ps1 is required.
You can process log files in multiple folders with FileMaintenance.ps1

指定したプログラムを設定ファイルに書かれたパラメータを読み込んで、順次呼び出すプログラムです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているFileMaintenance.ps1と併用すると複数のログ処理を一括実行できます。

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

Specify if you want to output log to Windows Event Log.
[$TRUE] is default.


.PARAMETER NoLog2EventLog
Specify if you want to suppress log to Windows Event Log.
Specification overrides -Log2EventLog


.PARAMETER ProviderName

Specify provider name of Windows Event Log.
[Infra] is default.


.PARAMETER EventLogLogName

Specify log name of Windows Event Log.
[Application] is default.


.PARAMETER Log2Console

Specify if you want to output log to PowerShell console.
[$TRUE] is default.


.PARAMETER NoLog2Console

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2Console


.PARAMETER Log2File

Specify if you want to output log to text log.
[$FALSE] is default.


.PARAMETER NoLog2File

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2File


.PARAMETER LogPath

Specify the path of text log file.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.
[$NULL] is default.

If the log file dose not exist, the script makes a new file.
If the log file exists, the script writes log additionally.


.PARAMETER LogDateFormat

Specicy time stamp format in the text log.
[yyyy-MM-dd-HH:mm:ss] is default.


.PARAMETER LogFileEncode

Specify the character encode in the log file.
[Default] is default and it works as ShiftJIS.


.PARAMETER NormalReturnCode

Specify Normal Return code.
[0] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER WarningReturnCode

Specify Warning Return code.
[1] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER ErrorReturnCode

Specify Error Return code.
[8] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER InternalErrorReturnCode

Specify Internal Error Return code.
[16] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER InfoEventID

Specify information event id in the log.
[1] is default.


.PARAMETER InfoLoopStartEventID

Specify start loop event id in the log.
[2] is default.


.PARAMETER InfoLoopEndEventID

Specify end loop event id in the log.
[3] is default.


.PARAMETER StartEventID

Specify start script id in the log.
[8] is default.


.PARAMETER EndEventID

Specify end script event id in the log.
[9] is default.


.PARAMETER WarningEventID

Specify Warning event id in the log.
[10] is default.


.PARAMETER SuccessEventID

Specify Successfully complete event id in the log.
[73] is default.


.PARAMETER InternalErrorEventID

Specify Internal Error event id in the log.
[99] is default.


.PARAMETER ErrorEventID

Specify Error event id in the log.
[100] is default.


.PARAMETER ErrorAsWarning

Specfy if you want to return WARNING exit code when the script terminate with an Error.


.PARAMETER WarningAsNormal

Specify if you want to return NORMAL exit code when the script terminate with a Warning.


.PARAMETER ExecutableUser

Specify the users who are allowed to execute the script in regular expression.
[.*] is default and all users are allowed to execute.
Parameter must be quoted with single quote'
Escape the back slash in the separeter of a domain name.
example [domain\\.*]
　

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

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
Param(

[String]
[parameter(position = 0, mandatory, HelpMessage = 'Specify path of powershell script to execute(ex. .\FileMaintenance.ps1)  or Get-Help Wrapper.ps1')]
[ValidateNotNullOrEmpty()]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("Path","LiteralPath","FullName")]$CommandPath ,

[String]
[parameter(position = 1, mandatory, HelpMessage = 'Specify path of command file including arguments(ex. .\Command.txt)  or Get-Help Wrapper.ps1')]
[ValidateNotNullOrEmpty()]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommandFile ,

[String]
[parameter(position = 2)][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default' , #Default指定はShift-Jis

[Switch]$Continue ,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[Boolean]$Log2Console = $TRUE ,
[Switch]$NoLog2Console ,

[Boolean]$Log2File = $FALSE ,
[Switch]$NoLog2File ,

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]
[ValidateNotNullOrEmpty()]$LogPath ,

[String]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss' ,
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default' , #Default ShiftJIS


[Int][ValidateRange(0,2147483647)]$NormalReturnCode        =  0 ,
[Int][ValidateRange(0,2147483647)]$WarningReturnCode       =  1 ,
[Int][ValidateRange(0,2147483647)]$ErrorReturnCode         =  8 ,
[Int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16 ,

[Int][ValidateRange(1,65535)]$InfoEventID          =   1 ,
[Int][ValidateRange(1,65535)]$InfoLoopStartEventID =   2 ,
[Int][ValidateRange(1,65535)]$InfoLoopEndEventID   =   3 ,
[int][ValidateRange(1,65535)]$StartEventID         =   8 ,
[int][ValidateRange(1,65535)]$EndEventID           =   9 ,
[Int][ValidateRange(1,65535)]$WarningEventID       =  10 ,
[Int][ValidateRange(1,65535)]$SuccessEventID       =  73 ,
[Int][ValidateRange(1,65535)]$InternalErrorEventID =  99 ,
[Int][ValidateRange(1,65535)]$ErrorEventID         = 100 ,

[Switch]$ErrorAsWarning ,
[Switch]$WarningAsNormal ,

[Regex]$ExecutableUser = '.*'

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
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage ("An ERROR termination occurred. Specified -Continue[${Continue}] option, " +
                "thus will terminate with ERROR and had executed command of the next lines.")
            }
    }

 Invoke-PostFinalize $ReturnCode

}



#####################   ここから本体  ######################

[int][ValidateRange(0,2147483647)]$NormalCount  = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$ErrorCount   = 0

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.8"

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


:ForLoop For ( $i = 0 ; $i -lt $lines.Count; $i++ ) {

    $line = $lines[$i]

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)]"

    Write-Debug "Command[$($CommandPath)] Arguments[$($line)] Line[$($i+1)]"   

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
                $ErrorCount++
                Break ForLoop
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
                        Break ForLoop
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

IF ($ErrorCount -gt 0) {
    $result = $ErrorReturnCode
    } elseIF ($WarningCount -gt 0) {
        $result = $WarningReturnCode
        } else {
            $result = $NormalReturnCode
            }

Finalize -ReturnCode $result
