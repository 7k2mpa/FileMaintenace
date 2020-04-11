#Requires -Version 3.0

<#
.SYNOPSIS
This script control N2WS backup job with python CLI.
CommonFunctions.ps1 is required.

.DESCRIPTION
This script control N2WS backup job with python CLI.
CommonFunctions.ps1 is required.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 

.EXAMPLE

N2WSbackup.ps1 -PolicyName SERVER1_policy -Job Request

Request to start backup policy name [SERVER1_policy]

.EXAMPLE

N2WSbackup.ps1 -PolicyName SERVER1_policy -Job GetResult

Get result of latest backup job backup of policy name [SERVER1_policy]


.PARAMETER PolicyName

Sepcify the policy name in N2WS backup policies.
Specification is required.

.PARAMETER Job

Specify job type [Request] to start new backup job or [GetResult] the result of latest backup job.
[GetResult] is default.

.PARAMETER RetryInterval

Specify checking interval the result of the job in seconds.
[60] seconds is default.

.PARAMETER MaxRetry      = 90 ,

Specify how many times to check the result of the job.
[90] times is default.

.PARAMETER N2WScliPath

Specify the path of the N2WS CLI folder path.
Relative or absolute path format is allowed.

.PARAMETER BackUpLogPath 

Specify the path of the folder of temporaly backup log files saved.
Relative or absolute path format is allowed.


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

.LINK

https://github.com/7k2mpa/FileMaintenace

#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
Param(

[String][Parameter(position = 0, mandatory)]$PolicyName  ,   

[String][Parameter(position = 1)][ValidateSet("Request", "GetResult")]$Job = 'GetResult',


[int][Parameter(position = 2)][ValidateRange(1,120)]$RetryInterval = 60 ,
[int][Parameter(position = 3)][ValidateRange(1,120)]$MaxRetry      = 90 ,

[String]$N2WScliPath = "D:\N2WS" ,
[String]$BackUpLogPath = "..\tmp\" ,

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
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default for ShiftJIS

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


################ It is up to this line that you need to configuration. ##################


################# functions #######################


function Test-N2WS {	

[OutputType([PSObject])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory)]$PolicyName ,
[String][parameter(position = 1)]$Date = "" ,

[String]$BackUpTempPath = $BackUpTempPath ,
[String]$N2WScliPath = $N2WScliPath
)

begin {
}
process {

Push-Location $N2WScliPath

    try {

        IF ($Date -eq "") {

            $return = python.exe cpm_cli.py get-backup-by-time --policy $PolicyName

            } else {

            $return = python.exe cpm_cli.py get-backup-by-time --policy $PolicyName --backup-time $Date
            Write-Output $return | Out-File $BackUpTempPath
            }

Write-Verbose $return

Pop-Location

        $id = $return | ConvertFrom-Json

#N2WS 2.5 return typo messeage!! [Cound not find policy] , thus do not match 'Could not find policy' orz

        IF (($id.Message -match 'not find policy') -or ($id."backup-id" -eq -1)) {

            Write-Log -Id $ErrorEventID -Type Error -Message "Backup policy [$($PolicyName)] dose not exist."
            Finalize $ErrorReturnCode
            
            } else {
            Push-Location $N2WScliPath
            $backup = python.exe cpm_cli.py get-backup-info --backup-id $id."backup-id" | ConvertFrom-Json
            Pop-Location
            }
        }
        
    catch [Exception] {
        Pop-Location
        $errorDetail = $ERROR[0] | Out-String
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to exec cpm_cli.py $($MountDrive)"
	    Finalize $ErrorReturnCode
        }


    IF ($NULL -eq $backup.status) {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to get backup status."
        Finalize $ErrorReturnCode
        }

Write-Output $backup
}
end{
}       
}


function Invoke-N2WSbackup {

[OutputType([boolean])]
[CmdletBinding()]
Param (
[String][parameter(position = 0, mandatory)]$PolicyName ,

[String]$BackUpTempPath = $BackUpTempPath ,
[String]$N2WScliPath = $N2WScliPath ,
[int]$RetryInterval = $RetryInterval ,
[int]$MaxRetry =  $MaxRetry
)

begin {
    $bkupDate = Get-Date -Format yyyy-MM-dd+HH:mm
}
process {

Push-Location $N2WScliPath

    $command = "cpm_cli.py run-backup --policy $PolicyName"

    $return = Start-Process python.exe -ArgumentList $command -Wait -NoNewWindow -PassThru

Pop-Location

    IF ($return.ExitCode -ne 0) {

        Write-Log -Id $ErrorEventID -Type Error -Message "Failed to execute python command [$($command)]"
        $status = $FALSE
        Finalize $ErrorReturnCode
    
        } else {
        Write-Log -Id $SuccessEventID -Type Success -Message "Successfully completed to execute python command [$($command)]"
        }

Start-Sleep -Seconds $RetryInterval


    while ($retryCount -le $MaxRetry) {

        $return = Test-N2WS -Date $bkupDate -PolicyName $PolicyName
            
Write-Verbose $return

            # 対象のバックアップポリシーが実行中又は実行完了となったら終了

        if (($return.status -match "(In Progress|Backup(| Partially) Successful)")) {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Policy [$($PolicyName)] was switched to [$($return.status)]."
            $status = $TRUE
            break                
            }
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Policy [$($PolicyName)] was still [$($return.status)]. Wait for [$($RetryInterval)] seconds. Retry [$($retryCount)/$($MaxRetry)]"
        Start-Sleep -Seconds $RetryInterval
        $retryCount++            
        }
           

    IF ($retryCount -gt $MaxRetry) {

        Write-Log -Id $ErrorEventID -Type Error -Message "Retried specified times, but did not switch to 'In Progress' or 'Backup Successful' Retry over."
        $status = $FALSE
        }

Write-Output $status
}
end {
}
}


function Test-N2WSresult {

[OutputType([boolean])]
[CmdletBinding()]

Param (
[String][parameter(position = 0, mandatory)]$PolicyName ,

[String]$BackUpTempPath = $BackUpTempPath ,
[String]$N2WScliPath = $N2WScliPath ,
[int]$RetryInterval = $RetryInterval ,
[int]$MaxRetry =  $MaxRetry
)

begin {
}
process {
    $BackUpTempPath | Test-Leaf -Name 'BackUp log file ' -IfNoExistFinalize >$NULL	

    $id = Get-Content -Path $BackUpTempPath | ConvertFrom-Json

    IF (($id.Message -match 'not find policy') -or ($id."backup-id" -eq -1)) {

        Write-Log -Id $ErrorEventID -Type Error -Message "Backup policy [$($PolicyName)] dose not exist."
        Finalize $WarningReturnCode
        }

    while ($retryCount -le $MaxRetry) {

        Push-Location $N2WScliPath

        $return = python.exe cpm_cli.py get-backup-info --backup-id $id."backup-id" | ConvertFrom-Json

        Pop-Location

Write-Verbose $return
 
        IF ($return.status -match '^(Backup(| Partially) Successful)$') {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Policy [$($PolicyName)] ID [$($id."backup-id")] was switched to [$($return.status)]."
            $status = $TRUE
            break
                
            } elseIF ($NULL -eq $return.Status) {

                Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to get backup status."
                $status = $FLASE
                break

                } else {
                $retryCount++
                Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Policy [$($PolicyName)] ID [$($id."backup-id")] was still [$($return.status)]. Wait for [$($RetryInterval)] seconds. Retry [$($retryCount)/$($MaxRetry)]"
                Start-Sleep -Seconds $RetryInterval
                }            
        }
           
        # リトライオーバー判定
        IF ($retryCount -gt $MaxRetry) {
                
            Write-Log -Id $ErrorEventID -Type Error -Message "Retried specified times, but did not switch to 'Backup Successful' or 'Backup Partially Successful' Retry over."
            $status = $FALSE
            }

Write-Output $status
}
end {
}
}


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

    $N2WScliPath = $N2WScliPath | ConvertTo-AbsolutePath -Name '-N2WScliPath'

    $N2WScliPath | Test-Container -Name '-N2WScliPath' -IfNoExistFinalize > $NULL


    $BackUpLogPath = $BackUpLogPath | ConvertTo-AbsolutePath -Name '-BackUpLogPath'

    $BackUpLogPath | Test-Container -Name '-BackUpLogPath' -IfNoExistFinalize > $NULL

    
    IF ($NULL -eq (Get-Command Python.exe -ErrorAction SilentlyContinue).path) {

        Write-Log -Id $ErrorEventID -Type Error -Message "Failed to get path of Python.exe"
        Finalize $ErrorReturnCode

        } else {
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage ("Python exists and the path is [" + ((Get-Command Python.exe).Path) +"]")
        }

    IF ((Test-N2WS -PolicyName $PolicyName).Status -eq "In Progress") {

        IF ($Job -eq 'Request') {

            Write-Log -Id $WarningEventID -Type Warning -Message "Policy [$($PolicyName)] backup in progress, thus can not request new backup."
            Finalize $WarningReturnCode            
            }        
        }
    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Policy [$($PolicyName)] exists."


#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to [$($Job)] N2WS backup policy [$($PolicyName)]"

}

function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)


 Invoke-PostFinalize $ReturnCode


}

##################### Main ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-beta.12"


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

[String]$BackUpTempPath = $BackUpLogPath | Join-Path -ChildPath "backup-info_$PolicyName.txt" 

Switch -Regex ($Job) {

    'Request' {

        IF (Invoke-N2WSbackup -PolicyName $PolicyName) {
    
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to start N2WS BackUp [$($PolicyName)]"
            $status = $NormalReturnCode
    
            } else {
            $status = $ErrorReturnCode
            }
        }

    'GetResult' {
    
        IF (Test-N2WSresult -PolicyName $PolicyName) {
    
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to finish N2WS BackUp [$($PolicyName)]"
            $status = $NormalReturnCode
    
            } else {
            $status = $ErrorReturnCode
            }
        }
    Default {
        Write-Log -ID $InternalErrorEventID -Type Error -Message "Internal Error at Switch section. It may cause a bug in regex."
        $status = $InternalErrorReturnCode
        }    
}

Finalize $status
