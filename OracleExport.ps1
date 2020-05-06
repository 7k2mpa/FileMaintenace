#Requires -Version 3.0


<#
.SYNOPSIS

This script exports Oracle data with Data Pump.
CommonFunctions.ps1 is required.



.DESCRIPTION

This script exports Oracle data with Data Pump.
CommonFunctions.ps1 is required.

Sample path setting

.\OracleExport.ps1
.\CommonFunctions.ps1



.EXAMPLE

.\OracleExport.ps1 -Schema MCFRAME -DumpDirectoryObject MCFDATA_PUMP_DIR 
Export data of Schema MCFRAME with Oracle Data Pump.
Specify export destination path with Oracle Directory Object named MCDATA_PUMP_DIR 



.PARAMETER Schema

Specify a shcema to export.
Specification is required.


.PARAMETER DumpDirectoryObject

Specify Oracle Directory Object for exporting.
Specification is required.


.PARAMETER AddtimeStamp

Specify if you want to add time stamp to file name.
Time stamp strings are added between filename and extension.

Sample:host_schema_PUMP_yyyyMMdd_HHmmss.dmp


.PARAMETER TimeStampFormat

Specify time stamp format
[_yyyyMMdd_HHmmss] is default


.PARAMETER OracleSID

Specify Oracle_SID for deleting RMAN log.
Should set '$Env:ORACLE_SID' by default.

.PARAMETER OracleHomeBinPath

Specify Oracle 'BIN' path in the child path Oracle home. 
Should set "$Env:ORACLE_HOME +'\BIN'" by default.


.PARAMETER PasswordAuthorization

Specify authentification with password authorization.
Should use OS authentification.
Should use for test only.


.PARAMETER ExecUser

Specify Oracle User to connect. 
Should use OS authentification.


.PARAMETER ExecUserPassword

Specify Oracle user Password to connect. 
Should use OS authentification.


.PARAMETER DumpFile

Specify dump file name.
[$HostName_$Schema_PUMP.dmp] is default.


.PARAMETER LogFile

[HostName_$Schema_PUMP.log] is default.



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



.OUTPUTS

System.Int. Return Code.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
Param(

[String][parameter(position = 0)][ValidateNotNullOrEmpty()]$Schema = 'MCFRAME' ,
[String][parameter(position = 1)][ValidateNotNullOrEmpty()]$DumpDirectoryObject = 'MCFDATA_PUMP_DIR' ,

[String][parameter(position = 2)][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

[String][parameter(position = 3)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$OracleHomeBinPath = $Env:ORACLE_HOME + '\BIN' ,

[String][parameter(position = 4)]$HostName = $Env:COMPUTERNAME,

[String][parameter(position = 5)][ValidatePattern('^(?!.*(\\|\/|:|\?|`"|<|>|\|)).*$')]$TimeStampFormat = '_yyyyMMdd_HHmmss' ,

[Switch]$AddtimeStamp ,

[String]$DumpFile = "$HostName_$Schema_PUMP.dmp" ,
[String]$LogFile  = "$HostName_$Schema_PUMP.log" ,


[String]$ExecUser = 'foo' ,
[String]$ExecUserPassword = 'hogehoge' ,
[Switch]$PasswordAuthorization ,



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

Try {

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

#指定フォルダの有無を確認

    $OracleHomeBinPath = $OracleHomeBinPath | ConvertTo-AbsolutePath -Name  '-OracleHomeBinPath'

    $OracleHomeBinPath | Test-Container -Name '-OracleHomeBinPath' -IfNoExistFinalize > $NULL
    

#対象のOracleがサービス起動しているか確認

    $targetWindowsOracleService = "OracleService" + $OracleSID

    IF (-not($targetWindowsOracleService | Test-ServiceStatus -Status Running)) {

        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "Windows Service [$($targetWindowsOracleService)] is not running or dose not exist."
        Finalize $ErrorReturnCode
        }else{
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Windows Service [$($targetWindowsOracleService)] is running."
        }
     

     

#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to export DB with Oracle data pump command."

}

function Finalize {

Param(
[parameter(mandatory=$TRUE)][int]$ReturnCode
)

Pop-Location

Invoke-PostFinalize $ReturnCode
}

#####################   ここから本体  ######################

$Version = "2.0.0-RC.9"

$DatumPath = $PSScriptRoot


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

    IF ($AddTimeStamp) {

        $DumpFile = $DumpFile | ConvertTo-FileNameAddTimeStamp -TimeStampFormat $TimeStampFormat
        $LogFile  = $LogFile  | ConvertTo-FileNameAddTimeStamp -TimeStampFormat $TimeStampFormat 
        }


    IF ($PasswordAuthorization) {

        $execCommand = "$ExecUser/$ExecUserPassword@$OracleSID Directory=$DumpDirectoryObject Schemas=$Schema DumpFile=$DumpFile LogFile=$LogFile Reuse_DumpFiles=y"
    
        } else {
        $execCommand = "`' /@$OracleSID as sysdba `' Directory=$DumpDirectoryObject Schemas=$Schema DumpFile=$DumpFile LogFile=$LogFile Reuse_DumpFiles=y"
        }

Write-Debug "Command[$($execCommand)]"

Push-Location $OracleHomeBinPath

$process = Start-Process .\EXPDP.exe -ArgumentList $execCommand -Wait -NoNewWindow -PassThru 

IF ($process.ExitCode -ne 0) {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to export DB with Oracle data pump command."
        Finalize $ErrorReturnCode

        } else {
        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to export DB with Oracle data pump command."
        Finalize $NormalReturnCode
        }
