#Requires -Version 3.0


<#
.SYNOPSIS

This script export Oracle data with Data Pump.
CommonFunctions.ps1 is required.

<Common Parameters> is not supported.

Oracle Database����Datapump���g�p����export�����s���܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
This script export Oracle data with Data Pump.

Oracle Database����Datapump���g�p����export�����s���܂��B


Sample path setting

.\OracleExport.ps1
.\CommonFunctions.ps1




.EXAMPLE

.\OracleExport.ps1 -Schema MCFRAME -DumpDirectoryObject MCFDATA_PUMP_DIR 
Export data of Schema MCFRAME with Oracle Data Pump.
Specify export destination path with Oracle Directory Object named MCDATA_PUMP_DIR 


Oracle Datapump��p���āA�X�L�[�}��MCFRAME�̃f�[�^��export���܂��B
�o�͐�f�B���N�g����Oracle Directory Object��MCDATA_PUMP_DIR�Ɏw�肵�����̂Ƃ��܂��B



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


.PARAMETER SQLLogPath
Specify path of SQL log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.

���s����SQL���Q�̃��O�o�͐���w�肵�܂��B
�w��͕K�{�ł��B

.PARAMETER Schema
Specify shcema to export.

Datapump�o�͑Ώۂ̃X�L�[�}���w�肵�܂��B


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



.PARAMETER DumpDirectoryObject
Specify Oracle Directory Object for exporting.

Datapump���o�͂���Oracle�ɐݒ肵��Directory Object���w�肵�܂��B


.PARAMETER Log2EventLog
�@Windows Event Log�ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE��Event Log�o�͂��܂��B

.PARAMETER NoLog2EventLog
�@Event Log�o�͂�}�~���܂��B-Log2EventLog $FALSE�Ɠ����ł��B
Log2EventLog���D�悵�܂��B

.PARAMETER ProviderName
�@Windows Event Log�o�͂̃v���o�C�_�����w�肵�܂��B�f�t�H���g��[Infra]�ł��B

.PARAMETER EventLogLogName
�@Windows Event Log�o�͂̃��O�������Ă��܂��B�f�t�H���g��[Application]�ł��B

.PARAMETER Log2Console 
�@�R���\�[���ւ̃��O�o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE�ŃR���\�[���o�͂��܂��B

.PARAMETER NoLog2Console
�@�R���\�[�����O�o�͂�}�~���܂��B-Log2Console $FALSE�Ɠ����ł��B
Log2Console���D�悵�܂��B

.PARAMETER Log2File
�@���O�t�B���ւ̏o�͂𐧌䂵�܂��B�f�t�H���g��$FALSE�Ń��O�t�@�C���o�͂��܂���B

.PARAMETER NoLog2File
�@���O�t�@�C���o�͂�}�~���܂��B-Log2File $FALSE�Ɠ����ł��B
Log2File���D�悵�܂��B

.PARAMETER LogPath
�@���O�t�@�C���o�̓p�X���w�肵�܂��B�f�t�H���g��$NULL�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
�t�@�C�������݂��Ȃ��ꍇ�͐V�K�쐬���܂��B
�t�@�C���������̏ꍇ�͒ǋL���܂��B

.PARAMETER LogDateFormat
�@���O�t�@�C���o�͂Ɋ܂܂������\���t�H�[�}�b�g���w�肵�܂��B�f�t�H���g��[yyyy-MM-dd-HH:mm:ss]�`���ł��B

.PARAMETER NormalReturnCode
�@����I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��0�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER WarningReturnCode
�@�x���I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��1�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER ErrorReturnCode
�@�ُ�I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��8�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER InternalErrorReturnCode
�@�v���O���������ُ�I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��16�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER InfoEventID
�@Event Log�o�͂�Information�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��1�ł��B

.PARAMETER WarningEventID
�@Event Log�o�͂�Warning�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��10�ł��B

.PARAMETER SuccessErrorEventID
�@Event Log�o�͂�Success�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��73�ł��B

.PARAMETER InternalErrorEventID
�@Event Log�o�͂�Internal Error�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��99�ł��B

.PARAMETER ErrorEventID
�@Event Log�o�͂�Error�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��100�ł��B

.PARAMETER ErrorAsWarning
�@�ُ�I�����Ă��x���I����ReturnCode��Ԃ��܂��B

.PARAMETER WarningAsNormal
�@�x���I�����Ă�����I����ReturnCode��Ԃ��܂��B

.PARAMETER ExecutableUser
�@���̃v���O���������s�\�ȃ��[�U�𐳋K�\���Ŏw�肵�܂��B
�f�t�H���g��[.*]�őS�Ẵ��[�U�����s�\�ł��B�@
�L�q�̓V���O���N�I�[�e�[�V�����Ŋ����ĉ������B
���K�\���̂��߁A�h���C���̃o�b�N�X���b�V����[domain\\.*]�̗l�Ƀo�b�N�X���b�V���ŃG�X�P�[�v���ĉ������B�@

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

[String]$ExecUser = 'foo',
[String]$ExecUserPassword = 'hogehoge',

[String][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

#[parameter(mandatory=$TRUE)][String]$Schema  ,
[String]$Schema = 'MCFRAME' ,

[String]$HostName = $Env:COMPUTERNAME,

[String]$DumpDirectoryObject='MCFDATA_PUMP_DIR' ,

[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[Switch]$PasswordAuthorization ,

[String][ValidatePattern('^(?!.*(\\|\/|:|\?|`"|<|>|\|)).*$')]$TimeStampFormat = '_yyyyMMdd_HHmmss',

[String]$DumpFile = $HostName+"_"+$Schema+"_PUMP.dmp",
[String]$LogFile  = $HostName+"_"+$Schema+"_PUMP.log",

[Switch]$AddtimeStamp,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console =$TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $FALSE,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[C-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\|)).*$')]$LogPath ,
[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss",
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default�w���Shift-Jis

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

Try {

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

#�w��t�H���_�̗L�����m�F

    $OracleHomeBinPath = $OracleHomeBinPath | ConvertTo-AbsolutePath -Name  '-OracleHomeBinPath'

    $OracleHomeBinPath | Test-Container -Name '-OracleHomeBinPath' -IfNoExistFinalize > $NULL
    

#�Ώۂ�Oracle���T�[�r�X�N�����Ă��邩�m�F

    $targetWindowsOracleService = "OracleService"+$OracleSID

    IF (-not($targetWindowsOracleService | Test-ServiceStatus -Status Running)) {

        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "Windows Service [$($targetWindowsOracleService)] is not running or dose not exist."
        Finalize $ErrorReturnCode
        }else{
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Windows Service [$($targetWindowsOracleService)] is running."
        }
     

     

#�����J�n���b�Z�[�W�o��


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

#####################   ��������{��  ######################

$Version = "2.0.0-RC.2"

$DatumPath = $PSScriptRoot


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

    IF ($AddTimeStamp) {

        $DumpFile = $DumpFile | ConvertTo-FileNameAddTimeStamp -TimeStampFormat $TimeStampFormat
        $LogFile  = $LogFile  | ConvertTo-FileNameAddTimeStamp -TimeStampFormat $TimeStampFormat 
        }


    IF ($PasswordAuthorization) {

        $execCommand = $ExecUser+"/"+$ExecUserPassword+"@"+$OracleSID+" Directory="+$DumpDirectoryObject+" Schemas="+$Schema+" DumpFile="+$DumpFile+" LogFile="+$LogFile+" Reuse_DumpFiles=y"
    
        } else {

        $execCommand = "`' /@"+$OracleSID+" as sysdba `' Directory="+$DumpDirectoryObject+" Schemas="+$Schema+" DumpFile="+$DumpFile+" LogFile="+$LogFile+" Reuse_DumpFiles=y "
        }


Push-Location $OracleHomeBinPath

$process = Start-Process .\EXPDP.exe -ArgumentList $execCommand -Wait -NoNewWindow -PassThru 

IF ($process.ExitCode -ne 0) {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to export DB with Oracle data pump command."
        Finalize $ErrorReturnCode

        } else {
        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to export DB with Oracle data pump command."
        Finalize $NormalReturnCode
        }
