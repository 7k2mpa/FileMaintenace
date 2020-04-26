#Requires -Version 3.0


<#
.SYNOPSIS
This scipt start or stop Windows Service specified.
CommonFunctions.ps1 is required.
You can process multiple Windows services with Wrapper.ps1
<Common Parameters> is not supported.


指定したサービスを起動,停止するプログラムです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているFileMaintenance.ps1と併用すると複数のサービスを一括起動,停止できます。

<Common Parameters>はサポートしていません

.DESCRIPTION
This scipt start or stop Windows Service specified.
If start(stop) Windows serivce already started(stopped), will temrminate as WARNING.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


指定したサービスを起動,停止するプログラムです。
(停止|起動)済サービスを(停止|起動)指定すると警告終了します。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。


.EXAMPLE
ChangeServiceStatus.ps1 -Service Spooler -TargetStatus Stopped -RetrySpanSec 5 -RetryTimes 5

Stop Windows serivice(Service Name:Spooler, Print Spooler)
If it dose not stop immediately, retry 5times every 5seconds.

If the service is stoped already, terminate as WARNING.

サービス名:Spooler（表示名はPrint Spooler）を停止します。
直ぐに停止しない場合は、5秒間隔で最大5回試行します。

停止済サービスを停止しようとした場合は、警告終了します。



.EXAMPLE
ChangeServiceStatus.ps1 -Service Spooler -TargetStatus Running -RetrySpanSec 5 -RetryTimes 5 -WarningAsNormal

Start Windows serivice(Service Name:Spooler, Display Name:Print Spooler)
If it dose not start immediately, retry 5times every 5seconds.

Specified -WarningAsNormal option and, if the service is started already, terminate as NORMAL.


サービス名:Spooler（表示名はPrint Spooler）を起動します。
直ぐに起動しない場合は、5秒間隔で最大5回試行します。

起動済サービスを停止しようとした場合は、正常終了します。



.PARAMETER Service
Specify Windows 'Service name'.  'Service name' is diffent from 'Display name'.
Sample
Serivce Name:Spooker
Display Name:Print Spooler
 
Specification is required.

　(停止|起動)するサービス名を指定します。
「サービス名」と（サービスの）「表示名」は異なりますので留意して下さい。
例えば「表示名:Print Spooler」は「サービス名:Spooler」となっています。
指定必須です。

.PARAMETER TargetStatus
Specify target status (Stopped|Running) of the service.
Specification is required.

遷移するサービス状態を指定します。
(Stopped|Running)どちらかを指定して下さい。
指定必須です。

.PARAMETER RetrySpanSec
Specify interval to check service status.
Some services require long time to translate serivce status, specify appropriate value.
Default is 3seconds.


　サービス停止再確認の間隔秒数を指定します。
サービスによっては数秒必要なものもあるので適切な秒数に設定して下さい。
デフォルトは3秒です。

.PARAMETER RetryTimes
Specify times to check service status.
Some services require long time to translate serivce status, specify appropriate value.
Default is 5times.

　サービス停止再確認の回数を指定します。
サービスによっては数秒必要なものもあるので適切な回数に設定して下さい。
デフォルトは5回です。



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


MICROSOFT LIMITED PUBLIC LICENSE version 1.1

.LINK

https://github.com/7k2mpa/FileMaintenace

#>

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
Param(

[parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter Service name (ex. spooler) To View all help , Get-Help ChangeServiceStatus.ps1')]
[String][Alias("Name")]$Service ,

[parameter(position = 1, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
[String][ValidateSet("Running", "Stopped")][Alias("Status")]$TargetStatus , 


#[String][parameter(position=1)][ValidateSet("Running", "Stopped")]$TargetStatus = 'Running', 
#[String][parameter(position=1)][ValidateSet("Running", "Stopped")]$TargetStatus = 'Stopped', 


[int][parameter(position=2)][ValidateRange(1,65535)]$RetrySpanSec = 10 ,
[int][parameter(position=3)][ValidateRange(1,65535)]$RetryTimes = 18 ,


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
    Catch [Exception] {
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


    IF (-not($Service | Test-ServiceExist -NoMessage)) {
        Write-Log -Id $ErrorEventID -Type Error -Message "Service [$($Service)] dose not exist."
        Finalize $ErrorReturnCode
        }


    IF ($TargetStatus -notmatch '(Running|Stopped)') {
        Write-Log -Id $ErrorEventID -Type Error -Message "-TargetStatus [$($TargetStatus)] is invalid specification."
        Finalize $ErrorReturnCode   
        }


    For ($i = 0 ; $i -le $RetryTimes ; $i++ ) {

        IF ($i -ge $RetryTimes) {

            Write-Log -Id $ErrorEventID -Type Error -Message "Although retry specified times, service [$($Service)] status is in [$($status)]"
            Finalize $ErrorReturnCode                         
            }

        $status = (Get-Service | Where-Object {$_.Name -eq $Service}).Status

        IF ($status -match "Pending") {

            Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] is in [$($status)] status. Wait for $($RetrySpanSec) seconds."
            Start-Sleep -Seconds $RetrySpanSec
            
            } else {
            Break
            }
    }

    IF ($Service | Test-ServiceStatus -Status $TargetStatus -Span 0 -UpTo 1 ) {
        Write-Log -Id $WarningEventID -Type Warning -Message "Service [$($Service)] status is already [$($TargetStatus)]"
        Finalize $WarningReturnCode
        }
        



#処理開始メッセージ出力


Write-Log -Id $InfoEventID -Type Information -Message "All parameters are valid."

Write-Log -Id $InfoEventID -Type Information -Message "Starting to switch Service [$($Service)] status."

}


function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)


 Invoke-PostFinalize $ReturnCode


}


#####################   ここから本体  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.8"

[String]$computer = "localhost" 
[String]$class = "win32_service" 
[Object]$WMIservice = Get-WMIobject -Class $class -computer $computer -filter "name = '$Service'" 


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

 Switch -Regex ($TargetStatus) {
 
    'Stopped' {
        $originalStatus = 'Running'    
        }
    
    'Running' {
        $originalStatus = 'Stopped'
        }

    Default {
        Write-Log -Id $InternalErrorEventID -Type Error -Message 'Internal Error. $TargetStatus is invalid.'
        Finalize $InternalErrorReturnCode
        } 
 }


#以下のコードはMSのサンプルを参考
#MICROSOFT LIMITED PUBLIC LICENSE version 1.1
#https://gallery.technet.microsoft.com/scriptcenter/aa73bb75-38a6-4bd4-b72e-a6aede76d6ad
#https://devblogs.microsoft.com/scripting/hey-scripting-guy-how-can-i-use-windows-powershell-to-stop-services/

$result = $ErrorReturnCode

:ForLoop For ( $i = 0 ; $i -le $RetryTimes ; $i++ ) {

    # サービス存在確認
    IF (-not($Service | Test-ServiceExist)) {
        Break
        }

    Write-Log -Id $InfoEventID -Type Information -Message "With WMIService.(start|stop)Service, starting to switch Service [$($Service)] status from [$($originalStatus)] to [$($TargetStatus)]"

Write-Debug (Get-Service | Where-Object {$_.Name -eq $Service}).Status

    Switch -Regex ($TargetStatus) {
 
        'Stopped' {

            IF ((Get-Service | Where-Object {$_.Name -eq $Service}).Status -match "Pending") {
                Break
                } elseIF ($WMIservice.AcceptStop) {
                    $return = $WMIservice.stopService()

                    } else {
                    Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] will not accept a stop request. Wait for $($RetrySpanSec) seconds."
                    Start-Sleep -Seconds $RetrySpanSec
                    Continue ForLoop
                    }
                
            }
   
        'Running' {

            #https://docs.microsoft.com/ja-jp/windows/win32/cimwin32prov/win32-service
            #[AcceptStart Class] dose not exist

            $return = $WMIservice.startService()
            }

        Default {
            Write-Log -Id $InternalErrorEventID -Type Error -Message 'Internal Error. $TargetStatus is invalid. '
            $result = $InternalErrorReturnCode
            Break ForLoop
            }
    }


    Switch ($return.returnvalue) {
        
            0 {
                $serviceStatus = $Service | Test-ServiceStatus -Status $TargetStatus -Span $RetrySpanSec -UpTo $RetryTimes

                IF ($serviceStatus) {
                    Write-Log -Id $SuccessEventID -Type Success -Message "Service [$($Service)] is [$($TargetStatus)]"
                    $result = $NormalReturnCode
                    Break ForLoop

                    } else {
                    Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] is not [$($TargetStatus)]"
                    }
                }

            2 {
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] reports access denied."
                }

            5 { 
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] can not accept control at this time."
                } 
            
            10 {
                Write-Log -Id $WarningEventID -Type Warning -Message "Service [$($Service)] is already [$($TargetStatus)]"
                $result = $WarningErrorCode
                Break ForLoop
                }
              
            DEFAULT {
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] reports ERROR $($return.returnvalue)"
                } 
    }  
    
    IF ($i -ge $RetryTimes) {
        Write-Log -Id $ErrorEventID -Type Error -Message "Although retry specified times, service [$($Service)] status is not switched to [$($TargetStatus)]"
        Break
        }

      #チェック回数の上限に達していない場合は、指定秒待機

      Write-Log -Id $InfoEventID -Type Information -Message ("Serivce [$($Service)] exists and service status dose not switch to [$($TargetStatus)] " +
        "Wait for $($RetrySpanSec) seconds. Retry [" + ($i+1) + "/$RetryTimes]")
      Start-Sleep -Seconds $RetrySpanSec
}

Finalize $result
