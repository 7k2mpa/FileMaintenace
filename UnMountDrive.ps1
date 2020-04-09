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
�@Windows Event Log�ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE��Event Log�o�͂��܂��B

.PARAMETER NoLog2EventLog
�@Event Log�o�͂�}�~���܂��B-Log2EventLog $FALSE�Ɠ����ł��B

.PARAMETER ProviderName
�@Windows Event Log�o�͂̃v���o�C�_�����w�肵�܂��B�f�t�H���g��[Infra]�ł��B

.PARAMETER EventLogLogName
�@Windows Event Log�o�͂̃��O�������Ă��܂��B�f�t�H���g��[Application]�ł��B

.PARAMETER Log2Console 
�@�R���\�[���ւ̃��O�o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE�ŃR���\�[���o�͂��܂��B

.PARAMETER NoLog2Console
�@�R���\�[�����O�o�͂�}�~���܂��B-Log2Console $FALSE�Ɠ����ł��B

.PARAMETER Log2File
�@���O�t�B���ւ̏o�͂𐧌䂵�܂��B�f�t�H���g��$FALSE�Ń��O�t�@�C���o�͂��܂���B

.PARAMETER NoLog2File
�@���O�t�@�C���o�͂�}�~���܂��B-Log2File $FALSE�Ɠ����ł��B

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

[parameter(position = 0, mandatory, HelpMessage = 'Specify Drive Letter (ex. F:) or Get-Help UnMountDrive.ps1')]
[String][ValidatePattern('^[d-zD-Z]:$')]$MountedDrive ,

#[parameter(position=0, mandatory=$true , HelpMessage = '�h���C�u���^�[���w��(ex. F:) �S�Ă�Help��Get-Help UnMountDrive.ps1')][String][ValidatePattern('^[d-zD-Z]:$')]$MountedDrive ,
#[String][ValidatePattern('^[d-z]:$')]$MountedDrive="F:",


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $FALSE,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[C-Z]:\\).*')]$LogPath ,
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

$Version = "2.0.0-beta.10"

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
