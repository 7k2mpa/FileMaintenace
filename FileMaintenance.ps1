﻿#Requires -Version 3.0
#If you want to use '-PreAction compress or archive' option in FileMaintenance.ps1, install WMF 5.0 or later, and place '#Requires -Version 5.0' insted of '#Requires -Version 3.0'
#If you want to use '-PreAction compress or archive' option with 7-Zip in FileMaintenance.ps1, do not need to replace.

<#
.SYNOPSIS

This script processes log files or temp files to delete, move, archive, etc.... with multiple methods.
CommonFunctions.ps1 is required.
You can process files in multiple folders with Wrapper.ps1



.DESCRIPTION

This script finds files and folders that match up to multiple criteria.
And processes the files and folders found with multiple methods with PreAction, Action and PostAction.

Methods are

-PreAction:
Create new files from files found.
Methods [AddTimeStamp (to file name)][Compress][Archive (to 1file)][Move (the) NewFile (created to new location)] are offered and can be used together.
Without specification -MoveNewFile option, place the file created in the same folder of the original file.

-Action:
Process files found to [Move][Copy][Delete][NullClear][KeepFilesCount] , folders found to [DeleteEmptyFolders]

-PostAction:
Process files found to [NullClear][Rename]


Finding criteria are [(Older than)-Days][-Size][-(FileName)RegularExpression][-Parent(Path)RegularExpression]

This script processes only 1 folder at once.
If you process multiple folders, can do with Wrapper.ps1

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to suppress or to output individually. 

This scrpit requires PowerShell 3.0 or later.
If you run the scripts on Windows Server 2008 or 2008R2, must install latest WMF.

This script can use cmdlet Compress-Archive for '-PreAction compress or archive option'. 

But cmdlet Compress-Archive can not handle wild card characters bracket[] for destination path correctly, you should install 7-Zip. This script can use 7-Zip for compress or archive also.

If you want to specify '-PreAction compress or archive' option in FileMaintenance.ps1 without installing 7-Zip, install WMF 5.0 or later, and place '#Requires -Version 5.0' instead of '#Requires -Version 3.0'

If you can install 7-Zip for compress or archive, do not need to replace.

https://docs.microsoft.com/ja-jp/PowerShell/scripting/install/installing-windows-PowerShell?view=PowerShell-7#upgrading-existing-windows-PowerShell



.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -noLog2Console -verbose

Find files in C:\TEST and child folders recuresively.
All logs are not output at console.
You would confirm getting files to process. 


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete

Delete files in C:\TEST and child folders recuresively.


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action DeleteEmptyFolders

Delete empty folders in C:\TEST and child folders recuresively.


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete -noRecurse

Delete files only in C:\TEST non-recuresively.


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Copy -MoveToFolder C:\TEST1 -Size 10KB -continue

Copy files over than 10KByte to C:\TEST1 recuresively.
If no child folder exists in the destination, make a new folder.
If a same name file exists in the destination, skip copying and continue to process a next object.


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,AddTimeStamp -Action NullClear -Days 10

Find files ending with '.log' and older 10days in C:\TEST recuresively.
Create new files compressed and added time stamp to file name from files found.
New files place in the same folder.
The files that are found dose not be deleted, but are cleared with null.


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,MoveNewFile -Action Delete -MoveToFolder C:\TEST1 -OverRide -Days 10

Find files ending with '.log' and older 10days in C:\TEST recuresively.
Create new files compressed and move to C:\TEST1
If a same name file exists in the destination, override old one.
The original files are deleted. 


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\OLD\Log -RegularExpression '^.*\.log$' -Action Delete -ParentRegularExpression '\\OLD\\'

Find files ending with '.log' recuresively.
-ParentRegularExpresssion option is specified with regular expression, thus path's backslash\ is escaped with backslash\
Delete them with '\OLD\' in the rest of the path characters next to the -TargetFolder(C:\OLD\Log)'s strings.
At the sample blow, 'C:\OLD\Los' dose not match up to -ParentRegularExpression.
Thus 'C:\OLD\Log\IIS\Current\Infra.log' , 'C:\OLD\Log\Java\Current\Infra.log' and 'C:\OLD\Log\Infra.log' are not deleted.

C:\OLD\Log\IIS\Current\Infra.log
C:\OLD\Log\IIS\OLD\Infra.log
C:\OLD\Log\Java\Current\Infra.log
C:\OLD\Log\Java\OLD\Infra.log
C:\OLD\Log\Infra.log


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -CommonConfigPath .\CommonConfig.ps1

Find files in C:\TEST and child folders recuresively.
With CommonCOnfig.ps1 setting, event log's IDs are specified.



.PARAMETER TargetFolder

Specify a folder of the target files or the folders placed.
Specification is required.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


.PARAMETER PreAction

Specify methods to process files.
-PreAction option accept multiple arguments.
Separate arguments with comma,

None:Do nothing, and is default. If you want to test the action, specify -WhatIf or -Confirm option.
Compress:Create new files compressed from the original files.
AddTimeStamp:Create new files with file name added time stamp.
Archive:Create an archive file from files found. Specify archive file name with -ArchiveFileName option.
MoveNewFile:place new files in -MoveNewFolder path.
7z:Specify to use 7-Zip and make .7z(LZMA2) for compress or archive option.
7zZip:Specify to use 7-Zip and make .zip(Deflate) for compress or arvhice option.


.PARAMETER Action

Specify method to process files.

None:Do nothing, and is default. If you want to test the action, specify -WhatIf or -Confirm option.
Move:Move the files found to -MoveNewFolder path.
Delete:Delete the files.
Copy:Copy the files found and place in -MoveNewFolder path.
DeleteEmptyFolders:Delete empty folders.
KeepFilesCount:Delete old generation files untill number of files is equal to be specified.
NullClear:Clear the files found with null.


.PARAMETER PostAction

Specify method to process files.

None:Do nothing, and is default. If you want to test the action, specify -WhatIf or -Confirm option.
Rename:Rename the files found with -RenameToRegularExpression
NullClear:Clear the files with null.


.PARAMETER MoveToFolder

Specify a destination folder of the files found moved to.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


.PARAMETER ArchiveFileName

Specify the file name of the archive file with -PreAction Archive option.
Specify it without extension.
Extension strings will be added automatically with archive method.


.PARAMETER 7zFolder 

Specify a folder of 7-Zip installed.
[C:\Program Files\7-Zip] is default.


.PARAMETER Days

Specify how many days older than today to process files.
[0] day is default and, process all files.


.PARAMETER Size

Specify size of files to process.
[0] byte is default, and process all files.
Units of KB,MB,GB are accepted.
e.g. [-Size 10MB] is equal to [-Size 10*1024^6]


.PARAMETER RegularExpression

Specify regular expression to match up to processing files.
['.*'] is default, and process all files.
Argument must be quoted with sigle quote'
In PowerShell specification, capital and small letter are equal value but, are not (some version?)


.PARAMETER ParentRegularExpression

Specify regular expression to match up to processing path of the files excluding -TargetFolder.
['.*'] is default, and process all files.
Argument must be quoted with sigle quote'
In PowerShell specification, capital and small letter are equal value but, are not (some version?)


.PARAMETER RenameToRegularExpression

Specify regular expression for rename rule when specify -PostAction Rename.
Specify rename pattern for -RegularExpression
https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/substitutions-in-regular-expressions


.PARAMETER Recurse

Specify to process the files or folders in the path recursively or non-recuresively.
[$TRUE(recuresively)] is default.


.PARAMETER NoRecurse

Specify if you want to find files non-recursively.
The option overrides -Recurse option.


.PARAMETER OverRide

Specify if you want to override same name files in the destination in moving or copying  process.
If the file in the destination path is equal or newer than the file in the source path, do not override and skip to process with counting up a Warning.
[$FALSE (terminate with an Error and do not override)] is default.


.PARAMETER OverRideAsNormal

Specify if you want to exit with Normal return code when override same name files in the destination in moving or copying  process.
[$FALSE (terminate with a Warning when override)] is default.


.PARAMETER OverRideForce

Specify if you want to override same name files in the destination in moving or copying  process.
If the file in the destination path is equal or newer than the file in the source path, force to override with counting up a Warning.
[$FALSE (terminate with an Error and do not override)] is default.


.PARAMETER Continue

Specify if you want to skip the process when files exist in -MoveToFolder alredy in moving or copying  process and to process remains.
If the script skips the process, processes remains and terminates with a Warning.
[$FALSE (terminate with an Error immediately and do not skip)] is default. 


.PARAMETER ContinueAsNormal

Specify if you do not want to override a files and to want to continue processing and to exit with Normal return code.
If the script skips to process, exits successfully.
[$FALSE (terminate with an Error immediately and do not skip)] is default. 


.PARAMETER NoneTargetAsWarning

Specify if you want to terminate with a Warning when no file exists in the folder.
[$FALSE (exit with Normal when no file exists in the folder)] is default.


.PARAMETER CompressedExtString

Specify file extention strings in specifing -PreAction Compress option.
[.zip] is default.


.PARAMETER TimeStampFormat

Specify time stamp format in specifing -PreAction AddTimeStamp option
[_yyyyMMdd_HHmmss] is default.
It is deffernt from -LogDateFormat option.


.PARAMETER KeepFiles

Specify how many newer files in the folder to keep with -Action KeepFileCount option.
[1] is default.



.PARAMETER CommonConfigPath

Specify common configuration file path in relative path format.
Only this parameter, you can specify the path with only relative path format.
With this parameter, you can specify same event id for utility scripts with common config file.
If you want to cancel using common config file specified in Param section of the script, specify this argument with NULL or empty string.


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
Escape the back slash in the separetor of a domain name.
example [domain\\.*]



.NOTES

The origin of [Delete Empty Folders] function comes from Martin Pugh's Remove-EmptyFolders released under MIT License.
 (https://github.com/martin9700/Remove-EmptyFolders)
See also LICENSE_Remove-EmptyFolders.txt File.

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
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]

Param(

[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Specify a folder to process (ex. D:\Logs)  or Get-Help FileMaintenance.ps1')]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("Path","LiteralPath","FullName" , "SourcePath")]$TargetFolder ,

#[String]$TargetFolder,  #for Validation debug
 

[Array][parameter(position = 1)]
[ValidateSet("none" , "AddTimeStamp" , "Compress", "MoveNewFile" , "Archive" , "7z" , "7zZip")]$PreAction = 'none' ,

[String][parameter(position = 2)]
[ValidateSet("none" , "Move", "Copy", "Delete" , "DeleteEmptyFolders" , "NullClear" , "KeepFilesCount")]$Action = 'none' ,

[String][parameter(position = 3)]
[ValidateSet("none" , "NullClear" , "Rename")]$PostAction = 'none' ,


[String][parameter(position = 4)]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("DestinationPath")]$MoveToFolder ,

#[String]$MoveToFolder,  #for Validation debug

[String][ValidateNotNullOrEmpty()][ValidatePattern('^(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$ArchiveFileName = "archive" ,

[Int][ValidateRange(0,2147483647)]$KeepFiles = 1 ,
[Int][ValidateRange(0,730000)]$Days = 0 ,
[Int64][ValidateRange(0,9223372036854775807)]$Size = 0 ,

#[Regex][Alias("Regex")]$RegularExpression = '^(.*)\.txt$' , #RenameRegex Sample

[Regex][Alias("Regex")]$RegularExpression = '.*' ,
[Regex][Alias("PathRegex")]$ParentRegularExpression = '.*' ,
[Regex][Alias("RenameRegex")]$RenameToRegularExpression = '$1.log' ,

[Boolean]$Recurse = $TRUE ,
[Switch]$NoRecurse ,


[Switch]$OverRide ,
[Switch]$OverRideAsNormal ,
[Switch]$OverRideForce ,
[Switch]$Continue ,
[Switch]$ContinueAsNormal ,
[Switch]$NoneTargetAsWarning ,

[String][ValidatePattern('^\.(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CompressedExtString = '.zip',

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$7zFolder = 'C:\Program Files\7-Zip' ,

[String][ValidatePattern('^(?!.*(\\|\/|:|\?|`"|<|>|\|)).*$')]$TimeStampFormat = '_yyyyMMdd_HHmmss' ,



#[String][ValidatePattern('^(|\0|(\.+\\)(?!.*(\/|:|\?|`"|<|>|\||\*))).*$')]$CommonConfigPath = '.\CommonConfig.ps1' , #MUST specify with relative path format
[String][ValidatePattern('^(|\0|(\.+\\)(?!.*(\/|:|\?|`"|<|>|\||\*))).*$')]$CommonConfigPath = $NULL ,


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


################# functions  #######################


function Test-LeafNotExists {

<#
.SYNOPSIS
 Check the path specified that a file or folder dose NOT exist in the path.

.DESCRIPTION
 Check the path specified that a file or folder dose NOT exist in the path, and return $TRUE or $FALSE
 
.INPUT
　Strings of File Path

.OUTPUT
　Boolean

.NOTE
Cases in the destination path....
1 file exists   with -OverRide option ...$TRUE, $OverRideFlag = $TRUE(-OverRide prior to -Continue) remind Invoke-Action override file anytime
2 file exists   with -Continue option ...$FALSE, $ContinueFlag = $TRUE 
3 file exists   without option ...finalize with $ErrorReturnCode, if $FroceEndLoop=$TRUE then $FALSE, $ForceFinalize=$TRUE
4 FOLDER exists with -OverRide option ...can not override, thus finalize with $ErrorReturnCode, if $FroceEndLoop=$TRUE then $FALSE, $ForceFinalize=$TRUE
5 FOLDER exists with -Continue option ...$FALSE, $ContinueFlag = $TRUE 
6 FOLDER exists without option ...finalize with $ErrorReturnCode, if $FroceEndLoop=$TRUE then $FALSE, $ForceFinalize=$TRUE
7 nothing exists ...$TRUE
#>

[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
[Alias("CheckPath" , "FullName")]$Path ,

[Switch]$ForceEndLoop = $ForceEndLoop ,
[Switch]$OverRide = $OverRide ,
[Switch]$OverRideAsNormal = $OverRideAsNormal ,
[Switch]$OverRideForce = $OverRideForce ,
[Switch]$Continue = $Continue ,
[Switch]$ContinueAsNormal = $ContinueAsNormal ,
[int]$InfoEventID = $InfoEventID ,
[int]$WarningEventID = $WarningEventID ,
[int]$ErrorEventID = $ErrorEventID
)

begin {
}
process {
Write-Log -ID $InfoEventID -Type Information -Message "Check existence of [$($Path)]"

Do {

    #Case 7
    IF (-not(Test-Path -LiteralPath $Path)) {

        Write-Log -ID $InfoEventID -Type Information -Message "File [$($Path)] dose not exist."
        $objectDoseNotExist = $TRUE
        Break
        }


    IF (Test-Path -LiteralPath $Path -PathType Leaf) {
        
        Write-Log -ID $WarningEventID -Type Warning -Message "Same name file [$($Path)] exists already."
        
        } else {
        Write-Log -ID $WarningEventID -Type Warning -Message "Same name folder [$($Path)] exists already."        
        }


    #Case 1
    IF (($OverRide) -and (Test-Path -LiteralPath $Path -PathType Leaf)) {

Write-Verbose  "Destination LastWriteTime[$((Get-Item -LiteralPath $Path).LastWriteTime)] Size[$((Get-Item -LiteralPath $Path).Length)]"
Write-Verbose  "Source      LastWriteTime[$($Target.Object.LastWriteTime)] Size[$($Target.Object.Length)]" 
 
        IF (-not($OverRideForce) -and (Get-Item -LiteralPath $Path).LastWriteTime -ge $Target.Object.LastWriteTime ) {
            
            Write-Log -ID $WarningEventID -Type Warning -Message "Last write time of [$($Path)] is equal or newer than [$($Target.Object.FullName)] , thus does no override."
            $Script:WarningFlag = $TRUE
            $objectDoseNotExist = $FALSE
            Break
            }

        $Script:OverRideFlag = $TRUE
        $objectDoseNotExist = $TRUE

        IF ($OverRideAsNormal) {

            Write-Log -ID $InfoEventID -Type Information -Message ("A same name file exists in the destination already, but specified -OverRideAsNormal[$($OverRideAsNormal)] option, " +
                "thus overrides the file in the destination [$($Path)] and counts a warning event as NORMAL.")
            
            } else {     
            Write-Log -ID $WarningEventID -Type Warning -Message ("A same name file exists in the destination already, but specified -OverRide[$($OverRide)] option, " +
                "thus overrides the file in the destination [$($Path)]")
            $Script:WarningFlag = $TRUE
            }

        Break
        }

    #Case 2,5
    IF ($Continue) {
        
        $Script:ContinueFlag = $TRUE
        $objectDoseNotExist = $FALSE

        IF ($ContinueAsNormal) {

            Write-Log -ID $InfoEventID -Type Information -Message "Specified -ContinueAsNormal[$($ContinueAsNormal)] option, continues to process objects and count a warning event as NORMAL."

            } else {
            Write-Log -ID $WarningEventID -Type Warning -Message "Specified -Continue[$($Continue)] option, continues to process objects."
            $Script:WarningFlag = $TRUE
            }
        Break
        }           

    #Case 3,4,6
    Write-Log -ID $ErrorEventID -Type Error -Message "Same name object exists already, thus forces to terminate $($ShellName)"
            
    IF ((-not($ForceEndLoop)) -and (-not($MYINVOCATION.ExpectingInput))) {  ;# $MYInvocation.ExpectingInput = $TRUE means, script run in the pipeline

        Finalize $ErrorReturnCode

        } else {
        $Script:ErrorFlag = $TRUE
        $Script:ForceFinalize = $TRUE
        $objectDoseNotExist = $FALSE
        Break 
        }
}

While ($FALSE)

Write-Output $objectDoseNotExist
}
end {
}
}


filter ComplexFilter {

<#
.SYNOPSIS
　filter objects with criteria

.DESCRIPTION
last write date is older than $Days
(file|folder) name match up to $RegularExpression
file size is over than $Size
C:\TargetFolder                    :TargetFolder
C:\TargetFolder\A\B\C\target.txt   :TargetObject
part of \A\B\C\ match up to $ParentRegularExpression

.INPUT
PSobject

.OUTPUT
PSobject passed the filter

#>
    IF ($_.LastWriteTime -lt (Get-Date).AddDays(-$Days)) {
    IF ($_.Name -match $RegularExpression) {
    IF ($_.Length -ge $Size) {
    IF (($_.FullName).Substring($TargetFolder.Length, ($_.FullName | Split-Path -Parent).Length - $TargetFolder.Length +1) -match $ParentRegularExpression)
        {Write-Output $_}
    }
    } 
    }
                                                                          
}

 
function Get-Object {

<#
.SYNOPSIS
　find objects(files or folders) in the specified folder

.INPUT
System.String. Path of the folder to get objects

.OUTPUT
PSObject
#>

[OutputType([PSObject])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("TargetFolder" , "FullName")]$Path ,
[String][parameter(position = 1, mandatory)][ValidateSet("File" , "Folder")]$FilterType ,

[Switch]$Recurse = $Recurse ,
[String]$Action = $Action
)

begin {
}
process {

$parameter = @{
    LiteralPath = $Path
    Recurse     = $Recurse
    Include     = '*'    
    File        = ($FilterType -eq 'File')
    Directory   = ($FilterType -eq 'Folder')
}

    $objects = @()

    $objects = ForEach ($object in (Get-ChildItem @parameter | ComplexFilter)) {

        [PSCustomObject]@{
            Object = $object
            Time   = $object.LastWriteTime
            Depth  = ($object.FullName.Split("\\")).Count
            }
        }
<#
some $Action process Object in order, thus sort the objects
KeepFilesCount: by last write date
DeleteEmptyFolders: by depth of the file path hierarchy with counting separator in the path for deleteing the deepest folder at first
#>

Write-Output $(Switch -Regex ($Action) {
 
                    '^KeepFilesCount$'     {$objects | Sort-Object -Property Time}

                    '^DeleteEmptyFolders$' {$objects | Sort-Object -Property Depth -Descending}

                    Default                {$objects}
                
             })
}
end {
}

}


function ConvertTo-PreActionPath {

<#
.SYNOPSIS
Convert to new path with extention .zip or adding time stamp.



.DESCRIPTION
Find convert type in the -PreAction option.
-PreAction Compress, Archive, 7z, 7zZip, AddTimeStamp are supported.

Convert to new path with extention .zip or adding time stamp with the convert type.



.PARAMETER PATH
Specify a file path to convert.


.PARAMETER DESTINATIONPATH
Specify a desitination folder path.
Even if you do not specify -PreAction MoveNewFile, you need specify the desitination path.



.INPUT
System.String. Path of the file

.OUTPUT
PSobject
#>

[OutputType([PSObject])]
[CmdletBinding()]
Param(
[String][parameter(position = 0 ,mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("TargetObject" , "FullName")]$Path , 
[String][parameter(position = 1 ,mandatory, ValueFromPipelineByPropertyName)][Alias("destinationFolder")]$DestinationPath ,

[Array]$PreAction = $PreAction ,
[String]$CompressedExtString =  $CompressedExtString ,
[String]$TimeStampFormat = $TimeStampFormat
) 

begin {
    $archive = New-Object PSObject -Property @{
        Path = ''
        Type = ''
        }
}
process {
    IF (($PreAction -match '^(Compress|Archive)$')) {

#Switch to find all elements in [Array]$PreAction
#Find an element  '7z' or '7zZip' in the array till finding one. 

        Switch -Regex ($PreAction) {    
        
          '^7z$' {
                $archive.Type = "7z"
                $extension = '.7z'
                Break                
                }
                
           '^7zZip$' {
                $archive.Type = "7zZip"
                $extension = '.zip'
                Break
                }
                    
             Default {
                $archive.Type = ''
                $extension = $CompressedExtString
                }    
        }

    } else {
    $archive.Type = '' 
    $extension = ''
    }
 
    Switch -Regex ($PreAction) {    
        
          '^Compress$' {
                $archive.Type += "Compress"
                Break                
                }
                
           '^Archive$' {
                $archive.Type += "Archive"
                Break
                }
                    
             Default {
                }    
    }

    IF ($PreAction -contains 'AddTimeStamp') {

        $archive.Path = $DestinationPath |
            Join-Path -ChildPath (($Path | Split-Path -Leaf | ConvertTo-FileNameAddTimeStamp -TimeStampFormat $TimeStampFormat) + $extension)

        $archive.Type += $(IF ($PreAction -match '^(Compress|Archive)$') {"AndAddTimeStamp"} 
        
                            else {"AddTimeStamp"})

        } else {        
        $archive.Path = $DestinationPath | Join-Path -ChildPath (($Path | Split-Path -Leaf) + $extension)        
        }

        Write-Log -ID $InfoEventID -Type Information -Message "Create a new file [$($archive.Path | Split-Path -Leaf)] with action [$($archive.Type)]"

    IF ($PreAction -contains 'MoveNewFile') {

        Write-Log -ID $InfoEventID -Type Information -Message ("Specified -PreAction MoveNewFile["+[Boolean]($PreAction -contains 'MoveNewFile')+"] option, " + 
            "thus place the new file in the folder [$($DestinationPath)]")
        }

    Write-Output $archive
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

#Process Switch options

IF ($NoRecurse)        {[Boolean]$Script:Recurse = $FALSE}
IF ($ContinueAsNormal) {[Switch]$Script:Continue = $TRUE}
IF ($OverRideAsNormal) {[Switch]$Script:OverRide = $TRUE}
IF ($OverRideForce)    {[Switch]$Script:OverRide = $TRUE}


#Start validating parameters


#Validate -TargetFolder

$TargetFolder = $TargetFolder |
                    ConvertTo-AbsolutePath -Name '-TargetFolder' |
                    Test-PathEx -Type Container -Name '-TargetFolder' -IfFalseFinalize -PassThrough


#Validate -MoveToFolder

    IF (($Action -match "^(Move|Copy)$") -or ($PreAction -contains 'MoveNewFile')) {    

        $MoveToFolder = $MoveToFolder |
                            ConvertTo-AbsolutePath -Name '-MoveToFolder' |    
                            Test-PathEx -Type Container -Name '-MoveToFolder' -IfFalseFinalize -PassThrough
                            
    } elseIF (-not([String]::IsNullOrEmpty($MoveToFolder))) {
    
        Write-Log -ID $ErrorEventID -Type Error -Message "Specified -Action [$($Action)] option, must not specifiy -MoveToFolder option."
        Finalize $ErrorReturnCode
        }


#Validate -ArchiveFileName

    IF ($PreAction -contains 'Archive') {

        $ArchiveFileName | Test-PathEx -Type NotNullOrEmpty -Name '-ArchiveFileName' -IfFalseFinalize > $NULL

        IF ($ArchiveFileName -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
            Write-Log -Type Error -ID $ErrorEventID -Message "-ArchiveFileName may contain characters that can not use by NTFS."
            Finalize $ErrorReturnCode
            } 
        }


#Validate -7zFolder

    IF ($PreAction -match "^(7z|7zZip)$") {    

        $7zFolder = $7zFolder |
                        ConvertTo-AbsolutePath -Name '-7zFolder' |
                        Test-PathEx -Type Container -Name '-7zFolder' -IfFalseFinalize -PassThrough
    }


#Validate combinations of the options

    IF (($TargetFolder -eq $MoveToFolder) -and   (($Action -match "(move|copy)") -or ($PreAction -contains 'MoveNewFile'))) {
    
        Write-Log -Type Error -ID $ErrorEventID -Message ("Specified -(Pre)Action option for Move or Copy files, " +
            "-TargetFolder and -MoveToFolder must not be same.")
        Finalize $ErrorReturnCode
        }

    IF (($Action -match "^(Move|Delete|KeepFilesCount)$") -and  ($PostAction -ne 'none')) {

        Write-Log -Type Error -ID $ErrorEventID -Message ("Specified -Action[$($Action)] option for Delete or Move files, " +
            "must not specify -PostAction[$($PostAction)] option.")
        Finalize $ErrorReturnCode
        }

   IF (($PreAction -contains 'MoveNewFile') -and (-not($PreAction -match "^(Compress|AddTimeStamp|Archive)$")) ) {

        Write-Log -Type Error -ID $ErrorEventID -Message ("Secified -PreAction MoveNewFile option, " + 
            "must specify -PreAction Compres or AddTimeStamp or Archive option also. " +
            "If you want to move the original files, will specify -Action Move option.")
        Finalize $ErrorReturnCode
        }

   IF (($PreAction -contains 'Compress') -and ($PreAction -contains 'Archive')) {

        Write-Log -Type Error -ID $ErrorEventID "Must not specify -PreAction both Compress and Archive options in the same time."
        Finalize $ErrorReturnCode
        }

   IF (($PreAction -contains '7z') -and ($PreAction -Contains '7zZip')) {

        Write-Log -Type Error -ID $ErrorEventID -Message "Must not specify -PreAction both 7z and 7zZip options for the archive method in the same time."
        Finalize $ErrorReturnCode
        }

   IF (($PreAction -match "^(7z|7zZip)$") -and (-not($PreAction -match "^(Compress|Archive)$"))) {

        Write-Log -Type Error -ID $ErrorEventID -Message ("Must not specify -PreAction only 7z or 7zZip option. " +
            "Must specify -PreAction Compress or Archive option with them.")
        Finalize $ErrorReturnCode
        }

   IF ($Action -eq "DeleteEmptyFolders") {
    
        IF (($PreAction -match '^(Compress|Archive|AddTimeStamp)$')  -or ($PostAction -ne 'none' )) {
    
            Write-Log -Type Error -ID $ErrorEventID -Message ("Specified -Action [$Action] , " +
                "must not specify -PreAction or -PostAction options for modify files.")
            Finalize $ErrorReturnCode

        } elseIF ($Size -ne 0) {
    
            Write-Log -Type Error -ID $ErrorEventID -Message "Specified -Action [$Action] , must not specify -size option."
            Finalize $ErrorReturnCode
            }
    }


    IF ($TimeStampFormat -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
        Write-Log -Type Error -ID $ErrorEventID -Message "-TimeStampFormat may contain characters that can not use by NTFS."
        Finalize $ErrorReturnCode
        }


#Output starting messages

Write-Log -ID $InfoEventID -Type Information -Message "All parameters are valid."

    IF ($Action -eq "DeleteEmptyFolders") {

        Write-Log -ID $InfoEventID -Type Information -Message ("Find and Delete empty folders in target folder [$($TargetFolder)], " + 
            "older than [$($Days)]days, match up to regular expression [$($RegularExpression)], recursively[$($Recurse)]")
        
        } else {

        Write-Log -ID $InfoEventID -Type Information -Message ("Find files in the folder [$($TargetFolder)], older than [$($Days)]days, " + 
            "match up to regular expression [$($RegularExpression)], " +
            "parent path match up to regular expression [$($ParentRegularExpression)], " +
            "size is over["+($Size / 1KB)+"]KB")

#PreAction
        IF ($PreAction -notcontains 'none') {    

            $message = "Process files found " +

                    $(IF ($PreAction -contains    'MoveNewFile') {"moving new files created to [$($MoveToFolder)] "}) +

                    $(IF ($PreAction -match        "^(Compress|Archive)$") {
                
                        $(IF     ($PreAction -contains '7z'   ) {"with compress method [7z] "}            
                        elseIF   ($PreAction -contains '7zZIP') {"with compress method [7zZip] "}
                        else                                    {"with compress method [PowerShell cmdlet Compress-Archive] "}
                    )}) +
                    
                    ("recursively [$($Recurse)] PreAction (Add time stamp to filename[" + [Boolean]($PreAction -contains 'AddTimeStamp') + "] | " + 
                       "Compress[" + [Boolean]($PreAction -contains 'Compress') + "] | Archive to 1file[" + [Boolean]($PreAction -contains 'Archive') + "] )")

        Write-Log -ID $InfoEventID -Type Information -Message $message
        }

#Action
        IF ($Action -ne 'none') {

            $message = "Process files found " +
                       $(IF ($Action -eq    'KeepFilesCount') {"to keep file generation only[$($KeepFiles)] "}) +
                       $(IF ($Action -match '^(Copy|Move)$')  {"moving to[$($MoveToFolder)] "}) +
                       "recursively[$($Recurse)] Action[$($Action)]"

            Write-Log -ID $InfoEventID -Type Information -Message $message
            }

#PostAction
        IF ($PostAction -ne 'none') {

            $message = "Process files found " +
                       $(IF ($PostAction -eq 'Rename') { "rename with rule[$($RenameToRegularExpression)] "}) +
                       "recursively[$($Recurse)] PostAction[$($PostAction)]"

            Write-Log -ID $InfoEventID -Type Information -Message $message
            }
    }


    IF ($OverRide) {
        Write-Log -ID $InfoEventID -Type Information -Message ("Specified -OverRide[$($OverRide)] option, " +
            "thus if files exist with the same name in the destination, will override them.")
            }

    IF ($ContinueAsNormal) {
        Write-Log -ID $InfoEventID -Type Information -Message ("Specified -ContinueAsNormal[$($ContinueAsNormal)] option, " +
            "thus if a file exist with the same name already in the destination, will process next file with logging a NORMAL event without termination.")
        
        } elseIF ($Continue) {
            Write-Log -ID $InfoEventID -Type Information -Message ("Specified -Continue[$($Continue)] option, " +
                "thus if a file exist with the same name already in the destination, will process next file with logging a WARNING event without termination.")
            }

}


function Finalize {

Param(    
[parameter(position = 0, mandatory)][int]$ReturnCode ,

[int]$NormalCount = $NormalCount ,
[int]$WarningCount = $WarningCount ,
[int]$ErrorCount = $ErrorCount ,
[boolean]$OverRide = $OverRide ,
[int]$OverRideCount = $OverRideCount ,

[Boolean]$ErrorFlag     = $FALSE ,
[boolean]$Continue = $Continue ,
[int]$ContinueCount = $ContinueCount
)
    $ForceFinalize = $FALSE
 
    IF ( ($NormalCount + $WarningCount + $ErrorCount) -ne 0 ) {    

       Write-Log -ID $InfoEventID -Type Information -Message "The results of execution NORMAL[$($NormalCount)] WARNING[$($WarningCount)] ERROR[$($ErrorCount)]"


        IF ($OverRide -and ($OverRideCount -gt 0)) {
            Write-Log -ID $InfoEventID -Type Information -Message ("Specified -OverRide[$($OverRide)] option, " +
                "thus overrided files in the destination with source files in [$($OverRideCount)] times.")
            }

        IF (($Continue) -and ($ContinueCount -gt 0)) {
            Write-Log -ID $InfoEventID -Type Information -Message ("Specified -Continue[$($Continue)] option, " +
                "thus continued to process next objects in [$($ContinueCount)] times even though the same name files exist in the destination.")
            }
    }

 Invoke-PostFinalize $ReturnCode
}


#####################  main  ######################

[String]$DatumPath = $PSScriptRoot

$Version = "3.0.1 beta-1"
[Boolean]$WarningFlag   = $FALSE
[Boolean]$NormalFlag    = $FALSE
[Boolean]$OverRideFlag  = $FALSE
[Boolean]$ContinueFlag  = $FALSE
[Boolean]$WhatIfFlag    = ($NULL -ne $PSBoundParameters['WhatIf'])

[Int]$ErrorCount    = 0
[Int]$WarningCount  = 0
[Int]$NormalCount   = 0
[Int]$OverRideCount = 0
[Int]$ContinueCount = 0
[Int]$InLoopDeletedFilesCount = 0

[Boolean]$ForceEndloop  = $FALSE          ;#$FALSE for Finalize , $TRUE for Break in the loop


#initialize, validate parameters, output starting message

. Initialize


$returnCode = $NormalReturnCode

:main DO {

#find files or folders and put them to the object

$filterType = $(IF ($Action -eq "DeleteEmptyFolders") {"Folder"} 

                else {"File"})


$targets = @()

$targets = $TargetFolder | Get-Object -FilterType $filterType

    IF ($NULL -eq $targets) {

        Write-Log -ID $InfoEventID -Type Information -Message "In -TargetFolder [$($targetFolder)] no [$($filterType)] exists for processing."

        IF ($NoneTargetAsWarning) {

            Write-Log -ID $WarningEventID -Type Warning -Message ("Specified -NoneTargetAsWarning option, " +
                "thus terminiate $($ShellName) with a Warning.")
            $returnCode = $WarningReturnCode                     
            }

        Break main
    }

Write-Log -ID $InfoEventID -Type Information -Message "[$(($targets | Measure-Object).Count)] [$($filterType)(s)] exist for processing."

Write-Debug   "[$(($targets | Measure-Object).Count)][$($filterType)(s)] are for processing..."

Write-Debug   ("`r`n" + ($targets.Object.fullname | Out-String))

Write-Verbose ("[$(($targets | Measure-Object).Count)][$($filterType)(s)] are for processing..." + "`r`n" + ($targets.Object.fullname | Out-String))


#-PreAction Archive processes files to archive to one file, thus before loop create an archived file

IF ($PreAction -contains 'Archive') {

    $destination = $(IF ($PreAction -contains 'MoveNewFile') {$MoveToFolder}
        
                    else {$TargetFolder})


    $archive = $ArchiveFileName | ConvertTo-PreActionPath -DestinationPath $destination
 
    IF ($archive.Path | Test-LeafNotExists) {

        Write-Log -ID $InfoLoopStartEventID -Type Information -Message "--- Start PRE-processing to [$($PreAction)] all files to one file [$($archive.Path)]  ---"

        ForEach ($Target in $targets) {
    
            Invoke-Action -Type $archive.Type -ActionFrom $Target.Object.FullName -ActionTo $archive.Path -ActionError $Target.Object.FullName
        
        }

        Write-Log -ID $InfoLoopEndEventID -Type Information -Message "--- End PRE-processing to [$($PreAction)] all files to one file [$($archive.Path)]  ---"
            
    } else {

        Write-Log -ID $ErrorEventID -Type Error -Message ("File/Folder exists in the path [$($archive.Path)] already, " +
            "thus terminate $($ShellName) with an Error.")

        $returnCode = $ErrorReturnCode
        Break main
        }
    
}

#Start loop to process objects(Files or Folders)

:forLoop ForEach ($Target in $targets) {
<#
'Goto' state dose not exist in PowerShell, thus no conditional branch in the program.
Thus use Do/While() state for branch action when errors occure in loop section.

Do/While() loop state evaluating in the end of the loop. In switching to false in evalutating at While(), end the loop.
If set 'While($FALSE)' , Do-While() loop process once.
If 'Break' in the loop, jump to 'While($FALSE)'

Cases of actions when errors occure in the loop (such as 'Invoke Action Delete but dose not have permission, thus fail to delete)

Case1 Jump to 'While()' and output the result, and process a next file.
    Break , $ForceEndloog = $TRUE , $ForceFinalize = $FALSE

Case2 Jump to 'While()' and output the result, and Finalize for termination
    Break , $ForceEndloog = $TRUE , $ForceFinalize = $TRUE

Case3 Jump to Finalize for temination (dose not output the result)
    Finalize $ErrorReturnCode
#>

:do Do {

[Boolean]$ErrorFlag     = $FALSE
[Boolean]$WarningFlag   = $FALSE
[Boolean]$NormalFlag    = $FALSE
[Boolean]$OverRideFlag  = $FALSE
[Boolean]$ContinueFlag  = $FALSE
[Boolean]$ForceFinalize = $FALSE  ;#If this flag is $TRUE, force terminate at end of the loop when error occures. This flag may set $FALSE in CommonFunctions.ps1
[Int]$InLoopOverRideCount = 0     ;#$OverRideCount means counter of all over the process. $InLoopOverRideCount means counter of the process in the only one object. (over ride may occure at one object a few times)

[Boolean]$ForceEndloop  = $TRUE   ;#$FALSE for Finalize , $TRUE for Break in the loop  If an error occures in the loop, Jump to the end of the loop and output the result of the process

Write-Log -ID $InfoLoopStartEventID -Type Information -Message "--- Start processing [$($filterType)] [$($Target.Object.FullName)] ---"

<#
Create a destinationFolder(child folder of the MoveToFolder) with Target.Object.FullName
If NoRecurse, destinationFolder will be, thus skip
Without Action[(Move|Copy)] , dose not need to checke existence of destinationPath

C:\TargetFolder                    :TargetFolder
C:\TargetFolder\A\B\C              :Target.Object.DirectoryName
C:\TargetFolder\A\B\C\target.txt   :Target.Object.FullName

D:\MoveToFolder                    :MoveToFolder
D:\MoveToFolder\A\B\C              :destinationFolder
D:\MoveToFolder\A\B\C\target.txt   :destinationPath

To create a destinationFolder, extract \A\B\C\ from TargetFolder and Join-Path MoveToFolder
String.Substring method extract from the argument to the end in the string
Even if NoRecurse, a destinationFolder is needed in Move or Copy action
#>
    IF (($Action -match "^(Move|Copy)$") -or  (($PreAction -contains 'MoveNewFile') -and ($PreAction -notcontains 'Archive')) ) {

        $destinationFolder = $MoveToFolder | Join-Path -ChildPath ($Target.Object.DirectoryName).Substring($TargetFolder.Length)

        IF ($Recurse) {

            IF (-not($destinationFolder | Test-PathEx -Type Container -Name 'destination folder of the file ')) {

                Write-Log -ID $InfoEventID -Type Information -Message "Create a new folder $($destinationFolder)"

                Invoke-Action -Type MakeNewFolder -ActionFrom $destinationFolder -ActionError $destinationFolder

#error occure in $Invoke-Action &-Continue $TRUE, $ContinueFlag switch to $TRUE. In the condtion, jump to the next object.
                IF ($ContinueFlag) {
                    Break do                
                    }
            }
        }
    }

#Pre Action

    IF (($PreAction -match '^(Compress|AddTimeStamp)$')) {

        $destination = $(IF ($PreAction -contains 'MoveNewFile') {$destinationFolder}

                        else {$Target.Object.DirectoryName})


        $archive = $Target.Object.FullName | ConvertTo-PreActionPath -DestinationPath $destination

        IF ($archive.Path | Test-LeafNotExists) {

            Invoke-Action -Type $archive.Type -ActionFrom $Target.Object.FullName -ActionTo $archive.Path -ActionError $Target.Object.FullName
            }
    }

#Main Action

    Switch -Regex ($Action) {

#case1 do nothing
        '^none$' {
            IF ( ($PostAction -eq 'none') -and ($PreAction -match '(none|Archive)') ) {
                Write-Log -ID $InfoEventID -Type Information -Message ("Specified -Action [$($Action)] option, " +
                    "thus do not process [$($Target.Object.FullName)]")
                }
        }

#case2 delete
        '^Delete$' {
            Invoke-Action -Type Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName
        } 

#case3 move or copy　process after testing existence of the same name file in the destination
        '^(Move|Copy)$' {
            $destinationPath = $destinationFolder | Join-Path -ChildPath ($Target.Object.Name)

            IF ($destinationPath | Test-LeafNotExists) {

                Invoke-Action -Type $Action -ActionFrom $Target.Object.FullName -ActionTo $destinationPath -ActionError $Target.Object.FullName 
            }
        }

#case4 delete empty folder after testing the folder is empty
        '^DeleteEmptyFolders$' {
            Write-Log -ID $InfoEventID -Type Information -Message  "Check the folder [$($Target.Object.FullName)] is empty."

            IF ($Target.Object.GetFileSystemInfos().Count -eq 0) {

                Write-Log -ID $InfoEventID -Type Information -Message  "The folder [$($Target.Object.FullName)] is empty."
                Invoke-Action -Type Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName

            } else {
                Write-Log -ID $InfoEventID -Type Information -Message "The folder [$($Target.Object.FullName)] is not empty." 
            }
        }

#case5 clear with null
        '^NullClear$' {
            Invoke-Action -Type NullClear -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName          
        }

#case6 KeepFilesCount
        '^KeepFilesCount$' {
            IF ((@($targets).Length - $InLoopDeletedFilesCount) -gt $KeepFiles) {

                Write-Log -ID $InfoEventID -Type Information -Message  ("More than [$($KeepFiles)] files exist in the folder, " +
                    "thus delete the oldest [$($Target.Object.FullName)]")

                Invoke-Action -Type Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName

#error occure in $Invoke-Action &-Continue $TRUE, $ContinueFlag switch to $TRUE. In the condtion, jump to the next object.
                IF ($ContinueFlag) {
                    Break do      
                }
                
                $InLoopDeletedFilesCount++
            
            } else {            
                Write-Log -ID $InfoEventID -Type Information -Message  ("Less [$($KeepFiles)] files exist in the folder, " +
                "thus do not delete [$($Target.Object.FullName)]")
            }
        }

#case7 $Action dose not match up to the cases, it must be internal error
        Default {
            Write-Log -ID $InternalErrorEventID -Type Error -Message "Internal Error at Switch Action section. A bug in regex may cause it."
            $returnCode = $InternalErrorReturnCode
            Break main
        }
    }


#Post Action

    Switch -Regex ($PostAction) {

#case1 do nothing
        '^none$' {            
            }

#case2 Rename after testing existence of a file with new renamed name in the path
        '^Rename$' {
            $newFilePath = $Target.Object.DirectoryName |
                            Join-Path -ChildPath (($Target.Object.Name) -replace "$RegularExpression" , "$RenameToRegularExpression") |
                            ConvertTo-AbsolutePath -Name 'Filename renamed'
                            
            IF ($newFilePath | Test-LeafNotExists) {

                Invoke-Action -Type Rename -ActionFrom $Target.Object.FullName -ActionTo $newFilePath -ActionError $Target.Object.FullName
    
            } else {
                Write-Log -ID $InfoEventID -Type Information -Message  ("A file [$($newFilePath)] already exists as attempting rename, " +
                "thus do not rename [$($Target.Object.FullName)]")
            }
        }

#case3 clear with null 
        '^NullClear$' {
            Invoke-Action -Type NullClear -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName          
        }


#case4 $Action dose not match up to the cases, it must be internal error
        Default {
            Write-Log -ID $InternalErrorEventID -Type Error -Message "Internal error at Switch PostAction section. A bug in regex may cause it."
            $returnCode = $InternalErrorReturnCode
            Break main
        }
    }
}


While ($FALSE) ;#end of :Do


#Count up Error > Warning > Normal 

    IF ($ErrorFlag) {
        $ErrorCount++
        } elseIF ($WarningFlag) {
            $WarningCount++
            } elseIF ($NormalFlag) {
                $NormalCount++
                }

    IF ($ContinueFlag) {
        $ContinueCount++
        }
         
    Write-Log -ID $InfoLoopEndEventID -Type Information -Message ("--- End processing [$($filterType)] [$($Target.Object.FullName)]  " + 
        "Results  Normal[$($NormalFlag)] Warning[$($WarningFlag)] Error[$($ErrorFlag)]  " +
        "Continue[$($ContinueFlag)]  OverRide[$($InLoopOverRideCount)] ---")

    IF ($ForceFinalize) {
        $returnCode = $ErrorReturnCode
        Break main
        }

} ;#end of :forLoop

}

While ($FALSE) ;#end of :main

IF ($returnCode -lt $InternalErrorReturnCode) {

    IF (($ErrorCount -gt 0)  -or ($returnCode -ge $ErrorReturnCode)) {
        
        $returnCode = $ErrorReturnCode

        } elseIF (($WarningCount -gt 0) -or ($returnCode -ge $WarningReturnCode)) {
            
            $returnCode = $WarningReturnCode
            }
    }

Finalize -ReturnCode $returnCode
