#Requires -Version 3.0

<#
.SYNOPSIS
This script deletes Oracle Achive logs older than specified days.
Archive log files are deleted in Oracle RMAN records only and you need to delete log files in the file system with OS's delete command.
CommonFunctions.ps1 , DeleteArachiveLog.rman are required.

<Common Parameters> is not supported.


�w����ȑO��Oracle Archive Log���폜����c�[���ł��B
Oracle�̎d�l��AOracle����Â�Archive Log�͔F������Ȃ��Ȃ�܂����A�t�@�C���V�X�e����̃t�@�C���͍폜����܂���B
�ʓr�AOS�R�}���h��FileMaintenance.ps1�Ńt�@�C�����폜���Ă��������B 

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION 
This script deletes Oracle Achive logs older than specified days.
The script loads DeleteArchivelog.rman, place DeleteArchivelog.rman previously.
You can specify how old days to delte with arugument.

With OS authentication, $env:ORACLE_SID is used for connecting to RMAN.
If you connect another target, set $env:ORACLE_SID before start the script.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


�w����ȑO��Oracle Archive Log���폜����c�[���ł��B
�Z�b�g�Ŏg�p����DeleteArchivelog.rman��ǂݍ��݁A���s���܂��B�\�ߔz�u���Ă��������B
���s�̍ۂɁA�����O���폜���邩�A�����Ŏw�肪�\�ł��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B


File Path sample

.\OracleDeleteArchiveLog.ps1
.\CommonFunctions.ps1
..\SQL\DeleteArchiveLog.rman
..\Log\RMAN.LOG


.EXAMPLE

OracleDeleteArchiveLog.ps1 -OracleRmanLogPath ..\Log\RMAN.log -Days 7

Delete archivelog older than 7days in Oracle SID set previously.
Output log to relative path ..\Log\Rman.log for RMAN execution result.
If Rman.log file dose not exist, create a new log file.
Authentification for connecting is with OS authetification, thus the user running the script is authetificated.
Add administrator priviledge for the user at Oracle Administration Assistant for Windows.

Specify parameter on
$ORACLE_HOME\network\admin\sqlnet.ora 

SQLNET.AUTHENTICATION_SERVICES = (NTS)


�\�ߐݒ��OracleSID�̃C���X�^���X��7���ȑO��archive log���폜���܂��B
RMAN���s���ʂ̃��O�͖{�X�N���v�g�z�u���猩�āA���΃p�X��..\Log\Rman.log�ɏo�͂��܂��B
Rman.log�����݂��Ȃ��ꍇ�̓t�@�C����V�K�쐬���܂��B
RMAN���s���̔F�؂�OS�F�؂ƂȂ�A���̃X�N���v�g�����s���Ă��郆�[�U���X�N���v�g���s���[�U�ƂȂ�܂��B
���Y���s���[�U�ɑ΂���Oracle Administration Assistant for Windows���g���āA�Ǘ��Ҍ�����t�^���Ă����ĉ������B
$ORACLE_HOME\network\admin\sqlnet.ora �t�@�C���Ɉȉ��̋L�q���K�v�ł��B
SQLNET.AUTHENTICATION_SERVICES = (NTS)


.EXAMPLE

OracleDeleteArchiveLog.ps1 -OracleSID MCFRAME -OracleRmanLogPath ..\Log\RMAN.log -Days 7 -PaswordAuthorization -ExecUser foo -ExecUserPassword bar

Delete archivelog older than 7days in Oracle SID MCFRAME(Windows Service name OracleServiceMCFRAME)
Output log to relative path ..\Log\Rman.log for RMAN execution result.
If Rman.log file dose not exist, create a new log file.
Authentification for connecting is with plain text user 'foo' and password 'bar'.
Recommend OS authentification for security.


Oracle�T�[�r�X��MCFRAME�iOS��̃T�[�r�X��OracleMCFRAME�j�̃C���X�^���X��7���ȑO��archive log���폜���܂��B
RMAN���s���ʂ̃��O�͖{�X�N���v�g�z�u���猩�āA���΃p�X��..\Log\Rman.log�ɏo�͂��܂��B
Rman.log�����݂��Ȃ��ꍇ�̓t�@�C����V�K�쐬���܂��B
RMAN���s���̔F�؂̓p�X���[�h�F�؂ƂȂ�A-ExecUser�A-ExecUserPassword�Ŏw�肳�ꂽ���[�Ufoo�A�p�X���[�hbar��Oracle�֐ڑ����܂��B
�Z�L�����e�B�̊ϓ_����ɗ�OS�F�؂𗘗p����鎖�𐄏����܂��B



.PARAMETER OracleSID
Specify Oracle_SID for deleting RMAN log.
Should set '$Env:ORACLE_SID' by default.

RMAN Log���폜����Ώۂ�OracleSID���w�肵�܂��B


.PARAMETER OracleService
This parameter is planed to obsolute.

RMAN Log���폜����Ώۂ�OracleSID���w�肵�܂��B
���̃p�����[�^�͔p�~�\��ł��B


.PARAMETER OracleHomeBinPath
Specify Oracle 'BIN' path in the child path Oracle home. 
Should set "$Env:ORACLE_HOME +'\BIN'" by default.

Oracle Home�z����BIN�t�H���_�܂ł̃p�X���w�肵�܂��B
�ʏ�͕W���ݒ�ł���$Env:ORACLE_HOME +'\BIN'�iPowershell�ł̕\�L�j�ŗǂ��̂ł����AOS�Ŋ��ϐ�%ORACLE_HOME%�����ݒ���ł͓��Y��ݒ肵�Ă��������B


.PARAMETER ExecRMANPath
Specify path of DeleteArchiveLog.rman
Can specify relative or absolute path format.

���s����RMAN�t�@�C���̃p�X���w�肵�܂��B
���΃p�X�A��΃p�X�ł̎w�肪�\�ł��B


.PARAMETER OracleRmanLogPath
Specify path of RMAN log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.


RMAN���s���̃��O�o�͐�t�@�C���p�X���w�肵�܂��B
���O�o�͐�t�@�C�������݂��Ȃ��ꍇ�͐V�K�쐬���܂��B
���΃p�X�A��΃p�X�ł̎w�肪�\�ł��B


.PARAMETER Days
Specify days to delete.

�폜�Ώۂɂ���RMAN�̌o�ߓ������w�肵�܂��B


.PARAMETER PasswordAuthorization
Specify authentification with password authorization.
Should use OS authentification.

�p�X���[�h�F�؂��w�肵�܂��B
OS�F�؂��g���Ȃ����Ɏg�p���鎖�𐄏����܂��B

.PARAMETER ExecUser
Specify Oracle User to connect. 
Should use OS authentification.

�p�X���[�h�F�؎��̃��[�U��ݒ肵�܂��B
OS�F�؂��g���Ȃ����Ɏg�p���鎖�𐄏����܂��B

.PARAMETER ExecUserPassword
Specify Oracle user Password to connect. 
Should use OS authentification.

�p�X���[�h�F�؎��̃��[�U�p�X���[�h��ݒ肵�܂��B
OS�F�؂��g���Ȃ����Ɏg�p���鎖�𐄏����܂��B




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

[int]
[parameter(Position = 0, mandatory)][ValidateRange(1,65535)]$Days = 1 ,

[String]
[parameter(Position = 1)][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

[String]
[parameter(Position = 2)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$OracleRMANLogPath = '.\SC_Logs\RMAN.log' ,

[String]
[parameter(Position = 3)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$ExecRMANPath = '.\SQL\DeleteArchiveLog.rman' ,

[String]
[parameter(Position = 4)][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,


[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',

[Switch]$PasswordAuthorization ,


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

Try {

    #CommonFunctions.ps1�̔z�u���ύX�����ꍇ�́A������ύX�B����t�H���_�ɔz�u�O��
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception] {
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

#OracleBIN�t�H���_�̎w��A���݊m�F

    $OracleHomeBinPath = $OracleHomeBinPath | ConvertTo-AbsolutePath -Name  '-OracleHomeBinPath'

    $OracleHomeBinPath | Test-Container -Name '-OracleHomeBinPath' -IfNoExistFinalize > $NULL

#OracleRmanLog�t�@�C���̎w��A���݁A�������݌����m�F

    $OracleRMANLogPath = $OracleRMANLogPath | ConvertTo-AbsolutePath -Name '-OracleRmanLogPath'

    $OracleRMANLogPath | Test-LogPath -Name '-OracleRMANLLogPath' > $NULL


#���s����RMAN�t�@�C���̑��݊m�F
   
    $ExecRmanPath = $ExecRmanPath  | ConvertTo-AbsolutePath -Name '-ExecRmanPath'

    $ExecRmanPath | Test-Leaf -Name '-ExecRmanPath' -IfNoExistFinalize > $NULL


#�Ώۂ�Oracle���T�[�r�X�N�����Ă��邩�m�F

    $targetWindowsOracleService = "OracleService"+$OracleSID

    IF (-not($targetWindowsOracleService | Test-ServiceStatus -Status Running)) {

        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "Windows Service [$($targetWindowsOracleService)] is not running or dose not exist."
        Finalize $ErrorReturnCode
        } else {
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Windows Service [$($targetWindowsOracleService)] is running."
        }
     



#�����J�n���b�Z�[�W�o��


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to delete Oracle archive logs older than $($Days)days."

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

Pop-Location

 Invoke-PostFinalize $ReturnCode
}

#####################   ��������{��  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.9"


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

    Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization) {

        $rmanLog = RMAN.exe target $ExecUser/$ExecUserPassword@$OracleSID CMDFILE "$ExecRMANPath" $Days
        Write-Output $rmanLog | Out-File -FilePath $OracleRMANLogPath -Append  -Encoding $LogFileEncode
 
        } else {
        $rmanLog = RMAN.exe target / CMDFILE "$ExecRMANPath" $Days
        Write-Output $rmanLog | Out-File -FilePath $OracleRMANLogPath -Append  -Encoding $LogFileEncode
        }


    IF ($LASTEXITCODE -ne 0) {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to delete Oracle archive logs older than $($Days)days."

        Finalize $ErrorReturnCode
        }


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Successfully completed to delete Oracle archive logs older than $($Days)days."
Write-Log -EventID $InfoEventID -EventType Information -EventMessage "!!REMIND they were deleted in Oracle RMAN records and you need to delete log files in the file system with OS's delete command!!"
 

Finalize $NormalReturnCode
