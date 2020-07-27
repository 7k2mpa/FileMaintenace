#Requires -Version 3.0

<#
.SYNOPSIS

This script controls N2WS backup job with python CLI.
CommonFunctions.ps1 is required.



.DESCRIPTION

This script controls N2WS backup job with python CLI.
CommonFunctions.ps1 is required.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to suppress or to output individually. 



.EXAMPLE

N2WSbackup.ps1 -PolicyName SERVER1_policy -Job Request

Request to start backup policy name [SERVER1_policy]


.EXAMPLE

N2WSbackup.ps1 -PolicyName SERVER1_policy -Job GetResult

Get result of latest backup job backup of policy name [SERVER1_policy]


.PARAMETER PolicyName

Sepcify a policy name in N2WS backup policies.
Specification is required.


.PARAMETER Job

Specify job type [Request] to start new backup job or [GetResult] of latest backup job.
[GetResult] is default.


.PARAMETER RetryInterval

Specify checking interval the result of the job in seconds.
[60] seconds is default.


.PARAMETER MaxRetry

Specify how many times to check the result of the job.
[90] times is default.


.PARAMETER N2WScliPath

Specify the path of the N2WS CLI folder path.
Relative or absolute path format is allowed.


.PARAMETER BackUpLogPath 

Specify the path of the folder of temporaly backup log files saved.
Relative or absolute path format is allowed.



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

#!!! start of definition !!!#
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
Param(

[String][Parameter(position = 0, mandatory, HelpMessage = 'Enter policy name in N2WS console. To View all help, Get-Help N2WSBackUp.ps1')]$PolicyName ,   

[String][Parameter(position = 1)][ValidateSet("Request", "GetResult")]$Job = 'GetResult' ,

[String][Parameter(position = 2)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$N2WScliPath = "D:\N2WS" ,

[String][Parameter(position = 3)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$BackUpLogPath = "..\tmp\" ,

[int][Parameter(position = 4)][ValidateRange(1,120)]$RetryInterval = 60 ,
[int][Parameter(position = 5)][ValidateRange(1,120)]$MaxRetry      = 90 ,



#[String][ValidatePattern('^(\.+\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommonConfigPath = '.\CommonConfig.ps1' , #MUST specify with relative path format
[String][ValidatePattern('^(\.+\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommonConfigPath = $NULL ,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String][ValidateNotNullOrEmpty()]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

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
# If you want to place CommonFunctions.ps1 in differnt path, modify

Try {
    ."$PSScriptRoot\CommonFunctions.ps1"

    IF ($LASTEXITCODE -eq 99) {
        Exit 1
    }
}
Catch [Exception] {
    Write-Error "Fail to load CommonFunctions.ps1 Please verify existence of CommonFunctions.ps1 in the same folder."
    Exit 1
}

#!!! end of definition !!!


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
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to exec cpm_cli.py $($PolicyName)"
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


    for ($retryCount = 0 ; $retryCount -le $MaxRetry ; $retryCount++) {

        $return = Test-N2WS -Date $bkupDate -PolicyName $PolicyName
            
Write-Verbose $return

#If BackUp policy is switched to In Progress or Successful, end

        IF (($return.status -match "(In Progress|Backup(| Partially) Successful)")) {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Policy [$($PolicyName)] was switched to [$($return.status)]."
            $status = $TRUE
            Break                
            }

        IF ($retryCount -ge $MaxRetry) {

            Write-Log -Id $ErrorEventID -Type Error -Message "Retried specified times, but did not switch to 'In Progress' or 'Backup (Partially) Successful' Retry over."
            $status = $FALSE
            Break
            }

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage ("Policy [$($PolicyName)] was still [$($return.status)]. " +
            "Wait for [$($RetryInterval)] seconds. Retry [" + ($retryCount+1) + "/$($MaxRetry)]")
        Start-Sleep -Seconds $RetryInterval
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
    $BackUpTempPath | Test-PathEx -Type Leaf -Name 'BackUp log file ' -IfFalseFinalize >$NULL	

    $id = Get-Content -Path $BackUpTempPath | ConvertFrom-Json

    IF (($id.Message -match 'not find policy') -or ($id."backup-id" -eq -1)) {

        Write-Log -Id $ErrorEventID -Type Error -Message "Backup policy [$($PolicyName)] dose not exist."
        Finalize $WarningReturnCode
        }

    for ($retryCount = 0 ; $retryCount -le $MaxRetry ; $retryCount++) {

        Push-Location $N2WScliPath

        $return = python.exe cpm_cli.py get-backup-info --backup-id $id."backup-id" | ConvertFrom-Json

        Pop-Location

Write-Verbose $return
 
        IF ($return.status -match '^(Backup(| Partially) Successful)$') {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Policy [$($PolicyName)] ID [$($id."backup-id")] was switched to [$($return.status)]."
            $status = $TRUE
            break
            }
                    
        IF ($NULL -eq $return.Status) {

            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to get backup status."
            $status = $FALSE
            break
            }

        IF ($retryCount -ge $MaxRetry) {
         
            Write-Log -Id $ErrorEventID -Type Error -Message "Retried specified times, but did not switch to 'Backup Successful' or 'Backup Partially Successful' Retry over."
            $status = $FALSE
            Break
            }        

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage ("Policy [$($PolicyName)] ID [$($id."backup-id")] was still [$($return.status)]. " +
            "Wait for [$($RetryInterval)] seconds. Retry [" + ($retryCount+1) + "/$($MaxRetry)]")
        Start-Sleep -Seconds $RetryInterval
            
    }

Write-Output $status
}
end {
}
}


function Initialize {

$ShellName = $PSCommandPath | Split-Path -Leaf

<#
PreInitialization for basic logging functions
Already egistered Event Source in Windows Event Log?
Log File output path
Validate Return Codes
Validate Execution user
Output Script Starting messages
#>
. Invoke-PreInitialize


#If passed PreInitilization, validate only business logics.

#validate parameters

$N2WScliPath = $N2WScliPath |
                    ConvertTo-AbsolutePath -Name '-N2WScliPath' |
                    Test-PathEx -Type Container -Name '-N2WScliPath' -IfFalseFinalize -PassThrough

                    
$BackUpLogPath = $BackUpLogPath |
                    ConvertTo-AbsolutePath -Name '-BackUpLogPath' |
                    Test-PathEx -Type Container -Name '-BackUpLogPath' -IfFalseFinalize -PassThrough

    
    IF ($NULL -eq (Get-Command Python.exe -ErrorAction SilentlyContinue).path) {

        Write-Log -Id $ErrorEventID -Type Error -Message "Failed to get path of Python.exe"
        Finalize $ErrorReturnCode

        } else {
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage ("Python.exe exists and the path is [" + ((Get-Command Python.exe).Path) +"]")
        }

    IF ((Test-N2WS -PolicyName $PolicyName).Status -eq "In Progress") {

        IF ($Job -eq 'Request') {

            Write-Log -Id $WarningEventID -Type Warning -Message "Policy [$($PolicyName)] backup in progress, thus can not request new backup."
            Finalize $WarningReturnCode            
            }        
        }
    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Policy [$($PolicyName)] exists."


#output starting messages

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to [$($Job)] N2WS backup policy [$($PolicyName)]"

}

function Finalize {

Param(
[parameter(position = 0, mandatory)][int]$ReturnCode
)


 Invoke-PostFinalize $ReturnCode


}


##################### Main ######################

$DatumPath = $PSScriptRoot

$Version = "2.1.1"


#initialize, validate parameters, output starting message

. Initialize


[String]$BackUpTempPath = $BackUpLogPath | Join-Path -ChildPath "backup-info_$($PolicyName).txt" 

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

Finalize -ReturnCode $status
