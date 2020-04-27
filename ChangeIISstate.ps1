#Requires -Version 3.0


<#
.SYNOPSIS
Script to Stop or Start IIS site.
CommonFunctions.ps1 is required.
With Wrapper.ps1 start or stop multiple IIS sites.

<Common Parameters> is not supported.

.DESCRIPTION
Script to Stop or Start IIS site.
If start(stop) IIS site already started(stopped), will temrminate with WARNING.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


.EXAMPLE
ChangeIIState.ps1 -Site SSL -TargetState stopped

Stop IIS site 'SSL'


.EXAMPLE
ChangeIIState.ps1 -Site SSL -TargetState started

Start IIS site 'SSL'


.PARAMETER Site
Specify IIS site

.PARAMETER TargetState
Specify IIS site state 'Started' or 'Stopped' 


.PARAMETER RetrySpanSec
　サービス停止再確認の間隔秒数を指定します。
サービスによっては数秒必要なものもあるので適切な秒数に設定して下さい。
デフォルトは3秒です。

.PARAMETER RetryTimes
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

.LINK

https://github.com/7k2mpa/FileMaintenace

#>


Param(

[String][parameter(position = 0, mandatory, HelpMessage = 'Enter IIS site name. To view all help , Get-Help ChangeIISstate.ps1')]$Site ,

[String][parameter(position = 1)][ValidateSet("Started", "Stopped")][Alias("State")]$TargetState = 'Stopped' ,

[int][parameter(position = 2)][ValidateRange(1,65535)]$RetrySpanSec = 3 ,
[int][parameter(position = 3)][ValidateRange(1,65535)]$RetryTimes = 5 ,


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

$ShellName = $PSCommandPath | Split-Path -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. Invoke-PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#パラメータの確認

    IF (-not('W3SVC' | Test-ServiceExist)) {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Web Service [W3SVC] dose not exist."
        Finalize $ErrorReturnCode
        }
 
     IF ($TargetState -notmatch '^(Started|Stopped)$') {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "-TargetState [$($TargetState)] is invalid specification."
        Finalize $ErrorReturnCode   
        }
       

    IF (Get-Website | Where-Object{$_.Name -ne $Site}) {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Site [$($Site)] dose not exist."
        Finalize $ErrorReturnCode
        }


    IF (Get-Website | Where-Object{$_.Name -eq $Site} | Where-Object {$_.State -eq $TargetState}) {
        Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Site [$($Site)] state is already [$($TargetState)]."
        Finalize $WarningReturnCode
        }
        



#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Starting to change IIS Site [$($Site)] state."

}


function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)


 Invoke-PostFinalize $ReturnCode


}


#####################   ここから本体  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.9"


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize


 Switch -Regex ($TargetState) {
 
    'Stopped' {
        $OriginalState = 'Started'    
        }
    
    'Started' {
        $OriginalState = 'Stopped'
        }

    Default {
        Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage 'Internal Error. $TargetState is invalid. '
        Finalize $InternalErrorReturnCode    
        }
 }


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "With Powershell Cmdlet, Starting to switch site [$($Site)] state from [$($OriginalState)] to [$($TargetState)]"
        
    Switch -Regex ($TargetState) {
 
        'Stopped' {
            Stop-Website -Name $Site
            }
    
        'Started' {
            Start-Website -Name $Site
            }

        Default {
            Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage 'Internal Error. $TargetState is invalid. '
            Finalize $InternalErrorReturnCode
            }
    }

$result = $ErrorReturnCode

:ForLoop For ( $i = 0 ; $i -le $RetryTimes ; $i++ ) {

      $siteState = Get-Website | Where-Object{$_.Name -eq $Site} | ForEach-Object{$_.State}

           Switch ($siteState) {
        
                $TargetState {
                    Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Site[$($Site)] state was [$($SiteState)]"
                    $result = $NormalReturnCode
                    Break ForLoop
                    }


                $OriginalState {
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Site [$($Site)] state is still [$($SiteState)]"
                    }

              
                DEFAULT {
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Site [$($site)] state is [$($SiteState)]"
                    } 
            }  
    
    IF ($i -ge $RetryTimes) {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Although waiting specified times , site [$($Site)] state did not switch to [$($TargetState)]"
        Break
        }

    #チェック回数の上限に達していない場合は、指定秒待機

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage ("Site [$($Site)] exists and site state did not change to [$($TargetState)] " +
        "Wait for $($RetrySpanSec) seconds. Retry [" + ($i+1) + "/$RetryTimes]")
    Start-Sleep -Seconds $RetrySpanSec
}

Finalize -ReturnCode $result
