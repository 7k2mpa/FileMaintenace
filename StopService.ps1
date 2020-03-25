﻿#Requires -Version 3.0


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
　Windows Event Logへの出力を制御します。
デフォルトは$TRUEでEvent Log出力します。

.PARAMETER NoLog2EventLog
　Event Log出力を抑止します。-Log2EventLog $FALSEと等価です。

.PARAMETER ProviderName
　Windows Event Log出力のプロバイダ名を指定します。デフォルトは[Infra]です。

.PARAMETER EventLogLogName
　Windows Event Log出力のログ名をしています。デフォルトは[Application]です。

.PARAMETER Log2Console 
　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console
　コンソールログ出力を抑止します。-Log2Console $FALSEと等価です。

.PARAMETER Log2File
　ログフィルへの出力を制御します。デフォルトは$FALSEでログファイル出力しません。

.PARAMETER NoLog2File
　ログファイル出力を抑止します。-Log2File $FALSEと等価です。

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


Param(

[String][parameter(position=0, mandatory=$true , HelpMessage = 'Enter Service name (ex. spooler) To View all help , Get-Help StartService.ps1')]$Service  ,

#[String][parameter(position=1 , mandatory=$true)][ValidateSet("Running", "Stopped")]$TargetStatus , 
#[String][parameter(position=1)][ValidateSet("Running", "Stopped")]$TargetStatus = 'Running', 
[String][parameter(position=1)][ValidateSet("Running", "Stopped")]$TargetStatus = 'Stopped', 


[int][parameter(position=2)][ValidateRange(1,65535)]$RetrySpanSec = 3,
[int][parameter(position=3)][ValidateRange(1,65535)]$RetryTimes = 5,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $FALSE,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath ,
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
    Catch [Exception] {
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

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#パラメータの確認


    IF (-not(Test-ServiceExist -ServiceName $Service -NoMessage)) {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Service [$($Service)] dose not exist."
        Finalize $ErrorReturnCode
        }


     IF ($TargetStatus -notmatch '(Running|Stopped)') {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "-TargetStatus is invalid."
        Finalize $ErrorReturnCode   
        }


    IF (Test-ServiceStatus -ServiceName $Service -Health $TargetStatus -Span 0 -UpTo 1 ) {
        Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Service [$($Service)] status is already [$($TargetStatus)]"
        Finalize $WarningReturnCode
        }
        



#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Starting to change Service [$($Service)] status."

}


function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)


EndingProcess $ReturnCode


}


#####################   ここから本体  ######################

$DatumPath = $PSScriptRoot

$Version = '20200207_1615'

[String]$computer = "localhost" 
[String]$class = "win32_service" 
[Object]$WmiService = Get-WMIobject -Class $class -computer $computer -filter "name = '$Service'" 


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
        Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage 'Internal Error. $TargetStatus is invalid.'
        Finalize $InternalErrorReturnCode
        } 
 }



#以下のコードはMSのサンプルを参考
#MICROSOFT LIMITED PUBLIC LICENSE version 1.1
#https://gallery.technet.microsoft.com/scriptcenter/aa73bb75-38a6-4bd4-b72e-a6aede76d6ad
#https://devblogs.microsoft.com/scripting/hey-scripting-guy-how-can-i-use-windows-powershell-to-stop-services/


For ( $i = 0 ; $i -lt $RetryTimes ; $i++ ) {

      # サービス存在確認
      IF (-not(Test-ServiceExist $Service)) {
          Finalize $ErrorReturnCode
          }

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "With WMIService.(start|stop)Service , starting to change Service [$($Service)] status from [$($originalStatus)] to [$($TargetStatus)]"

    Switch -Regex ($TargetStatus) {
 
        'Stopped' {
            IF ($WMIService.AcceptStop) {
                $return = $WMIService.stopService()
                } else {
                Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Service [$($Service)] will not accept a stop request. Wait for $($RetrySpanSec) seconds."
                Start-Sleep $RetrySpanSec
                Continue
                }
            }
    
        'Running' {

            #https://docs.microsoft.com/ja-jp/windows/win32/cimwin32prov/win32-service
            #No AcceptStart Class

            $return = $WMIService.startService()
            }

        Default {
            Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage 'Internal Error. $TargetStatus is invalid. '
            Finalize $InternalErrorReturnCode    
            }
    }



     Switch ($return.returnvalue) {
        
            0 {
                $serviceStatus = Test-ServiceStatus -ServiceName $Service -Health $TargetStatus -Span $RetrySpanSec -UpTo $RetryTimes

                IF ($serviceStatus) {
                    Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Service [$($Service)] is [$($TargetStatus)]"
                    Finalize $NormalReturnCode
                    } else {
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Service [$($Service)] is not [$($TargetStatus)] Retry."
                    }
                }


            2 {
                Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Service [$($Service)] reports access denied."
                }

            5 { 
                Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Service [$($Service)] can not accept control at this time."
                } 
            
            10 {
                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Service [$($Service)] is already [$($TargetStatus)]"
                Finalize $WarningErrorCode
                }
              
            DEFAULT {
                Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Service [$($Service)] reports ERROR $($Return.returnValue)"
                } 
      }  
    

      #チェック回数の上限に達していない場合は、指定秒待機

      Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Serivce [$($Service)] exists and service status dose not change to [$($TargetStatus)] Wait for $($RetrySpanSec) seconds."
      Start-Sleep $RetrySpanSec
}

Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Although waiting predeterminated times , service [$($Service)] status is not change to [$($TargetStatus)]"
Finalize $ErrorReturnCode