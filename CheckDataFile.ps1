#Requires -Version 3.0

<#
.SYNOPSIS

This script validates file interface system.
CommonFunctions.ps1 is required.



.DESCRIPTION

This script validates file interface system.

The file interface system has 2 files, trigger file and data file.
A trigger file has number in the 1st line. A number is number of the data lines in the data file.
The data file has text datum.

This script compares the number in the trigger file and number of the data lines in the data file for validating file interface system.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to suppress or to output individually. 



.EXAMPLE

.\CheckDataFile.ps1 -TriggerPath .\Trigger.txt -DataPath .\data.txt

Check existence of the trigger file (Trigger.txt)
If the trigger file dose not exist, return WarningReturnCode
If the trigger file exists, try load a data file (data.txt) 
If the data file dose not exist, return InternalErrorReturnCode

If a data file exists, count lines in the data file.
If number of the lines in the data file is equal to the number in the 1st line of trigger file, retuen NormalReturnCode, else return ErrorReturnCode



.PARAMETER TriggerPath

Specify a trigger files path.
Specification is required.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


.PARAMETER DataPath

Specify a data files path.
Specification is required.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


.PARAMETER CommandFileEncode

Specify encode chracter code in the Trigger file.
[Default(ShitJIS)] is default.



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

[String]
[parameter(position = 0, mandatory, HelpMessage = 'Specify path of Trigger File or Get-Help Wrapper.ps1')]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("Path","LiteralPath","FullName")]$TriggerPath ,

[String]
[parameter(position = 1, mandatory, HelpMessage = 'Specify path of Data File or Get-Help Wrapper.ps1')]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$DataPath ,

[String]
[parameter(position = 2)]
[ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default' , #Default works as ShiftJIS



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
# If you want to place CommonFunctions.ps1 in differnt path, modify

Try{
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
Catch [Exception]{
    Write-Output "Fail to load CommonFunctions.ps1 Please verify existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }

#!!! end of definition !!!


################# functions  #######################

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

    $TriggerPath = $TriggerPath | ConvertTo-AbsolutePath -Name '-TriggerPath'

    IF (-not($TriggerPath | Test-PathEx -Type Leaf -Name '-TriggerPath')) {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Trigger file dose not exist, thus terminate with a Warning."
        Finalize -ReturnCode $WarningReturnCode    
        }

    $DataPath = $DataPath | ConvertTo-AbsolutePath -Name '-DataPath'

    IF (-not($DataPath | Test-PathEx -Type Leaf -Name '-DataPath')) {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Although the data file dose not exist, the trigger file exists, thus terminate with an InternalError."
        Finalize -ReturnCode $InternalErrorReturnCode
        }


#output starting messages

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to compare number of lines in the data file with a number in the trigger file."

}

function Finalize {

Param(
[parameter(position = 0, mandatory)][int]$ReturnCode
)


 Invoke-PostFinalize $ReturnCode
}


#####################  main  ######################

$DatumPath = $PSScriptRoot

$Version = "2.1.0-beta.2"

#initialize, validate parameters, output starting message

. Initialize


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Try to read 1st line and get number in the trigger file."

    Try {
        $trigger = [int](Get-Content -Path $TriggerPath -Encoding $CommandFileEncode -TotalCount 1  -ErrorAction Stop)
        }

        catch [Exception] {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to load -TriggerPath [$($TriggerPath)]"
        $errorDetail = $Error[0] | Out-String
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
        Finalize -ReturnCode $ErrorReturnCode
        }

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Specified number of lines in the trigger file is [$($trigger)]"


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Try to get number of lines in the data file."

    Try {

        [Array]$data = @(Get-Content $DataPath -Encoding $CommandFileEncode -ErrorAction Stop)  
        }
        
        catch [Exception] {
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to load -DataPath [$($DataPath)]"
            $errorDetail = $ERROR[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize -ReturnCode $ErrorReturnCode
            }

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Number of lines in the data file is [$($data.Count)]"


Write-Debug "trigger[$($trigger.GetType().FullName)]"
Write-Debug "data[$data]"


IF ($data.count -eq $trigger) {

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Number of lines in the data file is same number specified in the trigger file."
    $result = $NormalReturnCode
    
    } else {    
    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Number of lines in the data file is diffrent from number specified in the trigger file."
    $result = $ErrorReturnCode
    }


Finalize -ReturnCode $result
