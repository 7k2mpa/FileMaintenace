#Requires -Version 3.0

<#
.SYNOPSIS
This script unmount a network drive.
CommonFunctions.ps1 is required.
You can unmount multiple network drives with Wrapper.ps1
<Common Parameters> is not supported.

�}�E���g�σl�b�g���[�N�h���C�u���A���}�E���g����v���O�����ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B
�Z�b�g�ŊJ�����Ă���Wrapper.ps1�ƕ��p����ƕ����̃h���C�u�������ł��܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION

This script unmount Network drive.
Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 

�}�E���g�σl�b�g���[�N�h���C�u���A���}�E���g����v���O�����ł��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B


.EXAMPLE
UnMountDrive.ps1 -MountedDrive F:

UnMount SMB share mapped as Drive F:

�}�E���g�σl�b�g���[�N�h���C�u��F:���A���}�E���g���܂��B




.PARAMETER MountedDrive
Specify drive letter mapped.
Specification is required.

�A���}�E���g�Ώۂ̃}�E���g�σh���C�u��F:���w�肵�܂��B
�w��K�{�ł��B




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

[parameter(position = 0, mandatory, HelpMessage = 'Specify Drive Letter (ex. F:) or Get-Help UnMountDrive.ps1')]
[String][ValidatePattern('^[d-zD-Z]:$')]$MountedDrive ,

#[String][ValidatePattern('^[d-z]:$')]$MountedDrive="F:" ,


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

    #CommonFunctions.ps1�̔z�u���ύX�����ꍇ�́A������ύX�B����t�H���_�ɔz�u�O��
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "Fail to load CommonFunctions.ps1 Please verfy existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }


################ �ݒ肪�K�v�Ȃ̂͂����܂� ##################

################# ���ʕ��i�A�֐�  #######################


function Initialize {

$ShellName = $PSCommandPath | Split-Path -Leaf

#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. Invoke-PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�



#�p�����[�^�̊m�F


#�h���C�u�����Ƀ}�E���g����Ă��邩

    $driveLetters = (Get-WmiObject Win32_LogicalDisk).DeviceID

    IF ($driveLetters.Contains($MountedDrive)) {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage  "Drive $($MountedDrive) exists already."


        [Object]$drive = Get-WMIObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $MountedDrive }
        IF ($drive.DriveType -ne 4) {
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Drive $($MountedDrive) is not network drive."
                    Finalize $ErrorReturnCode
                    }

    } else {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Drive $($MountedDrive) dose not exists."
        Finalize $ErrorReturnCode
        }

#�����J�n���b�Z�[�W�o��


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to unmount drive ${MountedDrive}"


}

function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)


 Invoke-PostFinalize $ReturnCode


}


#####################   ��������{��  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.8"

$psDrive = $MountedDrive.Replace(":","") 

#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

Try{

    Remove-SmbMapping -LocalPath $MountedDrive -Force -UpdateProfile  -ErrorAction Continue

    If ( (Get-PSDrive -Name $psDrive) 2>$NULL ) {
        Remove-PSDrive -Name $psDrive -Force  -ErrorAction Stop
        }

    }

    catch [Exception] {
        $errorDetail = $ERROR[0] | Out-String
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to unmount drive $($MountedDrive)"
	    Finalize $ErrorReturnCode
        }

Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Completed to unmount drive ${MountedDrive} successfully."

Finalize $NormalReturnCode     
