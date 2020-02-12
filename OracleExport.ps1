#Requires -Version 3.0


<#
.SYNOPSIS
Oracle Database���o�b�N�A�b�v�O�Ƀo�b�N�A�b�v���[�h�֐ؑւ���X�N���v�g�ł��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
Oracle Database���o�b�N�A�b�v����ɂ́A�\�߃f�[�^�x�[�X�̒�~�A�܂��̓o�b�N�A�b�v���[�h�֐ؑւ��K�v�ł��B
�]���̓f�[�^�x�[�X�̒�~(Shutdown Immediate)�Ŏ�������Ⴊ�唼�ł����A��~�̓Z�b�V���������݂���ƒ�~���Ȃ����ŏ�Q�ƂȂ�������܂��B
���̂��ߖ{�X�N���v�g��Oracle Database���~����̂ł͂Ȃ��A�\�̈���o�b�N�A�b�v���[�h�֐ؑւ��ăo�b�N�A�b�v���J�n����^�p��O��Ƃ��č쐬���Ă��܂��B

�Z�b�g�Ŏg�p����SQLs.PS1��ǂݍ��݁A���s���܂��B�\�ߔz�u���Ă��������B
�΂ɂȂ�o�b�N�A�b�v���[�h����ʏ탂�[�h�֐ؑւ���X�N���v�g��p�ӂ��Ă���܂��̂ŁA�Z�b�g�ŉ^�p���Ă��������B


�z�u��

.\OracleDB2NormalMode.ps1
.\OracleDB2BackUpMode.ps1
.\StartService.ps1
.\CommonFunctions.ps1
..\SQL\SQLs.PS1
..\Log\SQL.LOG
..\Lock\BkUp.flg



.EXAMPLE

.\OracleDB2BackUpMode -OracleSerivce MCDB -BackUpFlagPath ..\Flag\BackUp.FLG

Windows�T�[�r�X��OracleServiceMCDB�A�C���X�^���X��MCDB��Oracle Database�̑S�Ă̕\�̈���o�b�N�A�b�v���[�h�֐ؑւ��܂��B
Oracle Database�̔F�؂�OS�F�؂�p���܂��B���̃X�N���v�g�����s�����OS���[�U�ŔF�؂��܂��B
�o�b�N�A�b�v���t���O..\Flag\BackUp.FLG�̑��݂��m�F���A���݂����ꍇ�̓o�b�N�A�b�v���Ɣ��肵�Ĉُ�I�����܂��B
�ؑ֌��Listener���~���܂��B

.\OracleDB2BackUpMode -OracleSerivce MCDB -BackUpFlagPath ..\Flag\BackUp.FLG -NoStopListener -ExecUser BackUpUser -ExecUserPassword FOOBAR -PasswordAuthorization

Windows�T�[�r�X��OracleServiceMCDB�A�C���X�^���X��MCDB��Oracle Database�̑S�Ă̕\�̈���o�b�N�A�b�v���[�h�֐ؑւ��܂��B
OracleDatabase�̔F�؂̓p�X���[�h�F�؂�p���Ă��܂��B���[�UID BackUpUpser�A�p�X���[�h FOOBAR�Ń��O�C���F�؂��܂��B
�o�b�N�A�b�v���t���O..\Flag\BackUp.FLG�̑��݂��m�F���A���݂����ꍇ�̓o�b�N�A�b�v���Ɣ��肵�Ĉُ�I�����܂��B
�ؑ֌��Listener�͒�~���܂���B



.PARAMETER OracleService
���䂷��ORACLE�̃T�[�r�X���i�ʏ��OracleService��SID��t���������́j���w�肵�܂��B
�ʏ�͊��ϐ�ORACLE_SID�ŗǂ��ł����A���ݒ�̊��ł͌ʂɎw�肪�K�v�ł��B

.PARAMETER OracleHomeBinPath
Oracle�̊e��BIN���i�[����Ă���t�H���_�p�X���w�肵�܂��B
�ʏ�͊��ϐ�ORACLE_HOME\BIN�ŗǂ��ł����A���ݒ�̊��ł͌ʂɎw�肪�K�v�ł��B
.PARAMETER SQLLogPath
���s����SQL���Q�̃��O�o�͐���w�肵�܂��B
�w��͕K�{�ł��B


.PARAMETER SQLCommandsPath
�\�ߗp�ӂ����A���s����SQL���Q���L�q����ps1�t�@�C���̃p�X���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B

.PARAMETER BackUpFlagPath
�o�b�N�A�b�v���������t���O�t�@�C���̃p�X���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B


.PARAMETER ExecUser
Oracle���[�U�F�؎��̃��[�U�����w�肵�܂��B
OS�F�؎g���Ȃ����Ɏg�p���鎖�𐄏����܂��B

.PARAMETER ExecUserPassword
Oracle���[�U�F�؎��̃p�X���[�h���w�肵�܂��B
OS�F�؂��g���Ȃ����Ɏg�p���鎖�𐄏����܂��B

.PARAMETER PasswordAuthorization
Oracle�փ��[�U/�p�X���[�h�F�؂Ń��O�I�����鎖���w�肵�܂��B
OS�F�؂��g���Ȃ����Ɏg�p���鎖�𐄏����܂��B


.PARAMETER NoChangeToBackUpMode
�o�b�N�A�b�v���[�h�ւ̐ؑ֕s�v���w�肵�܂��B
�o�b�N�A�b�v�\�t�g�E�G�A�ɂ���ẮA�o�b�N�A�b�v�\�t�g�E�G�A��Oracle���o�b�N�A�b�v���[�h�֐ؑւ��܂��B
���̏ꍇ�͓��X�C�b�`��On�ɂ��ĉ������B

.PARAMETER NoStopListener
���X�i�[��~�s�v���w�肵�܂��B
�Ɩ��f�ʂ��K�v�ȏꍇ�A�o�b�N�A�b�v�O�Ƀ��X�i�[���~���܂����A�Ɩ��f�ʂ��s�vor����~�Ƃ���ꍇ�͓��X�C�b�`��On�ɂ��ĉ������B




.PARAMETER Log2EventLog
�@Windows Event Log�ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE��Event Log�o�͂��܂��B

.PARAMETER NoLog2EventLog
�@Event Log�o�͂�}�~���܂��B-Log2EventLog $False�Ɠ����ł��B
Log2EventLog���D�悵�܂��B

.PARAMETER ProviderName
�@Windows Event Log�o�͂̃v���o�C�_�����w�肵�܂��B�f�t�H���g��[Infra]�ł��B

.PARAMETER EventLogLogName
�@Windows Event Log�o�͂̃��O�������Ă��܂��B�f�t�H���g��[Application]�ł��B

.PARAMETER Log2Console 
�@�R���\�[���ւ̃��O�o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE�ŃR���\�[���o�͂��܂��B

.PARAMETER NoLog2Console
�@�R���\�[�����O�o�͂�}�~���܂��B-Log2Console $False�Ɠ����ł��B
Log2Console���D�悵�܂��B

.PARAMETER Log2File
�@���O�t�B���ւ̏o�͂𐧌䂵�܂��B�f�t�H���g��$False�Ń��O�t�@�C���o�͂��܂���B

.PARAMETER NoLog2File
�@���O�t�@�C���o�͂�}�~���܂��B-Log2File $False�Ɠ����ł��B
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


#>


Param(

[String]$ExecUser = 'foo',
[String]$ExecUserPassword = 'hogehoge',
[parameter(mandatory=$true , HelpMessage = 'Oracle Service(ex. MCDB) �S�Ă�Help��Get-Help FileMaintenance.ps1')][String]$OracleService ,
#[String]$OracleService = 'MCDB',

#[parameter(mandatory=$true)][String]$Schema  ,
[String]$Schema = 'MCFRAME' ,

[String]$HostName = $Env:COMPUTERNAME,

[String]$DumpDirectoryObject='MCFDATA_PUMP_DIR' ,

#[String]$OracleHomeBinPath = 'D:\TEST' ,
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
[boolean]$Log2File = $False,
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

Try{

    #CommonFunctions.ps1�̔z�u���ύX�����ꍇ�́A������ύX�B����t�H���_�ɔz�u�O��
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "CommonFunctions.ps1 ��Load�Ɏ��s���܂����BCommonFunctions.ps1�����̃t�@�C���Ɠ���t�H���_�ɑ��݂��邩�m�F���Ă�������"
    Exit 1
    }


################ �ݒ肪�K�v�Ȃ̂͂����܂� ##################

################# ���ʕ��i�A�֐�  #######################


function Initialize {

$SHELLNAME=Split-Path $PSCommandPath -Leaf

#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�


#�p�����[�^�̊m�F

#�w��t�H���_�̗L�����m�F

   $OracleHomeBinPath = ConvertToAbsolutePath -CheckPath $OracleHomeBinPath -ObjectName  '-OracleHomeBinPath'

   CheckContainer -CheckPath $OracleHomeBinPath -ObjectName '-OracleHomeBinPath' -IfNoExistFinalize > $NULL


        

#�Ώۂ�Oracle���T�[�r�X�N�����Ă��邩�m�F

    $TargetOracleService = "OracleService"+$OracleService

    $ServiceStatus = CheckServiceStatus -ServiceName $TargetOracleService -Health Running

    IF (-NOT($ServiceStatus)){


        Logging -EventType Error -EventID $ErrorEventID -EventMessage "�Ώۂ�OracleService���N�����Ă��܂���B"
        Finalize $ErrorReturnCode
        }else{
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�Ώۂ�Oracle Service�͐���ɋN�����Ă��܂�"
        }
     

#�����J�n���b�Z�[�W�o��


Logging -EventID $InfoEventID -EventType Information -EventMessage "�p�����[�^�͐���ł�"

Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle Data Pump���J�n���܂�"

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

Pop-Location

EndingProcess $ReturnCode


}

#####################   ��������{��  ######################

$Version = '20200207_1615'

$DatumPath = $PSScriptRoot


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize



    IF($AddTimeStamp){

        $DumpFile = AddTimeStampToFileName -TimeStampFormat $TimeStampFormat -TargetFileName $DumpFile
        $LogFile = AddTimeStampToFileName -TimeStampFormat $TimeStampFormat -TargetFileName $LogFile

    }



    IF ($PasswordAuthorization){

        $ExecCommand = $ExecUser+"/"+$ExecUserPassword+"@"+$OracleService+" Directory="+$DumpDirectoryObject+" Schemas="+$Schema+" DumpFile="+$DumpFile+" LogFile="+$LogFile+" Reuse_DumpFiles=y"
    
    }else{

        $ExecCommand = "`' /@"+$OracleService+" as sysdba `' Directory="+$DumpDirectoryObject+" Schemas="+$Schema+" DumpFile="+$DumpFile+" LogFile="+$LogFile+" Reuse_DumpFiles=y "

    }

#echo $ExecCommand


#$ExecCommand = [ScriptBlock]::Create($ExecCommand)

#exit

# Invoke-NativeApplication -ScriptBlock $ExecCommand

Push-Location $OracleHomeBinPath

$Process = Start-Process .\expdp -ArgumentList $ExecCommand -Wait -NoNewWindow -PassThru 

#Invoke-NativeApplicationSafe -ScriptBlock $ExecCommand


IF ($Process.ExitCode -ne 0){


#IF ($LastExitCode -ne 0){

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Oracle Data Pump�Ɏ��s���܂���"
	    Finalize $ErrorReturnCode



        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Oracle Data Pump�ɐ������܂���"
        Finalize $NormalReturnCode
        }
                   

