#Requires -Version 3.0

<#
.SYNOPSIS

This script executes the program specified with arguments in the specified config file.
Untill Ending with Normal, executes specified times every specified seconds.  

CommonFunctions.ps1 is requied.



.DESCRIPTION

This script executes the program specified with arguments in the specified config file.
Untill Ending with Normal, executes specified times every specified seconds.  

If the program exit with Normal return code, this script exit with Normal return code.

If the program exit with Warning return code, this script execute specified times every specified seconds.  
And if the program exit wirt Warning return code after exections, this script exit with Warning return code.

If the program exit with Error return code, this script exit with Error return code.

The configuration file can be set arbitrarily.
1st line of the configuration file is used to execute the program.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to suppress or to output individually. 


Sample Configuration file.

Save blow to LoopWrapperCommand.txt
Execute this script with argument -CommandPath .\CheckFlag.ps1 -CommandFile .\LoopWrapperCommand.txt
---
-CheckFolder .\Lock -CheckFile BkupDB.flg
---



.EXAMPLE

LoopWrapper.ps1 -CommandPath .\CheckFlag.ps1 -CommandFile .\Command.txt

Execute CheckFlag.ps1 in the same folder with arugument 1st line of Command.txt

If CheckFlag.ps1 end as Normal, this program exits as Normal.

CheckFlag.ps1 test a flag file and if a flag file dose not exist, CheckFlag.ps1 ends as Normal,
if a flag file exists, CheckFlag.ps1 end with error.

With this configuration, untill this script execute CheckFlag.ps1 specified times.
After specified times, this script end as Warning.

If CheckFlag.ps1 ends with error, this script ends with error.


.EXAMPLE

LoopWrapper.ps1 -CommandPath .\CheckFlag.ps1 -CommandFile .\Command.txt -Span 60 -UpTo 120

Execute CheckFlag.ps1 in the same folder with arugument 1st line of Command.txt

If CheckFlag.ps1 end as Normal, this program exits as Normal.

CheckFlag.ps1 test a flag file and if a flag file dose not exist, CheckFlag.ps1 ends as Normal,
if a flag file exists, CheckFlag.ps1 end with error.

With this configuration, untill this script execute CheckFlag.ps1 120 times every 60 seconds.
After specified times, this script end with warning.

If CheckFlag.ps1 ends with error, this script ends with error.



.PARAMETER CommandPath

Specify the path of script to execute.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


.PARAMETER CommandFile

Specify the path of command file with arguments.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


.PARAMETER CommandFileEncode

Specify encode chracter code in the command file.
[Default(ShitJIS)] is default.


.PARAMETER Span

Specify how log waiting for retry the script execution in seconds.
[10]secnods is default


.PARAMETER UpTo

Specify how many times to execute the script.
[1000times] is default.


.PARAMETER Continue

If you want to execute script again with argument 1st line in the command file ending the script with error.
[This script ends with error] is default.



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


.PARAMETER ExecutableUserTEST

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

Param(

[String]
[parameter(position = 0, mandatory, HelpMessage = 'Specify path of PowerShell script to execute(ex. .\FileMaintenance.ps1)  or Get-Help Wrapper.ps1')]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("Path","LiteralPath","FullName")]$CommandPath ,

[String]
[parameter(position = 1, mandatory, HelpMessage = 'Specify path of command file including arguments(ex. .\Command.txt)  or Get-Help Wrapper.ps1')]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("CommandFilePath")]$CommandFile ,


[parameter(position = 2)][ValidateRange(1,65535)][int]$Span = 10 ,
[parameter(position = 3)][ValidateRange(1,65535)][int]$UpTo = 1000 ,

[Switch]$Continue ,

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default' , #Default指定はShift-Jis



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

#!!! end of defenition !!!


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


#validate executing command's path

$CommandPath = $CommandPath |
                ConvertTo-AbsolutePath -ObjectName '-CommandPath' | 
                Test-PathEx -Type Leaf -Name '-CommandPath' -IfFalseFinalize -PassThrough

                
#validate command file path

$CommandFile = $CommandFile |
                ConvertTo-AbsolutePath -ObjectName '-CommandFile' | 
                Test-PathEx -Type Leaf -Name '-CommandFile' -IfFalseFinalize -PassThrough


#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to execute command [$($CommandPath)] with arguments [$($CommandFile)]"

}

function Finalize {

Param(
[parameter(position = 0, mandatory)][int]$ReturnCode
)




 Invoke-PostFinalize $ReturnCode

}


#####################  main  ######################

$DatumPath = $PSScriptRoot

$Version = "2.1.0-beta.1"


#initialize, validate parameters, output starting message

. Initialize


    Try {
        $line = @(Get-Content -Path $CommandFile -Encoding $CommandFileEncode -TotalCount 1  -ErrorAction Stop)
        }

        catch [Exception] {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to load -CommandFile"
        $errorDetail = $Error[0] | Out-String
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
        Finalize $ErrorReturnCode
        }




For ( $i = 1 ; $i -le $UpTo ; $i++ ) {

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute 1st line in [$($CommandFile)]"
    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Try times [$($i)/$($UpTo)]"

        Try {
        
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute command [$($CommandPath)] with arguments [$($line)]"
            Invoke-Expression "$CommandPath $Line" -ErrorAction Stop

            }

            catch [Exception] {

            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute [$($CommandPath)]"
            $errorDetail = $Error[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
            }

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Result of execution [$($CommandFile)] is [$($LASTEXITCODE)]"
                    

        #終了コードで分岐
        Switch ($LastExitCode) {

                        #条件1 異常終了
                        {$_ -ge $ErrorReturnCode} {
 
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "An ERROR termination occurred at line 1 in -CommandFile [$($CommandFile)]"
       
                            IF ($Continue) {
                                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Will try again, because option -Continue[$($Continue)] is used." 
                                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Wait for [$($Span)] seconds."
                                Start-Sleep -Seconds $Span
                                Break     
     
                                } else {
                                Finalize $ErrorReturnCode
                                }
                            }

                    
                        #条件2 警告終了
                        {$_ -ge $WarningReturnCode} {
                            

                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "A WARNING termination occurred at line 1 in [$($CommandFile)] , will try again. " 
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Waint for [$($Span)] seconds."
                            Start-Sleep -Seconds $Span                             
                            }

                        
                        #条件3 正常終了
                        Default {

                            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Completed successfully in [$($i)] times try."                        
                            Finalize $NormalReturnCode
                            }
        }
    
  

#対象群の処理ループ終端
}

Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Although with [$($UpTo)] times retry, did not complete successfully. Thus terminate with warning." 

Finalize $WarningReturnCode
