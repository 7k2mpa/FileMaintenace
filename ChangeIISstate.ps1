﻿#Requires -Version 3.0


<#
.SYNOPSIS
指定したサービスを停止するプログラムです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているFileMaintenance.ps1と併用すると複数のサービスを一括停止できます。

<Common Parameters>はサポートしていません

.DESCRIPTION

指定したサービスを停止するプログラムです。
停止済サービスを停止指定すると警告終了します。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。


.EXAMPLE
StartService.ps1 -Service Spooler -RetrySpanSec 5 -RetryTimes 5

サービス名:Spooler（表示名はPrint Spooler）を停止します。
直ぐに停止しない場合は、5秒間隔で最大5回試行します。

停止済サービスを停止しようとした場合は、警告終了します。



.EXAMPLE
StartService.ps1 -Service Spooler -RetrySpanSec 5 -RetryTimes 5 -WarningAsNormal

サービス名:Spooler（表示名はPrint Spooler）を停止します。
直ぐに停止しない場合は、5秒間隔で最大5回試行します。

停止済サービスを停止しようとした場合は、正常終了します。



.PARAMETER Service
　停止するサービス名を指定します。
「サービス名」と（サービスの）「表示名」は異なりますので留意して下さい。。
例えば「表示名:Print Spooler」は「サービス名:Spooler」となっています。
指定必須です。

.PARAMETER RetrySpanSec
　サービス停止再確認の間隔秒数を指定します。
サービスによっては数秒必要なものもあるので適切な秒数に設定して下さい。
デフォルトは3秒です。

.PARAMETER RetryTimes
　サービス停止再確認の回数を指定します。
サービスによっては数秒必要なものもあるので適切な回数に設定して下さい。
デフォルトは5回です。





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

[String][parameter(position=0, mandatory=$true , HelpMessage = 'Enter IIS site name. To view all help , Get-Help ChangeIIS.ps1')]$Site ,

[String][parameter(position=1)][ValidateSet("Started", "Stopped")]$TargetState = 'Stopped' , 
[int][parameter(position=2)][ValidateRange(1,65535)]$RetrySpanSec = 3,
[int][parameter(position=3)][ValidateRange(1,65535)]$RetryTimes = 5,


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

$SHELLNAME=Split-Path $PSCommandPath -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#パラメータの確認

    IF(-NOT(CheckServiceExist -ServiceName 'W3SVC')){
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Web Service [W3SVC] dose not exist."
        Finalize $ErrorReturnCode
        }
 
     IF($TargetState -notmatch ' ^(Started|Stopped)$'){
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "-TargetState is invalid."
        Finalize $ErrorReturnCode   
        }
       

    IF(Get-Website | Where-Object{$_.Name -ne $Site}){
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Site [$($Site)] dose not exist."
        Finalize $ErrorReturnCode
        }


    IF (Get-Website | Where-Object{$_.Name -eq $Site} | Where-Object {$_.State -eq $TargetState}){
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "Site [$($Site)] state is already [$($TargetState)]."
        Finalize $WarningReturnCode
        }
        



#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Logging -EventID $InfoEventID -EventType Information -EventMessage "Starting to change IIS Site [$($Site)] state."

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


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize


 Switch -Regex ($TargetState){
 
    'Stopped'{
        $OriginalState = 'Started'    
    }
    
    'Started'{
        $OriginalState = 'Stopped'
    }

    Default{
        Logging -EventID $InternalErrorEventID -EventType Error -EventMessage 'Internal Error. $TargetState is invalid. '
        Finalize $InternalErrorReturnCode
    
    }
 
 
 }


Logging -EventID $InfoEventID -EventType Information -EventMessage "With Powershell Cmdlet , Starting to change site [$($Site)] state from [$($OriginalState)] to [$($TargetState)]"
        
 Switch -Regex ($TargetState){
 
    'Stopped'{
        Stop-Website -Name $Site
    }
    
    'Started'{
        Start-Website -Name $Site
    }

    Default{
        Logging -EventID $InternalErrorEventID -EventType Error -EventMessage 'Internal Error. $TargetState is invalid. '
        Finalize $InternalErrorReturnCode
    
    }
    }


# カウント用変数初期化
$Counter = 0

    # 無限ループ
    While ($true) {

      # チェック回数カウントアップ
      $Counter++

      $SiteState = Get-Website | Where-Object{$_.Name -eq $Site} | ForEach-Object{$_.State}

           Switch ($SiteState)  {
        
                $TargetState{

                    Logging -EventID $SuccessEventID -EventType Success -EventMessage "Site[$($Site)] state was [$($SiteState)]."
                    Finalize $NormalReturnCode
                    

                }


                $OriginalState {
                Logging -EventID $InfoEventID -EventType Information -EventMessage "Site [$($Site)] state is still [$($SiteState)]. "
                }

              
                DEFAULT {
                Logging -EventID $InfoEventID -EventType Information -EventMessage "Site [$($site)] state is [$($SiteState)]"
                } 
            }  
    





        IF ($Counter -eq $RetryTimes){ 
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Although waiting predeterminated times , site [$($Site)] state did not change to [$($TargetState)]."
        Finalize $ErrorReturnCode
        }

      #チェック回数の上限に達していない場合は、指定秒待機

      Logging -EventID $InfoEventID -EventType Information -EventMessage "Site [$($Site)] exists and site state did not change to [$($TargetState)]. Wait for $($RetrySpanSec) seconds."
      Start-Sleep $RetrySpanSec

      # 無限ループに戻る

    }
