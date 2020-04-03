#Requires -Version 3.0

<#
.SYNOPSIS
This script checkes existence(or non-existence)  of a flag file, and create(or delete) the flag file.

CommonFunctions.ps1 is required.

<Common Parameters> is not supported.

�o�b�N�A�b�v�����̃t���O�t�@�C�����m�F�A�쐬����X�N���v�g�ł��B
�t���O�t�@�C�������݂���ƌx���I��False���A���݂��Ȃ��Ɛ���I��True��Ԃ��܂��B
-CreateFlag���w�肷��ƃt���O�t�@�C���𐶐����܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION

This script checkes existence(or non-existence)  of a flag file, and create(or delete) the flag file.
If status of existence(or non-existence) is true, exit with normal return code.
If status of existence(or non-existence) is false, exit with warning return code.

If specify -PostAction option, the script create(or delete) the flag file.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


�o�b�N�A�b�v�����̃t���O�t�@�C�����m�F�A�쐬����X�N���v�g�ł��B
�t���O�t�@�C�������݂���ƌx���I��False���A���݂��Ȃ��Ɛ���I��True��Ԃ��܂��B
-CreateFlag���w�肷��ƃt���O�t�@�C���𐶐����܂��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B

Sample Path

.\CheckFlag.ps1
.\CommonFunctions.ps1
..\Lock\BackUp.Flg



.EXAMPLE
.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg

Check BackUp.Flg file in the ..\Lock folder.
If the file exists, the script exit with warning return code.
If the file dose not exist, the script exit with normal return code.

For backward compatibility, run without specification -Status option, -Status will be 'NoExist' by default.

..\Lock�t�H���_��BackUp.Flg�t�@�C���̗L�����m�F���܂��B
�t���O�t�@�C�������݂���ƌx���I��False���A���݂��Ȃ��Ɛ���I��True��Ԃ��܂��B


.EXAMPLE
.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg -Status Exist -PostAction Delete

Check BackUp.Flg file in the ..\Lock folder.
If the file dose not exists, the script exit with warning return code.
If the file exists, the script delete the flag file.

If success to delete, the script exit with normal return code.
If fail to delte, the script exit with error return code.


..\Lock�t�H���_��BackUp.Flg�t�@�C���̗L�����m�F���܂��B
�t�@�C�������݂��Ȃ��ƌx���I��False��Ԃ��܂��B
�t�@�C�������݂����BackUp.Flg�t�@�C���̍폜�����݂܂��B
�t�@�C���폜�ɐ�������Ɛ���I��True��Ԃ��܂��B���s����ƈُ�I��Flase��Ԃ��܂��B



.PARAMETER FlagFolder
Specify the folder to check existence of flag file.
Can specify relative or absolute path format.

�t���O�t�@�C�����m�F�A�z�u����t�H���_���w�肵�܂��B
���΃p�X�A��΃p�X�ł̎w�肪�\�ł��B

.PARAMETER FlagFile
Specify the name of the flag file.

�t���O�t�@�C�������w�肵�܂��B

.PARAMETER Status
Specify 'Exist' or 'NoExist' the flag file.
'NoExist' is by default.

�m�F�����Ԃ��w�肵�܂��B

.PARAMETER PostAction
Specify action to the flag file after checking.

�t�@�C���m�F��A�폜�A�������w�肵�܂��B


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

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
Param(

[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Specify the folder of a flag file placed.(ex. D:\Logs)or Get-Help CheckFlag.ps1')]
[ValidateNotNullOrEmpty()][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')][ValidateScript({ Test-Path $_  -PathType container })][Alias("Path","LiteralPath")]$FlagFolder ,

[String][parameter(position = 1, mandatory)][ValidateNotNullOrEmpty()][ValidatePattern ('^(?!.*(\/|:|\?|`"|<|>|\||\*|\\).*$)')]$FlagFile ,
[String][parameter(position = 2)][ValidateNotNullOrEmpty()][ValidateSet("Exist","NoExist")]$Status = 'NoExist' ,
[String][parameter(position = 3)][ValidateNotNullOrEmpty()][ValidateSet("Create","Delete")]$PostAction ,

#Planned to obsolute
[Switch]$CreateFlag ,
#Planned to obsolute

[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,

[boolean]$Log2File = $FALSE,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath ,
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath = ..\Log\FileMaintenance.log ,
[String]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss',
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

#For Backward compatibility

    IF ($CreateFlag) {
            $PostAction = 'Create'
            } 


#�p�����[�^�̊m�F


#�t���O�t�H���_�̗L�����m�F


    $FlagFolder = $FlagFolder | ConvertTo-AbsolutePath -ObjectName  '-FlagFolder'

    $FlagFolder | Test-Container -Name '-FlagFolder' -IfNoExistFinalize > $NULL


#�t���O�t�@�C������Validation


    IF ($FlagFile -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "The path -FlagFile contains some characters that can not be used by NTFS"
        Finalize $ErrorReturnCode
        }

#Check invalid combination -Status and -PostAction

    IF (($Status -eq 'Exist' -and $PostAction -eq 'Create') -or ($Status -eq 'NoExist' -and $PostAction -eq 'Delete')) {

        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "Must not specify -Status [$($Status)] and -PostAction [$($PostAction)] in the same time."
        Finalize $ErrorReturnCode        
        }



#�����J�n���b�Z�[�W�o��


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid"

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Starting to check existence of the flag file [$($FlagFile)]"

}


function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)

 Invoke-PostFinalize $ReturnCode

}



#####################   ��������{��  ######################

$DatumPath = $PSScriptRoot

$Version = '20200330_1000'


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

[String]$flagValue = $ShellName +" "+ (Get-Date).ToString($LogDateFormat)
[String]$flagPath = $FlagFolder | Join-Path -ChildPath $FlagFile


Switch -Regex ($Status) {


    '^NoExist$' {

        IF (-not($flagPath | Test-Leaf -Name 'Flag file') -and -not($flagPath | Test-Container -Name 'Same Name file')) {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Flag file [$($flagPath)] dose not exists and terminate as NORMAL." 

            } else {
            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Flag file [$($flagPath)] exists already and terminate as WARNING."
            Finalize $WarningReturnCode    
            }
        }


    '^Exist$' {
    
        IF ($flagPath | Test-Leaf -Name 'Flag file') {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Flag file [$($flagPath)] exists and terminate as NORMAL."    

            } else {
            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Flag file [$($flagPath)] is deleted already and terminate as WARNING."
            Finalize $WarningReturnCode
            }        
        }


    Default {
            Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error. Switch Status exception has occurred. "
            Finalize $InternalErrorReturnCode    
            }
}


Switch -Regex ($PostAction) {

    '^$' {
            Break
            }


    'Create' {
    
            Invoke-Action -ActionType MakeNewFileWithValue -ActionFrom $flagPath -ActionError $flagPath -FileValue $flagValue
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to create the flag file [$($flagPath)]"
            }


    'Delete' {
    
            Invoke-Action -ActionType Delete -ActionFrom $flagPath -ActionError $flagPath
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to delete the flag file [$($flagPath)]"
            }

    Default {

            Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error. Switch PostAction exception has occurred. "
            Finalize $InternalErrorReturnCode    
            }
}

#�I�����b�Z�[�W�o��

Finalize $NormalReturnCode