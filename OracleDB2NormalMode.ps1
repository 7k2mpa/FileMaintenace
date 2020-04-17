#Requires -Version 3.0

<#
.SYNOPSIS
This script siwtch to Normal mode(Ending Backup Mode) Oracle Database after finishing backup software.
CommonFunctions.ps1 is required.

<Common Parameters> is not supported.


Oracle Database���o�b�N�A�b�v��ɒʏ탂�[�h�֐ؑւ���X�N���v�g�ł��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
This script siwtch to Normal mode(Ending Backup Mode) Oracle Database after finishing backup software.
The script loads SQLs.ps1, place SQLs.ps1 previously.
OracleDB2BackUpMode.ps1 is offered also, you may use it with this script.
If Windows Oracle service or Listener service is stopped, start them automatically.

Oracle Database���o�b�N�A�b�v����ɂ́A�\�߃f�[�^�x�[�X�̒�~�A�܂��̓o�b�N�A�b�v���[�h�֐ؑւ��K�v�ł��B
�]���̓f�[�^�x�[�X�̒�~(Shutdown Immediate)�Ŏ�������Ⴊ�唼�ł����A��~�̓Z�b�V���������݂���ƒ�~���Ȃ����ŏ�Q�ƂȂ�������܂��B
���̂��ߖ{�X�N���v�g��Oracle Database���~����̂ł͂Ȃ��A�\�̈���o�b�N�A�b�v���[�h�֐ؑւ��ăo�b�N�A�b�v���J�n����^�p��O��Ƃ��č쐬���Ă��܂��B

�Z�b�g�Ŏg�p����SQLs.PS1��ǂݍ��݁A���s���܂��B�\�ߔz�u���Ă��������B
�΂ɂȂ�o�b�N�A�b�v���[�h����ʏ탂�[�h�֐ؑւ���X�N���v�g��p�ӂ��Ă���܂��̂ŁA�Z�b�g�ŉ^�p���Ă��������B


Sample Path setting

.\OracleDB2NormalMode.ps1
.\OracleDB2BackUpMode.ps1
.\StartService.ps1
.\CommonFunctions.ps1
..\SQL\SQLs.PS1
..\Log\SQL.LOG
..\Lock\BkUp.flg



.EXAMPLE

.\OracleDB2NormalMode

Switch all tables of Oracle SID specified at Windows enviroment variable to Normal Mode.
Authentification to connecting to Oracle is used OS authentification with OS user running the script.
If Windows Oracle service or Listener service, start them automatically.

Windows���ϐ�Oracle_SID�ɐݒ肳�ꂽ�S�Ă̕\�̈��ʏ탂�[�h�֐ؑւ��܂��B
Oracle Database�̔F�؂�OS�F�؂�p���܂��B���̃X�N���v�g�����s�����OS���[�U�ŔF�؂��܂��B
Oracle�T�[�r�X�AListener����~���Ă����ꍇ�͋N�����܂��B


.\OracleDBNormalMode -OracleSID MCDB -ExecUser FOO -ExecUserPassword BAR -PasswordAuthorization

Switch all tables of Oracle SID MCDB to Normal Mode.
Authentification to connecting to Oracle is used password authentification.
Oracle user is used 'FOO', Oracle user password is used 'BAR'
If Windows Oracle service or Listener service, start them automatically.


Oracle SID MCDB��Oracle Database�̑S�Ă̕\�̈��ʏ탂�[�h�֐ؑւ��܂��B
OracleDatabase�̔F�؂̓p�X���[�h�F�؂�p���Ă��܂��B���[�UID FOO�A�p�X���[�h BAR�Ń��O�C���F�؂��܂��B



.PARAMETER OracleSID
Specify Oracle_SID.
Should set '$Env:ORACLE_SID' by default.

�Ώۂ�OracleSID���w�肵�܂��B


.PARAMETER OracleService
This parameter is planed to obsolute.

RMAN Log���폜����Ώۂ�OracleSID���w�肵�܂��B
���̃p�����[�^�͔p�~�\��ł��B


.PARAMETER OracleHomeBinPath
Specify Oracle 'BIN' path in the child path Oracle home. 
Should set "$Env:ORACLE_HOME +'\BIN'" by default.

Oracle Home�z����BIN�t�H���_�܂ł̃p�X���w�肵�܂��B
�ʏ�͕W���ݒ�ł���$Env:ORACLE_HOME +'\BIN'�iPowershell�ł̕\�L�j�ŗǂ��̂ł����AOS�Ŋ��ϐ�%ORACLE_HOME%�����ݒ���ł͓��Y��ݒ肵�Ă��������B

.PARAMETER StartServicePath
Specify path of StartService.ps1
Specification is required.
Can specify relative or absolute path format.

StartService.ps1�̃p�X���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B

.PARAMETER SQLLogPath
Specify path of SQL log file.
If the file dose not exist, create a new file.
Can specify relative or absolute path format.
                                                                                        
.PARAMETER SQLCommandsPath
Specify path of SQLs.ps1
Specification is required.
Can specify relative or absolute path format.

�\�ߗp�ӂ����A���s����SQL���Q���L�q����ps1�t�@�C���̃p�X���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B


.PARAMETER ControlFileDotCtlPATH
Specify to export controle file path ending with .ctl
Specification is required.
Can specify relative or absolute path format.

.CTL�`���̃R���g���[���t�@�C�����o�͂���p�X���w�肵�܂��B

.PARAMETER ControlFileDotBkPATH
Specify to export controle file path ending with .bk
Specification is required.
Can specify relative or absolute path format.

.BK�`���̃R���g���[���t�@�C�����o�͂���p�X���w�肵�܂��B

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



[String][Alias("OracleService")]$OracleSID = $Env:ORACLE_SID ,

[String]$SQLLogPath = '.\SC_Logs\SQL.log',

[String]$SQLCommandsPath = '.\SQL\SQLs.ps1',

[String]$ExecUser = 'hogehoge',
[String]$ExecUserPassword = 'hogehoge',
[Switch]$PasswordAuthorization ,

[String]$OracleHomeBinPath = $Env:ORACLE_HOME +'\BIN' ,

[String]$StartServicePath = '.\ChangeServiceStatus.ps1' ,

[int][ValidateRange(1,65535)]$RetrySpanSec = 20,
[int][ValidateRange(1,65535)]$RetryTimes = 15,

[String]$TimeStampFormat = "_yyyyMMdd_HHmmss",

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default�w���Shift-Jis

[String]$controlfiledotctlPATH = '.\SC_Logs\file_bk.ctl' ,
[String]$controlfiledotbkPATH  = '.\SC_Logs\controlfile.bk',

[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $FALSE,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath ,
[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss",

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
    Catch [Exception] {
    Write-Output "Fail to load CommonFunctions.ps1 Please verfy existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }

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


#SQLLog�t�@�C���̎w��A���݁A�������݌����m�F

    $SQLLogPath = $SQLLogPath | ConvertTo-AbsolutePath -ObjectName '-SQLLogPath'

    $SQLLogPath | Test-LogPath -Name '-SQLLogPath' > $NULL


#SQL�R�}���h�Q�̎w��A���݊m�F�ALoad

    $SQLCommandsPath = $SQLCommandsPath | ConvertTo-AbsolutePath -ObjectName '-SQLCommandPath'

    $SQLCommandsPath | Test-Leaf -Name '-SQLCommandsPath' -IfNoExistFinalize > $NULL


    Try {
        . $SQLCommandsPath
        }

        Catch [Exception] {
        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage  "Fail to load SQLs in -SQLCommandsPath"
        Finalize $ErrorReturnCode
        }

    Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to load SQLs Version $($SQLsVersion) in -SQLCommandsPath"


#Oracle�T�[�r�X�N���p��StartService.ps1�̑��݊m�F

    $StartServicePath = $StartServicePath | ConvertTo-AbsolutePath -Name '-StartServicePath'

    $StartServicePath | Test-Leaf -Name '-StartServicePath' -IfNoExistFinalize > $NULL



#Oracle�T�[�r�X���݊m�F

    $targetWindowsOracleService = "OracleService"+$OracleSID

    IF (-not(Test-ServiceExist -ServiceName $targetWindowsOracleService)) {

        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "Windows Service [$($targetWindowsOracleService)] dose not exist."
        Finalize $ErrorReturnCode
        }

#ControlFile�o�͐�path�̑��݊m�F


    $controlfiledotctlPATH = $controlfiledotctlPATH | ConvertTo-AbsolutePath -Name '-controlfiledotctlPATH '

    $ControlfiledotctlPATH | Split-Path -Parent | Test-Container -Name 'Parent Folder of -controlfiledotctlPATH' -IfNoExistFinalize > $NULL

    $controlfiledotbkPATH = $controlfiledotbkPATH | ConvertTo-AbsolutePath -Name '-controlfiledotbkPATH '

    $ControlfiledotbkPATH | Split-Path  -Parent | Test-Container -Name 'Parent Folder of -controlfiledotbkPATH' -IfNoExistFinalize > $NULL



#�����J�n���b�Z�[�W�o��

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "To start to switch Oracle Database to Normal Mode. (to end BackUp Mode)"

}

function Finalize {

Param(
[parameter(mandatory=$TRUE)][int]$ReturnCode
)

Pop-Location

 Invoke-PostFinalize $ReturnCode


}

#####################   ��������{��  ######################

[boolean]$ErrorFlag = $FALSE
[boolean]$WarningFlag = $FALSE

[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0


[Boolean]$NeedToStartListener = $TRUE
[String]$ListenerStatus = $NULL

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.1"


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize



Push-Location $OracleHomeBinPath


#���X�i�[�N����Ԃ��m�F�A�K�v�ɉ����ċN��

$returnMessage = LSNRCTL.exe status  2>&1

[String]$listenerStatus = $returnMessage

Write-Output $returnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode

    Switch -Regex ($ListenerStatus) { 

        '�C���X�^���X������܂�' {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Listener is running."
            $needToStartListener = $FALSE
            }

        '���X�i�[������܂���' {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Listener is stopped."
            $needToStartListener = $TRUE
            }   

        Default {
            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Listener status is unknown."
            $needToStartListener = $TRUE
            }     
     }


    IF ($needToStartListener) {
    
        $returnMessage = LSNRCTL.exe START

        Write-Output $returnMessage | Out-File -FilePath $SQLLogPath -Append -Encoding $LogFileEncode
    
 
        IF ($LASTEXITCODE -eq 0) {
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfulley complete to start Listener."
            
            } else {
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to start Listener."
            Finalize $ErrorReturnCode
            }

    }


#Windows�T�[�r�X�N����Ԃ��m�F�A�K�v�ɉ����ċN��    


    IF (Test-ServiceStatus -ServiceName $targetWindowsOracleService -Health Running -Span 0 -UpTo 1) {
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Windows Service [$($targetWindowsOracleService)] is already running."
        
        } else {
        $serviceCommand = "$StartServicePath -Service $targetWindowsOracleService -Status Running -RetrySpanSec $RetrySpanSec -RetryTimes $RetryTimes"
        
        Try {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start Windows Serive [$($targetWindowsOracleService)] with [$($StartServicePath)]"
            Invoke-Expression $serviceCommand        
            }

        catch [Exception] {
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to start script [$($StartServicePath)]"
            $errorDetail = $ERROR[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
            }            
            
        IF ($LASTEXITCODE -ne 0) {
                Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to start Windows service [$($targetWindowsOracleService)]"
                Finalize $ErrorReturnCode
                }
        }


#DB�C���X�^���X��Ԋm�F

    $invokeResult = Invoke-SQL -SQLCommand $DBStatus -SQLName 'DB Status Check' -SQLLogPath $SQLLogPath

    IF (($invokeResult.Status) -OR ($invokeResult.log -match 'ORA-01034')) {

            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to check Oracle Database Status."
                
            } else {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Failed to check Oracle Database Status."
            }


        IF ($invokeResult.log -match 'OPEN') {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Oracle instance SID [$($OracleSID)] is already OPEN."
         
  
        }elseIF ($invokeResult.log -match '(STARTED|MOUNTED)') {
            
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Oracle instance SID [$($OracleSID)] is MOUNT or NOMOUNT. Shutdown and start up manually."
            Finalize $ErrorReturnCode

        } else {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Oracle instance SID [$($OracleSID)] is not OPEN."        
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Switch Oracle instance SID [$($OracleSID)] to OPEN."

            $invokeResult = Invoke-SQL -SQLCommand $DBStart -SQLName 'Oracle DB Instance OPEN' -SQLLogPath $SQLLogPath

                IF ($invokeResult.Status) {

                    Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to switch Oracle instance to OPEN."
                
                    } else {
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Failed to switch Oracle instance to OPEN."
                    $ErrorCount ++
                    }
            }




#BackUp/Normal Mode�ǂ��炩���m�F

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Check Back Up Mode"

    $status = Test-OracleBackUpMode

      IF ($LASTEXITCODE -ne 0) {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to Check Back Up Mode."

        Finalize $ErrorReturnCode
        } else { 
        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to Check Back Up Mode."
        }


 IF (-not($status.BackUp) -and ($status.Normal)) {
 
    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Oracle Database is running in Normal Mode(ending backup mode)"
    }

 IF (-not( ($status.BackUp) -xor ($status.Normal) )) {

    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Oracle Database is running in UNKNOWN mode."
    $ErrorCount ++
 
    } elseIF (($status.BackUp) -and (-not($status.Normal))) {
 
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Oracle Database is running in Backup Mode. Switch to Normal Mode(Ending Backup Mode)"

        $invokeResult = Invoke-SQL -SQLCommand $DBBackUpModeOff -SQLName "Switch to Normal Mode" -SQLLogPath $SQLLogPath

        IF ($invokeResult.Status) {

            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to switch to Normal Mode(Ending Backup Mode)"

            } else {        
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to switch to Normal Mode(Ending Backup Mode)"
            $ErrorCount ++
            }
 }


#�R���g���[���t�@�C�������o��

#SQL.ps1�̒u���ϐ��\���ɂȂ��Ă���Ώە�����u��

    $DBExportControlFile = $DBExportControlFile.Replace('&controlfiledotctlPATH' , $controlfiledotctlPATH)
    $DBExportControlFile = $DBExportControlFile.Replace('&controlfiledotbkPATH'  , $controlfiledotbkPATH)

    $invokeResult = Invoke-SQL -SQLCommand $DBExportControlFile -SQLName 'DBExportControlFile'  -SQLLogPath $SQLLogPath

    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to export Oracle Control Files."

        } else {         
        Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Failed to export Oracle Control Files"
        $WarningCount ++
        }


#Redo Log ���������o��

    $invokeResult = Invoke-SQL -SQLCommand $ExportRedoLog  -SQLName 'ExportRedoLog'  -SQLLogPath $SQLLogPath 

    IF ($invokeResult.Status) {

        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to export Redo Log."
        
        } else {
        Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Failed to export Redo Log."
        $WarningCount ++
        }


Finalize $NormalReturnCode
