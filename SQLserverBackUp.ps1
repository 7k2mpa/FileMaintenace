#Requires -Version 3.0

<#
.SYNOPSIS
Execute Backup-SQLdatabase with logging.

.DESCRIPTION
Execute Backup-SQLdatabase with logging.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 

.EXAMPLE
.\SQLserverBackUp.ps1 -BackUpFile '\NAS\SQLfull.bk' -ServerInstance 'SQLserver\Instance' -DBname 'testDB' -Type Full 


.PARAMETER BackUpFile

Specify a path of backup file export.
Specification is required.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


.PARAMETER ServerInstance

Specify SQL Server Instance.
Specification is required.


.PARAMETER DBname

Specify SQL Server database name.
Specification is required.

.PARAMETER Type

Specify backup type.
Choose one from [Full (Backup)] [Diff(erential BackUp)] [Tran(saction Log Backup)]



.PARAMETER Log2EventLog

Specify if you want to output log to Windows Event Log.
[$TRUE] is default.

　Windows Event Logへの出力を制御します。
デフォルトは$TRUEでEvent Log出力します。

.PARAMETER NoLog2EventLog
Specify if you want to suppress log to Windows Event Log.
Specification override -Log2EventLog

　Event Log出力を抑止します。-Log2EventLog $FALSEと等価です。
Log2EventLogより優先します。

.PARAMETER ProviderName

Specify provider name of Windows Event Log.
[Infra] is default.


　Windows Event Log出力のプロバイダ名を指定します。
デフォルトは[Infra]です。

.PARAMETER EventLogLogName

Specify log name of Windows Event Log.
[Application] is default.

　Windows Event Log出力のログ名を指定します。
デフォルトは[Application]です。

.PARAMETER Log2Console

Specify if you want to output log to PowerShell console.
[$TRUE] is default.

　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2Console

　コンソールログ出力を抑止します。-Log2Console $FALSEと等価です。
Log2Consoleより優先します。

.PARAMETER Log2File

Specify if you want to output log to text log.
[$FALSE] is default.

　ログフィルへの出力を制御します。
デフォルトは$FALSEでログファイル出力しません。

.PARAMETER NoLog2File

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2File

　ログファイル出力を抑止します。-Log2File $FALSEと等価です。
Log2Fileより優先します。

.PARAMETER LogPath

Specify the path of text log file.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.
[$NULL] is default.

If the log file dose not exist, make a new file.
If the log file exists, write log additionally.

　ログファイル出力パスを指定します。デフォルトは$NULLです。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log\Log.txt , ..\Script\log\log.txt）
ワイルドカード* ? []は使用できません。
フォルダ、ファイル名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。
ファイルが存在しない場合は新規作成します。
ファイルが既存の場合は追記します。

.PARAMETER LogDateFormat

Specicy time stamp format in the text log.
[yyyy-MM-dd-HH:mm:ss] is default.

　ログファイル出力に含まれる日時表示フォーマットを指定します。
デフォルトは[yyyy-MM-dd-HH:mm:ss]形式です。

.PARAMETER LogFileEncode

Specify the character encode in the log file.
[Default] is default and it works as ShiftJIS.


ログファイルの文字コードを指定します。
デフォルトはShift-JISです。

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

　異常終了しても警告終了のReturnCodeを返します。

.PARAMETER WarningAsNormal

Specify if you want to return NORMAL exit code when the script terminate with a Warning.

　警告終了しても正常終了のReturnCodeを返します。

.PARAMETER ExecutableUser

Specify the users who are allowed to execute the script in regular expression.
[.*] is default and all users are allowed to execute.
Parameter must be quoted with single quote'
Escape the back slash in the separeter of a domain name.
example [domain\\.*]

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


[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
Param(

[String][parameter(position=0)]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("LiteralPath")]$BackUpFile ,

[String][parameter(position=1)][ValidateNotNullOrEmpty()]$ServerInstance ,

[String][parameter(position=2)][ValidateNotNullOrEmpty()]$DBname ,

[String][parameter(position=3)][ValidateSet("Full", "Diff" , "Trun")]$Type,


[Boolean]$Log2EventLog = $TRUE ,
[Switch]$NoLog2EventLog ,
[String][ValidateNotNullOrEmpty()]$ProviderName = 'Infra' ,
[String][ValidateSet("Application")]$EventLogLogName = 'Application' ,

[Boolean]$Log2Console = $TRUE ,
[Switch]$NoLog2Console ,

[Boolean]$Log2File = $FALSE ,
[Switch]$NoLog2File ,

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath ,

[String][ValidateNotNullOrEmpty()]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss' ,
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

$ShellName = Split-Path -Path $PSCommandPath -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. Invoke-PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い



#パラメータの確認

    $BackUpFile = $BackUpFile | ConvertTo-AbsolutePath -Name '-BackUpFile'

    $BackUpFile | Test-Container -Name '-BackUpFile' -IfNoExistFinalize > $NULL


#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Starting to back up SQLserver. Type[$($Type)] DB[$($DBname)] Server[$($ServerInstance)] OutTo[$($BackUpFile)] "

}


function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

 Invoke-PostFinalize $ReturnCode

}


#####################   ここから本体  ######################


$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.9"


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

    Switch -Regex ($Type) {

        'Full' {
            $parameter = @{
                BackUpAction = 'Database'
                Incremental  = $FALSE
                Initialize   = $FALSE    
                }
            }

        'Diff' {
            $parameter = @{
                BackUpAction = 'Database'
                Incremental  = $TRUE
                Initialize   = $FALSE    
                }
            }

        'Trun' {
            $parameter = @{
                BackUpAction = 'Log'
                Incremental  = $FALSE
                Initialize   = $TRUE   
                }
            }

        default {
            Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error at Function Invoke-Action. Switch ActionType exception has occurred. "
            Finalize -ReturnCode $InternalErrorReturnCode
            }

    }

$parameter+= @{
    CompressionOption = 'On'
    Database          = $DBname
    ServerInstance    = $ServerInstance
    BackUpFile        = $BackUpFile
}

   
    try {
        Backup-SqlDatabase @parameter
        }
        
    catch [Exception] {
   
        $errorDetail = $ERROR[0] | Out-String
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to back up SQL Server. Type[$($Type)] DB[$($DBname)] Server[$($ServerInstance)] OutTo[$($BackUpFile)]"
	    Finalize -ReturnCode $ErrorReturnCode
        } 


Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to Backup SQL Server. Type[$($Type)] DB[$($DBname)] Server[$($ServerInstance)] OutTo[$($BackUpFile)]"

Finalize -ReturnCode $NormalReturnCode
