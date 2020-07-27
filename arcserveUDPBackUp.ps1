#Requires -Version 3.0

<#
.SYNOPSIS

This script starts arcserve UDP backup job with arcserve UDP CLI.
CommonFunctions.ps1 is required.



.DESCRIPTION

This script starts arcserve UDP backup job with arcserve UDP CLI.
CommonFunctions.ps1 is required.
Can specify full or incremental backup.
Can specify authorization style plain password or password file.
If you want to specify password authorization, execution user must be same with user of password file.
It is a future of Windows.

If you specify -ExecUser arcserve and start script with another user, can not authorization with password file of 'arcserve' user.

This scripts support the location of arcserve backup console server both in the same host or in the other.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to suppress or to output individually.  

Path sample

D:\script\infra\arcserveUDPBackUp.ps1
D:\script\infra\Log\backup.flg
D:\script\infra\UDP.psw



.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -Server SVDB01 -BackUpJobType Incr

Start incremental backup targeting server [SVDB] in the plan [SSDB] 


.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -AllServers -BackUpJobType Full -UDPConsoleServerName BKUPSV01.corp.local

Start full backup targeting all servers in the plan [SSDB]
and specify arcserve UDP console BKUPSV01.corp.local 


.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -Server SVDB02 -BackUpJobType Incr -AuthorizationType PlainText -ExecUser = 'arcserve' -ExecUserDomain = 'INTRA' -ExecUserPassword = 'hogehoge'

Start incremental backup targeting server[SVDB02] in the plan [SSDB] 
with plain password.
Specify execution backup domain user [INTRA\arcserve] password [hogehoge]
You can specify other user from running the script, but you shoud not use plain pssword for security reason.


.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -AllServers -BackUpJobType Full -AuthorizationType JobExecUserAndPasswordFile -ExecUserPasswordFilePath '.\UDP.psw'

Start full backup targeting all servers in the plan [SSDB] 
Autorization style is execution user of the script and password file.
You need to make password file in the same user of executing the script.
Password file name is set with the user name automatically.
'_[username]' is added to the filename to load.
If you specify '.\UDP.psw' and execution user is 'Domain\arcserve' , this script load the password file '.\UDP_arcserve.psw'



.PARAMETER Plan

Specify a plan in arcserve UDP.
Specification is required.
Wild card dose not be accepted.


.PARAMETER Server

Specify one server name in the -Plan option.
Can not specify a server name not in the plan.
Wild card dose not be accepted.


.PARAMETER AllServers

If you want to specify all servers in the -Plan option.


.PARAMETER BackUpJobType

Specify back up type.
Full:Full BackUp
Incr:Incremental BackUp


.PARAMETER BackupFlagFilePath

Specify lock file path of back up status.
This script generetes and saves flag file with plan name and server name added.
If specify -AllServers option, file name be with 'All'


.PARAMETER PROTOCOL

Specify protocol to logon to arcserve UDP console server.
http or https are allowed.
[http] is default.


.PARAMETER UDPConsolePort

Specify port number to logon to arcserve UDP console server.
[8015] is default.


.PARAMETER UDPCLIPath

Specify arcserve UDP CLI folder path.
Relative or absolute path format is allowed.


.PARAMETER AuthorizationType

Specify authorization type to logon to the arcserve UDP console server.

JobExecUserAndPasswordFile:script execution user / password file(user name is added to the file name )
FixedPasswordFile:fixed user / password file
PlanText:fixed user / plain password string


.PARAMETER ExecUser

Specify OS user to logon to the arcserve UDP console in authorization type PlainText or FixedPasswordFile.
If domain user runs the script, you specify user name without domain name.

Sample:FooDOMAIN\BarUSER , specify -ExecUser BarUSER


.PARAMETER ExecUserDomain

Specify OS user's domain to logon to the arcserve UDP console in authorization type PlainText or FixedPasswordFile.

Sample:FooDOMAIN\BarUSER , specify -ExecDomain FooDOMAIN


.PARAMETER ExecUserPassword

Specify OS user's password in plain text to logon to the arcserve UDP console in authorization type PlainText or FixedPasswordFile.


.PARAMETER FixedPasswordFilePath

Specify password file path in authorization style [FixedPasswordFile] to logon to the arcserve UDP console.


.PARAMETER ExecUserPasswordFilePath

Specify password file path in authorization style [JobExecUserAndPasswordFile] to logon to the arcserve UDP console.

Sample:'.\UDP.psw' , script running user FooDOMAIN\BarUSER
password file '.UDP_BarUSER.psw' will be loaded automatically.

_ and script running user name are inserted to the path specificated.


.PARAMETER UDPConsoleServerName

Specify arcserve UDP console server's host name or IP address.



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
Param(

[String][parameter(position = 0, mandatory, HelpMessage = 'Enter plan name in arcserveUDP console. To View all help, Get-Help arcserveUDPBackUp.ps1')]$Plan ,

[String][parameter(position = 1)][ValidateSet("Full", "Incr")]$BackUpJobType = 'Incr',

[String][parameter(position = 2)][ValidateNotNullOrEmpty()]$Server ,

[Switch]$AllServers,


[String][parameter(position = 3)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$BackupFlagFilePath = '.\Lock\BackUp.flg' ,

[String][parameter(position = 4)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$UDPCLIPath = 'D:\arcserve\Management\PowerCLI\UDPPowerCLI.ps1',

[String][parameter(position = 5)]$ExecUserPasswordFilePath = '.\UDP.psw' ,

[String][parameter(position = 6)][ValidateSet("JobExecUserAndPasswordFile","FixedPasswordFile" , "PlainText")]$AuthorizationType = 'JobExecUserAndPasswordFile' ,



[String]$ExecUser = 'arcserve',
[String]$ExecUserDomain = 'Domain',
[String]$ExecUserPassword = 'hogehoge',
[String]$FixedPasswordFilePath = '.\UDP_arcserve.psw' ,

[String]$UDPConsoleServerName = 'localhost' ,

[String][ValidateSet("http", "https")]$PROTOCOL = 'http' ,
[int]$UDPConsolePort = 8015 ,



#[String][ValidatePattern('^(\.+\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommonConfigPath = '.\CommonConfig.ps1' , #MUST specify with relative path format
[String][ValidatePattern('^(\.+\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommonConfigPath = $NULL ,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String][ValidateNotNullOrEmpty()]$ProviderName = "Infra",
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

    IF (-not($AllServers)) {

        IF ([String]::IsNullOrEmpty($Server)) {

            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Did not specify -AllServers option, although -Server option is null or empty."
            Finalize $ErrorReturnCode                    

            } else {
            $Server | Test-Hostname -ObjectName 'BackUp target -Server' -IfInvalidFinalize > $NULL
            }
        }

    $UDPConsoleServerName | Test-Hostname -ObjectName 'arcserveUDP Console Server -UDPConsoleServerName' -IfInvalidFinalize > $NULL


    IF ($AuthorizationType -match '^(FixedPasswordFile|PlainText)$' ) {

        $ExecUserDomain | Test-DomainName -ObjectName 'The domain of execution user -ExecUserDomain' -IfInvalidFinalize > $NULL    
        $ExecUser | Test-UserName -ObjectName 'Execution user -ExecUser ' -IfInvalidFinalize > $NULL

        }


#Test UDPConsole

    IF (Test-Connection -ComputerName $UDPConsoleServerName -Quiet) {
    
        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "UDP Console Server [$($UDPConsoleServerName)] responsed."

        } else {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "UDP Console Server [$($UDPConsoleServerName)] did not response. Check -UDPConsoleServerName"
        Finalize $ErrorReturnCode
        }


#Test Password File

    IF ($AuthorizationType -match '^FixedPasswordFile$' ) {

        $FixedPasswordFilePath  = $FixedPasswordFilePath |
                                    ConvertTo-AbsolutePath -Name '-FixedPasswordFilePath' |
                                    Test-PathEx -Type Leaf -Name '-FixedPasswordFilePath' -IfFalseFinalize -PassThrough
        }

    IF ($AuthorizationType -match '^JobExecUserAndPasswordFile$' ) {

        $ExecUserPasswordFilePath  = $ExecUserPasswordFilePath | ConvertTo-AbsolutePath -Name '-ExecUserPasswordFilePath'
    
        $ExecUserPasswordFilePath | Split-Path -Parent | Test-PathEx -Type Container -Name 'Parent Folder of -ExecUserPasswordFilePath' -IfFalseFinalize > $NULL

        }

    $BackupFlagFilePath  = $BackupFlagFilePath | ConvertTo-AbsolutePath -Name '-BackupFlagFilePath'
    
    $BackupFlagFilePath | Split-Path -Parent | Test-PathEx -Type Container -Name 'Parent Folder of -BackupFlagFilePath' -IfFalseFinalize > $NULL


#Validate arcserveUDP CLI
    
    $UDPCLIPath = $UDPCLIPath |
                    ConvertTo-AbsolutePath -Name 'arcserve -UDPCLIPath ' |
                    Test-PathEx -Type Leaf -Name 'arcserve -UDPCLIPath ' -IfFalseFinalize -PassThrough


#output starting messages

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to execute arcserve UDP back up method [$($BackUpJobType)]"

}


function Finalize {

Param(
[parameter(position = 0, mandatory)][int]$ReturnCode ,

[String]$BackupFlagFilePath = $BackupFlagFilePath
)

    Pop-Location

    IF ($BackupFlagFilePath | Test-PathEx -Type Leaf -Name 'BackUp Flag') {
        Invoke-Action -ActionType Delete -ActionFrom  $BackupFlagFilePath -ActionError "BackUp Flag [$($BackupFlagFilePath)]"
        }


 Invoke-PostFinalize $ReturnCode

}


##################### Main ######################

$DatumPath = $PSScriptRoot

$Version = "3.0.0-alpha"
 
 
#initialize, validate parameters, output starting message

. Initialize


    [Array]$userInfo = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -split '\\'

    $doDomain = $userInfo[0]
    $doUser   = $userInfo[1]

#Create Invoke Command Strings

    $command = '.\"' + ($UDPCLIPath | Split-Path -Leaf) + '"' 

    $command += " -UDPConsoleServerName $UDPConsoleServerName -Command Backup -BackupJobType $BackUpJobType -UDPConsoleProtocol $PROTOCOL -UDPConsolePort $UDPConsolePort -AgentBasedJob False"



    IF ($AllServers) {

       Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Back up targets are all servers in the Plan [$($Plan)]"
       $command +=  " -PlanName $Plan "
       $Server = 'All'
       
       } else {
       Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Back up target is [$($Server)] in the Plan [$($Plan)]"
       $command += " -NodeName $Server "

       }



    Switch -Regex ($AuthorizationType){

    '^JobExecUser$' {
        #今のところ、この認証方式はarcserve UDPでは出来ない。実行ユーザが権限を持っていても(パスワードファイル|パスワード)を与える必要がある
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Authorization type is [$($AuthorizationType)] Authorize with user name executing and permission."
        }

    '^JobExecUserAndPasswordFile$' {
    
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Authorization type is [$($AuthorizationType)] Authorize with user name executing and the password file specified."

        $extension                = [System.IO.Path]::GetExtension(($ExecUserPasswordFilePath | Split-Path -Leaf))
        $fileNameWithOutExtention = [System.IO.Path]::GetFileNameWithoutExtension(($ExecUserPasswordFilePath | Split-Path -Leaf))

        $ExecUserPasswordFileName = $fileNameWithOutExtention + "_" + $doUser + $extension

        
        $ExecUserPasswordFilePath = $ExecUserPasswordFilePath |
                                        Split-Path -Parent |
                                        Join-Path -ChildPath $ExecUserPasswordFileName |
                                        Test-PathEx -Type Leaf -Name '-ExecUserPasswordFilePath' -IfFalseFinalize -PassThrough

        $command += " -UDPConsoleUserName `'$doUser`' -UDPConsoleDomainName `'$doDomain`' -UDPConsolePasswordFile `'$ExecUserPasswordFilePath`' "
        }

    '^FixedPasswordFile$' {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Authorization type is [$($AuthorizationType)] Authorize with user specified and the password file specified."
        $command += "-UDPConsoleDomainName `'$ExecUserDomain`' -UDPConsoleUserName `'$ExecUser`' -UDPConsolePasswordFile `'$FixedPasswordFilePath`' "
        }

    '^PlainText$' {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Authorization type is [$($AuthorizationType)] Authorize with user specified and plain password text."
        $command += "-UDPConsoleDomainName `'$ExecUserDomain`' -UDPConsoleUserName `'$ExecUser`' -UDPConsolePassword `'$ExecUserPassword`' "
        }

    Default {

        Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error -AuthorizationType is invalid."
        Finalize $ErrorReturnCode
        }
    }

#BackUp Flag Check and Create

     $extension                = [System.IO.Path]::GetExtension(($BackupFlagFilePath | Split-Path -Leaf))
     $fileNameWithOutExtention = [System.IO.Path]::GetFileNameWithoutExtension(($BackupFlagFilePath | Split-Path -Leaf))

     $BackupFlagFileName = $fileNameWithOutExtention + "_" + $Plan + "_" + $Server + $extension
        
     $BackupFlagFilePath = $BackupFlagFilePath | Split-Path -Parent | Join-Path -ChildPath $BackupFlagFileName



    IF ($BackupFlagFilePath | Test-PathEx -Type Leaf -Name 'Back up flag') {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Back Up is running. Stop for avoiding overlap."
        Finalize $ErrorReturnCode
        }

    Test-PathEx -Type Log -Path $BackupFlagFilePath -Name 'Folder of backup flag' -IfFalseFinalize

#Invoke PowerCLI command

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute arcserveUDP CLI [$($UDPCLIPath)]"

    Push-Location ($UDPCLIPath | Split-Path -Parent)

    Try {
        $return = Invoke-Expression $command 2>$errorMessage -ErrorAction Stop 
        }

        catch [Exception] {

            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute arcserveUDP CLI [$($UDPCLIPath)]"
            $errorDetail = $ERROR[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
        }


    IF ($return -ne 0) {
                   
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Falied to start backup Server [$($Server)] in the Plan [$($Plan)] Method [$($BackUpJobType)]"
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Error Message [$($errorMessage)]"
        $result = $ErrorReturnCode         

        } else {

        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to start backup Server [$($Server)] in the Plan [$($Plan)] Method [$($BackUpJobType)]"
        $result = $NormalReturnCode
        }

Finalize -ReturnCode $result
