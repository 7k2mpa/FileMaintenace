#Requires -Version 3.0
#If you want to use '-PreAction compress or archive' option in FileMaintenance.ps1, install WMF 5.0 or later, and place '#Requires -Version 5.0' insted of '#Requires -Version 3.0'
#If you want to use '-PreAction compress or archive' option with 7-Zip in FileMaintenance.ps1, do not need to replace.

<#

.SYNOPSIS
This script is used with FileMaintenance.ps1 and others.

.DESCRIPTION
This script is used with FileMaintenance.ps1 and others.
Place this script in the same directory of FileMaintenance.ps1.

This script uses cmdlet Compress-Archive in Invoke-Action function for compression.

But cmdlet Compress-Archive can not handle wild card characters bracket[] for destination path corectly, you should install 7-Zip. This script can use 7-Zip for compress or archive also.

If you want to use '-PreAction compress or archive' option in FileMaintenance.ps1 without installing 7-Zip, install WMF 5.0 or later, and place '#Requires -Version 5.0' insted of '#Requires -Version 3.0'

If you can install 7-Zip for compress or archive, do not need to replace.

You can get the version of this script with '.\CommonFunctions.ps1 -verbose'.


Use commented definitions blow 'Param()' section  for setting variables of log path and etc.
You can specify parameters colletively in CommonFunctions.ps1

Specification priority is


HIGH

 definitions blow Param() section in CommonFunctions.ps1
 arguments of the script
 param section in the scipt

LOW


The scripts have validation functions, but spcification in param section dose not validate.
Remind that dose not specify invalid parameter in param section.



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

[CmdletBinding()]
Param(
)
$Script:CommonFunctionsVersion = "2.1.0-beta.1"
Write-Verbose "CommonFunctions.ps1 Version $CommonFunctionsVersion"

#[boolean]$Log2EventLog = $TRUE ,
#[Switch]$NoLog2EventLog ,
#[String]$ProviderName = "Infra" ,
#[String][ValidateSet("Application")]$EventLogLogName = 'Application' ,

#[boolean]$Log2Console = $TRUE ,
#[Switch]$NoLog2Console ,
#[boolean]$Log2File = $FALSE ,
#[Switch]$NoLog2File ,
#[String][ValidatePattern('^(\.+\\|[C-Z]:\\).*')]$LogPath ,
#[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss" ,
#[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default' , #Default指定はShift-Jis

#[int][ValidateRange(0,2147483647)]$NormalReturnCode        =  0 ,
#[int][ValidateRange(0,2147483647)]$WarningReturnCode       =  1 ,
#[int][ValidateRange(0,2147483647)]$ErrorReturnCode         =  8 ,
#[int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16 ,

#[int][ValidateRange(1,65535)]$InfoEventID          =   1 ,
#[int][ValidateRange(1,65535)]$StartEventID         =   8 ,
#[int][ValidateRange(1,65535)]$EndEventID           =   9 ,
#[int][ValidateRange(1,65535)]$WarningEventID       =  10 ,
#[int][ValidateRange(1,65535)]$SuccessEventID       =  73 ,
#[int][ValidateRange(1,65535)]$InternalErrorEventID =  99 ,
#[int][ValidateRange(1,65535)]$ErrorEventID         = 100 ,

#[Switch]$ErrorAsWarning ,
#[Switch]$WarningAsNormal ,

#[Regex]$ExecutableUser ='.*'



function Write-Log {
<#
.SYNOPSIS
Output Log to Windows Event Log, Console and File.

.DESCRIPTION
Output Log to Windows Event Log, Console and File.

This function can run on PowerShell .Net only, can not run on PowerShell Core.
If you want to run the scripts on PowerShell core, specify -NoLog2EventLog option.

.PARAMETER EVENTID
Specify event id.

.PARAMETER EVENTTYPE
Specify event type.
It is applied to Windows Event Log Level.

.PARAMETER EVENTMESSAGE
Specify message to output logs.

#>
[CmdletBinding()]
Param(
[parameter(position = 0, mandatory)][ValidateRange(1,65535)][int][Alias("ID")]$EventID ,
[parameter(position = 1, mandatory)][String][ValidateSet("Information", "Warning", "Error" ,"Success")][Alias("Type")]$EventType ,
[parameter(position = 2, mandatory)][String][Alias("Message")]$EventMessage ,

[Switch]$Log2EventLog = $Log2EventLog ,
[Switch]$ForceConsoleEventLog = $ForceConsoleEventLog ,
[Switch]$ForceConsole = $ForceConsole ,
[String]$EventLogLogName = $EventLogLogName ,
[String]$ProviderName = $ProviderName ,
[String]$ShellName = $ShellName ,
[Switch]$Log2Console = $Log2Console ,
[Switch]$Log2File = $Log2File ,
[String]$LogDateFormat = $LogDateFormat ,
[String]$LogPath = $LogPath ,
[String]$LogFileEncode = $LogFileEncode
)
begin {
    $logFormattedDate = (Get-Date).ToString($LogDateFormat)    
}
process {
    IF (($Log2EventLog -or $ForceConsoleEventLog) -and -not($ForceConsole) ) {

        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType $EventType -EventId $EventID -Message "[$($ShellName)] $($EventMessage)"
        }


    IF ($Log2Console -or $ForceConsole -or $ForceConsoleEventLog) {

        $consoleWrite = $EventType.PadRight(14) + "EventID " + ([String]$EventID).PadLeft(6) + "  " + $EventMessage
        Write-Host $consoleWrite
        }   


    IF ($Log2File -and -not($ForceConsole -or $ForceConsoleEventLog )) {
       
        $logWrite = $logFormattedDate + " " + $ShellName + " " + $EventType.PadRight(14) + "EventID " + ([String]$EventID).PadLeft(6) + "  " + $EventMessage
        Write-Output $logWrite | Out-File -FilePath $LogPath -Append -Encoding $LogFileEncode
        }   
}
end {
}
}


function Test-ReturnCode {
<#
.SYNOPSIS
Validate magnitude relation of the return codes in parameter section.

.DESCRIPTION
Validate magnitude relation of the return codes in parameter section.

If might be $ErrorReturnCode = 0 , terminate with Exit 1 when an error occure.
#>
    IF (-not(($InternalErrorReturnCode -ge $WarningReturnCode) -and ($ErrorReturnCode -ge $WarningReturnCode) -and ($WarningReturnCode -ge $NormalReturnCode))) {

        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID "The magnitude relation of ReturnCodes' parameters is not set correctly."
        Write-Output "The magnitude relation of ReturnCodes is not set correctly."
        Exit 1
        }
}


function Test-EventLogSource {
<#
.SYNOPSIS
Test existence of the event source in Windows Event Log.

.DESCRIPTION
Test existence of the event source in Windows Event Log.

Regist the new event source if the event source dose not exist.
If might not be able to output event log in sepcified event source, thus force to output log in the console.
#>
    IF ($Log2EventLog) {

        $ForceConsole = $TRUE

        Try {
            IF (-not([System.Diagnostics.Eventlog]::SourceExists($ProviderName) ) ) {

#Register a new event source
           
                New-EventLog -LogName $EventLogLogName -Source $ProviderName  -ErrorAction Stop
                $ForceConsoleEventLog = $TRUE    
                Write-Log -EventId $InfoEventID -Type Information -Message "Regist a new source event [$($ProviderName)] to [$($EventLogLogName)]"
                }
        }
        Catch [Exception] {
        Write-Log -EventId $ErrorEventID -Type Error -Message ("Failed to regist new source event because no source $($ProviderName) exists in event log, " +
            "must have administrator privilage for registing a new source. Start PowerShell with administrator privilage and start the script.")
        Write-Log -EventId $ErrorEventID -Type Error -Message "Execution Error Message : $Error[0]"
        Exit $ErrorReturnCode
        }

        $ForceConsole = $FALSE
        $ForceConsoleEventLog = $FALSE
    }
}


function Test-LogFilePath {
<#
.SYNOPSIS
Test output path of log file.

.DESCRIPTION
Test output path of log file.

If might not be able to output log file, thus force to output log in the event log and console.
#>
    IF ($Log2File) {

        $ForceConsoleEventLog = $TRUE    

        $LogPath | ConvertTo-AbsolutePath -Name '-LogPath' | Test-PathEx -Type Log -Name '-LogPath' -IfFalseFinalize > $NULL
    
        $ForceConsoleEventLog = $FALSE
        }
}


function Invoke-Action {

[CmdletBinding()]    
Param(
[String][parameter(position = 0, mandatory)]
[ValidatePattern("^(Move|Copy|Delete|AddTimeStamp|NullClear|Rename|MakeNew(FileWithValue|Folder)|(7z|7zZip|^)(Compress|Archive)(AndAddTimeStamp|$))$")]
[Alias("Type")]$ActionType,

[String][parameter(position = 1, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
[Alias("Path" , "FullName" , "Source" , "SourcePath")]$ActionFrom ,

[String][parameter(position = 2)][Alias("DestinationPath" , "Destination")]$ActionTo,
[String][parameter(position = 3)][Alias("ErrorPath" , "Error")]$ActionError,
[String][parameter(position = 4)]$FileValue,

$WhatIfFlag = $WhatIfFlag ,
$OverRideFlag = $OverRideFlag ,
$ForceEndLoop = $ForceEndLoop ,
$Continue = $Continue ,
$7zFolder = $7zFolder 

)
begin {
    IF (-not($ActionType -match "^(Delete|NullClear|MakeNewFolder|Rename)$" ) -and ($NULL -eq $ActionTo)) {

        Write-Log -Id $InternalErrorEventID -Type Error -Message "Internal Error at Function Invoke-Action  [$($ActionType)] requires [$($ActionTo)]"
        Finalize $InternalErrorReturnCode
        }

    IF ($ActionType -match '^(Move|Copy|AddTimeStamp|Rename|(7z|7zZip|^)(Compress|Archive)(AndAddTimeStamp|$))$' ) {
        $addMessage = " to [$($ActionTo)]"
        }
}
process {
    IF ($WhatIfFlag -and ($ActionType -match "(Compress|Archive)") ) {
    
        Write-Log -Id $WarningEventID -Type Warning -Message "Specified -WhatIf[$($WhatIfFlag)] option, thus do not execute [$($ActionType)] [$($ActionError)]"
        $Script:NormalFlag = $TRUE

        IF ($OverRideFlag) {
            $Script:OverRideCount++
            $Script:InLoopOverRideCount++
            $Script:OverRideFlag = $FALSE            
            }
        Return
        }
    
    Try {
  
       Switch -Regex ($ActionType) {

        '^(Copy|AddTimeStamp)$' {
            Copy-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $NULL -ErrorAction Stop
            }

        '^(Move|Rename)$' {
            Move-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $NULL -ErrorAction Stop
            }

        '^Delete$' {
            Remove-Item -LiteralPath $ActionFrom -Force > $NULL -ErrorAction Stop
            }
                       
        '^NullClear$' {
            Clear-Content -LiteralPath $ActionFrom -Force > $NULL -ErrorAction Stop
            }

        '^(Compress|CompressAndAddTimeStamp)$' {
#           $ActionTo = $ActionTo -replace "\[" , "````["
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Force > $NULL  -ErrorAction Stop
            }                  
                                       
        '^MakeNewFolder$' {
            New-Item -ItemType Directory -Path $ActionFrom > $NULL  -ErrorAction Stop
            }

        '^MakeNewFileWithValue$' {
            New-Item -ItemType File -Path $ActionFrom -Value $FileValue > $NULL -ErrorAction Stop
            }

        '^(Archive|ArchiveAndAddTimeStamp)$' {
#           $ActionTo = $ActionTo -replace "\[" , "````["
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Update > $NULL  -ErrorAction Stop
            }                  

        '^((7z|7zZip)(Archive|Compress)($|AndAddTimeStamp))$' {

            Push-Location -LiteralPath $7zFolder

            IF ($ActionType -match '7zZip') {
                
                $7zType = 'zip'
                
                } else {
                $7zType = '7z'
                }

            Switch -Regex ($ActionType){
            
                'Compress' {
                    [String]$errorDetail = .\7z.exe a $ActionTo $ActionFrom -t"$7zType" 2>&1
                    Break
                    }

                'Archive' {
                    [String]$errorDetail = .\7z.exe u $ActionTo $ActionFrom -t"$7zType" 2>&1
                    Break
                    }
            
                Default {
                    Pop-Location 
                    Throw "Internal error in 7-Zip Switch section with Action Type"
                    }            
                }

            Pop-Location
            $processErrorFlag = $TRUE
            IF ($LASTEXITCODE -ne 0) {

                Throw "error occure in 7-Zip"            
                }
            }
                                           
        Default {
            Write-Log -Id $InternalErrorEventID -Type Error -Message "Internal Error at Function Invoke-Action. Switch ActionType exception has occurred. "
            Finalize $InternalErrorReturnCode
            }
      }       
   
   
   
    }   
    catch [Exception] {
       
        Write-Log -Id $ErrorEventID -Type Error -Message ("Failed to execute [$($ActionType)] [$($ActionError)]" + $addMessage)
        IF (-not($processErrorFlag)) {
            $errorDetail = $Error[0] | Out-String
            }
        Write-Log -Id $ErrorEventID -Type Error -Message "Execution Error Message : $errorDetail"
        $Script:ErrorFlag = $TRUE

        IF ($Continue) {
            Write-Log -Id $WarningEventID -Type Warning -Message "Specified -Continue option, thus continue to process next objects."
            $Script:WarningFlag = $TRUE
            $Script:ContinueFlag = $TRUE
            Return
            }

        #Continueしない場合は終了処理へ進む
        IF ($ForceEndLoop) {
            $Script:ErrorFlag = $TRUE
            $Script:ForceFinalize = $TRUE
            Break

            } else {
            Finalize $ErrorReturnCode
            }   
    }

    IF ($OverRideFlag) {
        $Script:OverRideCount ++
        $Script:InLoopOverRideCount ++
        $Script:OverRideFlag = $FALSE
        }
        
    Write-Log -Id $SuccessEventID -Type Success -Message ("Successfully completed to [$($ActionType)] [$($ActionError)]" + $addMessage)
    $Script:NormalFlag = $TRUE
}
end {
}
}


function ConvertTo-AbsolutePath {

<#
.SYNOPSIS
Validate, Normalize and Convert to absolute path format.

.DESCRIPTION
This function validates, nomamalize path input, and convert to absolute format.

The validation includes null, empty, drive letter, Windows reserved words, wild cards asterisk* and question?
The nomalization includes replacing separator slash/ with back slash\ , consentive separator such as \\ , delete \ placed in ending directory path.

Relative, absolute, UNC path format are coverted to absolute path format.

If fail to validation, the fuction call function Finalize.

Characters bracket[] in PowerShell will be processed as wild cards.
But in the function path input is processed literally, characters bracket[] in the path must not be escaped. 

F.Y.I. function Invoke-Action processes path input literally also.


.PARAMETER PATH
Specify path to convert.
The path must be in relative, absolute, UNC path format.
In relative path format, the parameter start with .\ or ..\


.PARAMETER NAME
Specify description of the path.
It will be output in logs.

.INPUT
System.String

.OUTPUT
System.String

#>

[OutputType([String])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("CheckPath" , "FullName")]$Path ,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("ObjectName")]$Name ,

[String]$DatumPath = $DatumPath
)
begin {
}
Process {

    IF ([String]::IsNullOrEmpty($Path)) {
        Write-Log -ID $ErrorEventID -Type Error -Message "$($Name) is null or empty. Specification is required."    
        Finalize $ErrorReturnCode    
        }          

#Windows file system allows slash / for path separater. But for processing convert / to \

    $Path = $Path.Replace('/','\')


#Path validation Test-Path -isvalid can not validate path including colon: , thus test with other method.

    IF (Test-Path -LiteralPath $Path -IsValid) {
        Write-Log -Id $InfoEventID -Type Information -Message "$Name[$($Path)] is valid path format."
   
        } else {
        Write-Log -Id $ErrorEventID -Type Error -Message "$Name[$($Path)] is invalid path format. The path may contain a drive letter not-existed or characters that can not use by NTFS."
        Finalize $ErrorReturnCode
        }

    IF (($Path | Split-Path -noQualifier) -match '(\/|:|\?|`"|<|>|\||\*)') {
    
        Write-Log -Type Error -Id $ErrorEventID -Message "$Name may contain characters that can not use by NTFS  such as BackSlash/ Colon: Question? DoubleQuote`" less or greater than<> astarisk* pipe| "
        Finalize $ErrorReturnCode
        }

        
#Test if Windows reserved words in the path

    IF ($Path -match '\\(AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])(\\|$|\..*$)') {

        Write-Log -Type Error -Id $ErrorEventID -Message "$Name may contain the Windows reserved words such as (AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])"
        Finalize $ErrorReturnCode
        } 


#Normalization path. If the path contains consecutive separator\ , they will be single with [System.IO.Path]::GetFullPath()

        Switch -Regex ($Path) {

        "^\.+\\.*" {
       
            Write-Log -Id $InfoEventID -Type Information -Message "$Name[$($Path)] is relative path format."

            $convertedPath = $DatumPath | Join-Path -ChildPath $Path | ForEach-Object {[System.IO.Path]::GetFullPath($_)}
         
            Write-Log -Id $InfoEventID -Type Information -Message "Convert to absolute path format [$($convertedPath)] with joining the folder path [$($DatumPath)] the script is placed and the path [$($Path)]"

            $Path = $convertedPath
            }

        "^[c-zC-Z]:\\.*" {

            Write-Log -Id $InfoEventID -Type Information -Message "$Name[$($Path)] is absolute path format."
            
            $Path = $Path | ForEach-Object {[System.IO.Path]::GetFullPath($_)}            
            
            }

        "^\\\\.*\\.*" {

            Write-Log -Id $InfoEventID -Type Information -Message "$Name[$($Path)] is UNC path format."
            
            $Path = $Path | ForEach-Object {[System.IO.Path]::GetFullPath($_)}          
           
            }

        Default {
      
            Write-Log -Id $ErrorEventID -Type Error -Message "$Name[$($Path)] is neither absolute nor relative nor UNC path format."
            Finalize $ErrorReturnCode
            }
    }


#If the path ends with separte character \ , delete the ending character.

    IF ($Path.EndsWith('\')) {
    
        Write-Log -Id $InfoEventID -Type Information -Message "Windows path format allows the end of path with a path separator '\' , due to processing limitation, remove it."
        $Path = $Path.Substring(0, $Path.Length -1)
        }
       

    Write-Output $Path
}
end {
}


}

 
function ConvertTo-FileNameAddTimeStamp {

[OutputType([String])]
[CmdletBinding()]

Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("TargetFileName")]$Name ,
[String][parameter(position = 1, mandatory)]$TimeStampFormat 
)

begin {
    $formattedDate = (Get-Date).ToString($TimeStampFormat)
}

process {
    $extension                = [System.IO.Path]::GetExtension($Name)
    $fileNameWithOutExtention = [System.IO.Path]::GetFileNameWithoutExtension($Name)

    Write-Output ($fileNameWithOutExtention + $formattedDate + $extension)
}

end {
}
}


function Test-ServiceExist {

<#
.SYNOPSIS
Check existence of specified Windows Service

.PARAMETER ServiceName
Specify Windows service to test.

.PARAMETER NoMessage
Specify if you want to supress log message.

.INPUT
System.String

.OUTPUT
Boolean

#>

[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("Name")]$ServiceName ,
[Switch]$NoMessage
)
begin {
}
process {


    $service = Get-Service | Where-Object {$_.Name -eq $ServiceName}

    IF ($service.Status -Match "^$") {
        IF (-not($NoMessage)) {
            Write-Log -Id $InfoEventID -Type Information -Message "Service [$($ServiceName)] dose not exist."
            }
        Write-Output $FALSE

        } else {

        IF (-not($NoMessage)) {
            Write-Log -Id $InfoEventID -Type Information -Message "Service [$($ServiceName)] exists."
            }
        Write-Output $TRUE
        }
}
end {
}
}


function Test-ServiceStatus {
<#
.SYNOPSIS
Get service status in which running or stopped.

.DESCRIPTION
Specify service status and compare the status and -Status parameter option specified.
If the status is equal to specfication one, return $TRUE, not return $FALSE
Some service needs long time to switch status, you can specify interval and times to get status in this function.
If you test service to need long time to switch, you should spedify -Span option to large number.

.PARAMETER SERVICENAME
Specify name of service you want to get status.

.PARAMETER STATUS
Specify status of the service for testing.

.PARAMETER SPAN
Specify interval of testing service in seconds.

.PARAMETER UPTO
Specify how many times to retry for testing.

.OUTPUT
Boolean

#>
[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("Name")]$ServiceName ,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][ValidateSet("Running", "Stopped")][Alias("Health")]$Status = 'Running' ,

[int][ValidateRange(0,2147483647)][Alias("RetrySpanSec")]$Span = 3 ,
[int][ValidateRange(0,2147483647)][Alias("RetryTimes")]$UpTo = 10
)
begin {
}
process {

$result = $FALSE

    For ( $i = 0 ; $i -le $UpTo; $i++ ) {

#Test existence of the Windows service

        IF (-not($ServiceName | Test-ServiceExist -NoMessage)) {
            Break
            }


#Test status of the Windows service

        $service = Get-Service | Where-Object {$_.Name -eq $ServiceName}

        IF ($service.Status -eq $Status) {
            Write-Log -Id $InfoEventID -Type Information -Message "Service [$($ServiceName)] exists and status is [$($service.Status)]"
            $result = $TRUE
            Break     
            
            } elseIF (($Span -eq 0) -and ($UpTo -le 1)) {
                
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($ServiceName)] exists and status is [$($service.Status)]"
                Break
                }


#The service dose not swith to specified status.

        IF ($i -ge $UpTo) {
            Write-Log -Id $InfoEventID -Type Information -Message ("Service [$($ServiceName)] exists and status is [$($Service.Status)] now. " +
                "The specified waiting times has elapsed but the service has not switched to status [$($Status)]")
            Break
            }


#Wait for specified seconds.

        Write-Log -Id $InfoEventID -Type Information -Message ("Service [$($ServiceName)] exists and status is [$($Service.Status)] , " +
            "is not [$($Status)] Wait for $($Span)seconds. Retry [" + ($i+1) + "/$UpTo]")
        Start-Sleep -Seconds $Span        
    }

Write-Output $result
}
end {
}
}


function Test-PathEx {
<#
.SYNOPSIS
Extended Test-Path function

.DESCRIPTION
Testing path of Leaf, Container, Not Null or Empty, Log File.
This function output logs with Write-Log function in CommonFunctions.ps1
Return 3type value.

Without option (default)
$TRUE for existence or $FALSE for non-existence.

With -PassThrough option
$PATH for exisntence(true) or $NULL for non-existence(false)

With -IfFalseFinalize option
Exit the function and execute Finalize function in the script if the result is false.
Return $FALSE or $PATH for true.

.PARAMETER PATH
Specify a path for test.

.PARAMETER NAME
Specify name string in the logs.

.PARAMETER TYPE
Specify type of testing path.
With -Type Log, test log file write permission or make a new log file when the log file dose not exist.

With -NotNullOrEmpty option, return $TRUE or $PATH for $PATH value is not $NULL or empty.

.PARAMETER IFFALSEFINALIZE
Specify if you want to force exit and execute Finalize function when the script get false.

.PARAMETER NOMESSAGE
Specify if you want to supress outputting logs.

.PARAMETER PASSTHROUGH
Specify if you want to get value $PATH when the result of the path is true. 

.OUTPUT
Boolean
String

#>

    [OutputType([Boolean])]
    [CmdletBinding()]

    Param(
    [String][parameter(position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("CheckPath" , "FullName" , "LiteralPath")]$Path ,
    [String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("ObjectName")]$Name ,
    [String][parameter(position = 2)][ValidateSet("Leaf", "Container", "NotNullOrEmpty", "Log")]$Type ,

    [Switch]$IfFalseFinalize ,
    [Switch]$NoMessage ,
    [Switch]$Passthrough
    )

    begin {
#       Push-Location (Get-Location -PSProvider FileSystem)
    }
    process {
    
        Switch -Regex ($Type) {

            'Leaf' {
                $result = Test-Path -LiteralPath $Path -PathType Leaf
            }

            'Container' {
                $result = Test-Path -LiteralPath $Path -PathType Container
            }

            'NotNullOrEmpty' {
                $result = -not([String]::IsNullOrEmpty($Path))
            }

            'Log' {
                $result = Test-LogPath -Path $Path -Name $Name -GetResult
                $NoMessage = $TRUE
            }
        }


        IF (($result) -and (-not($NoMessage))) {

            IF ($Type -eq 'NotNullOrEmpty') {

                Write-Log -ID $InfoEventID -Type Information -Message "$($Name) is specified [$($Path)]"                

                } else {

                Write-Log -ID $InfoEventID -Type Information -Message "$($Name)[$($Path)] exists."
                }

        } elseIF (-not($result) -and (-not($NoMessage))) {

            IF ($Type -eq 'NotNullOrEmpty') {

                Write-Log -ID $InfoEventID -Type Information -Message "$($Name) is not specified."                

                } else {

                Write-Log -ID $InfoEventID -Type Information -Message "$($Name)[$($Path)] dose not exist."
                }
        } 



        IF ((-not($result)) -and ($IfFalseFinalize)) {
            
            IF (-not($NoMessage)) {

                Write-Log -ID $ErrorEventID -Type Error -Message "$($Name) is required."

            } 

            Finalize $ErrorReturnCode
        }
    

        IF (($Passthrough) -and $result) {

            Write-Output $Path

        } elseIF (($Passthrough) -and (-not($result))) {

            Write-Output $NULL

        } else {

            Write-Output $result

        }
    }
    end {
#       Pop-Location
    }
}


function Test-LogPath {
[OutputType([boolean])]
[CmdletBinding()]
Param(

[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("CheckPath" , "FullName")]$Path,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("ObjectName")]$Name,
[String][parameter(position = 2)]$FileValue = $NULL ,

[Switch][parameter(position = 3)]$PassThrough ,
[Switch][parameter(position = 4)]$GetResult
)
begin {
    $logFormattedDate = (Get-Date).ToString($LogDateFormat)
}
process {

$result = $ErrorReturnCode

:do DO {    
    IF (-not($Path | Split-Path -Parent)) {
        Write-Log -Id $ErrorEventID -Type Error -Message "$($Name)[$($Path)] is invalid specification."   
        Break
        }

#Not exist the parent folder of the log output path

    IF (-not($Path | Split-Path -Parent | Test-PathEx -Type Container -Name $Name)) {
    
        Break
        }


#Test same name folder of the log output path.

    IF (Test-Path -LiteralPath $Path -PathType Container) {
        Write-Log -Id $ErrorEventID -Type Error -Message "Same name folder $($Path) exists already."        
        Break
        }


    IF (Test-Path -LiteralPath $Path -PathType Leaf) {

        Write-Log -Id $InfoEventID -Type Information -Message "Check write permission of $($Name) [$($Path)]"
        $logWrite = $logFormattedDate + " " + $ShellName + " Write Permission Check"
        

        Try {
            Write-Output $logWrite | Out-File -FilePath $Path -Append -Encoding $LogFileEncode -ErrorAction Stop
            Write-Log -Id $SuccessEventID -Type Success -Message "Successfully complete to write to $($Name) [$($Path)]"
            $result = $NormalReturnCode
            }
        Catch [Exception]{
            Write-Log -Type Error -Id $ErrorEventID -Message  "Failed to write to $($Name) [$($Path)]"
            Write-Log -Id $ErrorEventID -Type Error -Message "Execution error message : $Error[0]"
            Break
            }
     
     } else {
            Invoke-Action -ActionType MakeNewFileWithValue -ActionFrom $Path -ActionError $Path -FileValue $FileValue
            $result = $NormalReturnCode
            }
}

While ($FALSE)  ;# :do

IF ($GetResult) {
    IF ($result -eq $NormalReturnCode) {

        Write-Output $TRUE
        Return

    } else {

        Write-Output $FALSE
        Return
    }    
}

IF ($result -eq $ErrorReturnCode) {
    Finalize $result

    } elseIF ($PassThrough) {

        Write-Output $Path
        } else {

        Write-Output $NULL    
        }
}
end {
}
}


function Test-ExecUser {

Param(
[Regex]$ExecutableUser = $ExecutableUser
)

    $Script:ScriptExecUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    Write-Log -Id $InfoEventID -Type Information -Message "Executed in user [$($ScriptExecUser.Name)]"

    IF (-not($ScriptExecUser.Name -match $ExecutableUser)) {
        Write-Log -Type Error -Id $ErrorEventID -Message "Executed in an unauthorized user."
        Finalize $ErrorReturnCode
        }
}


function Invoke-PreInitialize {

$ERROR.clear()
$ForceConsole = $FALSE
$ForceConsoleEventLog = $FALSE

#Validate ReturnCode

. Test-ReturnCode


#Test existence of event source

. Test-EventLogSource


#Test output path of the log file

. Test-LogFilePath



#remind variable's scope. These variables are used in script (not in this function only!) for set scope, use $Script:variable's name

#process -NoLog switches

IF ($NoLog2EventLog) {[boolean]$Script:Log2EventLog = $FALSE}
IF ($NoLog2Console)  {[boolean]$Script:Log2Console  = $FALSE}
IF ($NoLog2File)     {[boolean]$Script:Log2File     = $FALSE}


Write-Log -Id $StartEventID -Type Information -Message "Start $($ShellName) Version $($Version)"

Write-Log -Id $InfoEventID -Type Information -Message "Loaded CommonFunctions.ps1 Version $($CommonFunctionsVersion)"

Write-Log -Id $InfoEventID -Type Information -Message "Start to validate parameters."

. Test-ExecUser


}


function Invoke-PostFinalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)
Write-Debug "ReturnCode [$ReturnCode]"

IF ($ReturnCode -ge $InternalErrorReturnCode) {

    Write-Log -Id $ErrorEventID -Type Error -Message "Terminated with An InternalError, thus the exit code is [$($InternalErrorReturnCode)]"

    } elseIF (($ErrorCount -gt 0) -or ($ReturnCode -ge $ErrorReturnCode)) {

        IF ($ErrorAsWarning) {
            Write-Log -Id $WarningEventID -Type Warning -Message "Terminated with an Error, specified -ErrorAsWarning[$($ErrorAsWarning)] option, thus the exit code is [$($WarningReturnCode)]"  
            $returnCode = $WarningReturnCode
           
            } else {
            Write-Log -Id $ErrorEventID -Type Error -Message "Terminated with An Error, thus the exit code is [$($ErrorReturnCode)]"
            $returnCode = $ErrorReturnCode
            }

        } elseIF (($WarningCount -gt 0) -or ($ReturnCode -ge $WarningReturnCode)) {

            IF ($WarningAsNormal) {
                Write-Log -Id $InfoEventID -Type Information -Message "Terminated with a Warning, specified -WarningAsNormal[$($WarningAsNormal)] option, thus the exit code is [$($NormalReturnCode)]" 
                $returnCode = $NormalReturnCode
           
                } else {
                Write-Log -Id $WarningEventID -Type Warning -Message "Terminated with a Warning, thus the exit code is [$($WarningReturnCode)]"
                $returnCode = $WarningReturnCode
                }
        
        } else {
        Write-Log -Id $SuccessEventID -Type Success -Message "Completed successfully. The exit code is [$($NormalReturnCode)]"
        $returnCode = $NormalReturnCode               
        }

    Write-Log -Id $EndEventID -Type Information -Message "Exit $($ShellName) Version $($Version)"

Exit $returnCode
}


function Invoke-SQL {
[OutputType([PSObject])]
[CmdletBinding()]
Param(

[parameter(position = 0, mandatory)][String]$SQLCommand ,
[parameter(position = 1, mandatory)][String]$SQLName ,
[parameter(position = 2)][String]$SQLLogPath = $SQLLogPath ,

[Switch]$IfErrorFinalize ,


[Boolean]$PasswordAuthorization = $PasswordAuthorization ,
[String]$ShellName = $ShellName ,
[String]$LogFileEncode = $LogFileEncode ,
[String]$LogDateFormat = $LogDateFormat , 
[String]$ExecUser = $ExecUser ,
[String]$ExecUserPassword = $ExecUserPassword
)
begin {
    $scriptExecUser = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name
    $logFormattedDate = (Get-Date).ToString($LogDateFormat)

#PowerShellではヒアドキュメントの改行はLFとして処理される
#しかしながら、他のOracleからの出力はLF&CRのため、Windowsメモ帳で開くと改行コードが混在して正しく処理されない
#よって、明示的にCRを追加してSQLLogで改行コードが混在しないようにする
#Sakura Editor等では改行コード混在も正しく処理される

$logWrite = @"
`r
`r
----------------------------`r
DATE: $logFormattedDate`r
SHELL: $ShellName`r
SQL: $SQLName`r
`r
OS User: $scriptExecUser`r
`r
SQL Exec User: $ExecUser`r
Password Authrization [$PasswordAuthorization]`r
`r
"@

    $invokeResult = New-Object PSObject -Property @{
    Status = $NULL
    Log = $NULL
    }

}
process {

Write-Output $logWrite | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode

Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization) {

        $invokeResult.Log = $SQLCommand | SQLPlus.exe $ExecUser/$ExecUserPassword@OracleSerivce as sysdba

        } else {
        $invokeResult.log = $SQLCommand | SQLPlus.exe / as sysdba
        }

Pop-Location

Write-Output $invokeResult.log | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode

    IF ($LASTEXITCODE -ne 0) {

        Write-Log -Id $ErrorEventID -Type Error -Message "Failed to execute SQL Command[$($SQLName)]"
   
            IF ($IfErrorFinalize) {
            Finalize $ErrorReturnCode
            }
   
        $invokeResult.Status = $FALSE

        } else {
        Write-Log -Id $SuccessEventID -Type Success -Message "Successfully completed to execute SQL Command[$($SQLName)]"
        $invokeResult.Status = $TRUE
        }
Write-Output $invokeResult
}
end {
}
}


function Test-OracleBackUpMode {

[OutputType([PSObject])]
[CmdletBinding()]
 Param(
 [String]$DBCheckBackUpMode = $DBCheckBackUpMode ,
 [String]$SQLLogPath = $SQLLogPath
 )

 begin {
 }
 process {
    Write-Log -Id $InfoEventID -Type Information -Message "Get the backup status of Oracle Database ,determine Oracle Database is running in which mode BackUp/Normal. A line [Active] is in BackUp Mode."
    
    $invokeResult = Invoke-SQL -SQLCommand $DBCheckBackUpMode -SQLName "DBCheckBackUpMode" -SQLLogPath $SQLLogPath

   
    #文字列配列に変換する
    $sqlLog = $invokeResult.Log -replace "`r","" |  ForEach-Object {$_ -split "`n"}

    $normalModeCount = 0
    $backUpModeCount = 0

    $dbStatus = New-Object PSObject -Property @{
    Normal = $FALSE
    BackUp = $FALSE
    }

    $i = 1

    foreach ($line in $sqlLog) {

        IF ($line -match 'NOT ACTIVE') {
            $normalModeCount ++
            Write-Log -Id $InfoEventID -Type Information -Message "[$line] line[$i] Normal Mode"
 
 
            } elseIF ($line -match 'ACTIVE') {
            $backUpModeCount ++
            Write-Log -Id $InfoEventID -Type Information -Message "[$line] line[$i] BackUp Mode"
            }
 
    $i ++
    }


    Write-Log -Id $InfoEventID -Type Information -Message "Oracle Database is running in...."

    IF (($backUpModeCount -eq 0) -and ($normalModeCount -gt 0)) {
 
        Write-Log -Id $InfoEventID -Type Information -Message "Normal Mode"
        $dbStatus.Normal = $TRUE
        $dbStatus.BackUp = $FALSE

    } elseIF (($backUpModeCount -gt 0) -and ($normalModeCount -eq 0)) {
   
        Write-Log -Id $InfoEventID -Type Information -Message "Back Up Mode"
        $dbStatus.Normal = $FALSE
        $dbStatus.BackUp = $TRUE

    } else {

        Write-Log -Id $InfoEventID -Type Information -Message "??? Mode ???"
        $dbStatus.Normal = $FALSE
        $dbStatus.BackUp = $FALSE
    }

    Write-Output $dbStatus
}
end {
}
}


function Test-UserName {

[OutputType([Boolean])]
[CmdletBinding()]

Param(
[parameter(position = 0,  mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][String][Alias("Name")]$CheckName,
[parameter(position = 1)][String]$ObjectName ,

[Switch]$IfInvalidFinalize
)
begin  {
}
process {
    Switch -Regex ($CheckUserName) {

        '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$' {
            Write-Log -Id $InfoEventID -Type Information -Message "$($ObjectName) [$($CheckUserName)] is valid user name."
            Write-Output $TRUE     
            }

        Default {
            Write-Log -Id $ErrorEventID -Type Error -Message "$($ObjectName) [$($CheckUserName)] is invalid user name."
            Write-Output $FALSE

            IF($IfInvalidFinalize){

                Finalize $ErrorReturnCode
                }
            }
    }
}
end {
}
}


function Test-DomainName {

[OutputType([Boolean])]
[CmdletBinding()]

Param(
[parameter(position = 0,  mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][String][Alias("Name")]$CheckDomainName,
[parameter(position = 1)][String]$ObjectName ,

[Switch]$IfInvalidFinalize
)
begin  {
}
process {
    Switch -Regex ($CheckDomainName) {

        '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$' {
            Write-Log -Id $InfoEventID -Type Information -Message "$($ObjectName) [$($CheckDomainName)] is valid domain name."
            Write-Output $TRUE     
            }

        Default {
            Write-Log -Id $ErrorEventID -Type Error -Message "$($ObjectName) [$($CheckDomainName)] is invalid domain name."
            Write-Output $FALSE

            IF($IfInvalidFinalize){

                Finalize $ErrorReturnCode
                }
            }
    }
}
end {
}


}


function Test-Hostname {

[OutputType([Boolean])]
[CmdletBinding()]

Param(
[parameter(position = 0,  mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][String][Alias("Name")]$CheckHostName,
[parameter(position = 1)][String]$ObjectName ,

[Switch]$IfInValidFinalize
)
begin  {
}
process {
    Switch -Regex ($CheckHostName) {

        '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$' {
            Write-Log -Id $InfoEventID -Type Information -Message "$($ObjectName) [$($CheckHostName)] is valid IP Address."
            Write-Output $TRUE     
            }

        '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$' {
            Write-Log -Id $InfoEventID -Type Information -Message "$($ObjectName) [$($CheckHostName)] is valid Hostname."
            Write-Output $TRUE                
            }

        Default {
            Write-Log -Id $ErrorEventID -Type Error -Message "$($ObjectName) [$($CheckHostName)] is invalid Hostname."
            Write-Output $FALSE

            IF($IfInvalidFinalize){

                Finalize $ErrorReturnCode
                }
            }
    }
}
end {
}
#ValidIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";

#ValidHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";

}
