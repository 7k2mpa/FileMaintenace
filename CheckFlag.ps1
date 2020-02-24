#Requires -Version 3.0

<#
.SYNOPSIS
�o�b�N�A�b�v�����̃t���O�t�@�C�����m�F�A�쐬����X�N���v�g�ł��B
�t���O�t�@�C�������݂���ƌx���I��False���A���݂��Ȃ��Ɛ���I��True��Ԃ��܂��B
-CreateFlag���w�肷��ƃt���O�t�@�C���𐶐����܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
�o�b�N�A�b�v�����̃t���O�t�@�C�����m�F�A�쐬����X�N���v�g�ł��B
�t���O�t�@�C�������݂���ƌx���I��False���A���݂��Ȃ��Ɛ���I��True��Ԃ��܂��B
-CreateFlag���w�肷��ƃt���O�t�@�C���𐶐����܂��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B

�t���O�t�@�C���̍폜�͓����ɊJ�����Ă���FileMaintenance.ps1�������p���������B


�z�u��


.\CheckFlag.ps1
.\CommonFunctions.ps1
..\Lock\BackUp.Flg



.EXAMPLE
.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg

..\Lock�t�H���_��BackUp.Flg�t�@�C���̗L�����m�F���܂��B
�t���O�t�@�C�������݂���ƌx���I��False���A���݂��Ȃ��Ɛ���I��True��Ԃ��܂��B


.EXAMPLE
.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg -CreateFlag

..\Lock�t�H���_��BackUp.Flg�t�@�C���̗L�����m�F���܂��B
�t�@�C�������݂���ƌx���I��False��Ԃ��܂��B
�t�@�C�������݂��Ȃ���BackUp.Flg�t�@�C���̐��������݂܂��B�t�@�C�������ɐ�������Ɛ���I��True��Ԃ��܂��B�����Ɏ��s����ƈُ�I��Flase��Ԃ��܂��B



.PARAMETER FlagFolder

�t���O�t�@�C�����m�F�A�z�u����t�H���_���w�肵�܂��B
���΃p�X�A��΃p�X�ł̎w�肪�\�ł��B

.PARAMETER FlagFile

�t���O�t�@�C�������w�肵�܂��B

.PARAMETER CreateFlag

�t���O�t�@�C�������݂��Ȃ��ꍇ�A�t���O�t�@�C���𐶐����܂��B
�t���O�t�@�C���̒��g�̓V�F����+�����ƂȂ�܂��B



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

.LINK

https://github.com/7k2mpa/FileMaintenace

#>


Param(

[String][parameter(position=0)][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$FlagFolder = '.\',
#[parameter(mandatory=$true , HelpMessage = '�����Ώۂ̃t�H���_���w��(ex. D:\Logs) �S�Ă�Help��Get-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$FlagFolder,


[String][parameter(position=1)][ValidatePattern ('^(?!.*(\/|:|\?|`"|<|>|\||\*|\\).*$)')]$FlagFile ,

[Switch]$CreateFlag ,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,

[boolean]$Log2File = $False,
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


#�t���O�t�H���_�̗L�����m�F


    $FlagFolder = ConvertToAbsolutePath -CheckPath $FlagFolder -ObjectName  'Flag�t�H���_-FlagFolder'

    CheckContainer -CheckPath $FlagFolder -ObjectName 'FLag�t�H���_-FlagFolder' -IfNoExistFinalize > $NULL


#�t���O�t�@�C������Validation


    IF ($FlagFile -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-FlagFile��NTFS�Ŏg�p�ł��Ȃ��������w�肵�Ă��܂�"
				Finalize $ErrorReturnCode
                }



#�����J�n���b�Z�[�W�o��


Logging -EventID $InfoEventID -EventType Information -EventMessage "�p�����[�^�͐���ł�"

Logging -EventID $InfoEventID -EventType Information -EventMessage "�t���O�t�@�C��[$($FlagFile)]�̗L���m�F���J�n���܂�"

}


function Finalize{

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)



EndingProcess $ReturnCode

}






#####################   ��������{��  ######################

[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0

$DatumPath = $PSScriptRoot

$Version = '20200207_1615'


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

[String]$FlagValue = ${SHELLNAME} + (Get-Date).ToString($LogDateFormat)
[String]$FlagPath = Join-Path -Path $FlagFolder -ChildPath $FlagFile

    IF(CheckLeaf -CheckPath $FlagPath -ObjectName '�t���O�t�@�C��'){

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "�t���O�t�@�C��[$($FlagPath)]�����݂��邽�ߌx���I�������ɂ��܂�"
        Finalize $WarningReturnCode
    
        }else{
       

        Logging -EventID $InfoEventID -EventType Information -EventMessage "�t���O�t�@�C��[$($FlagPath)]�����݂��Ȃ����ߐ���I�������ɂ��܂�"
                
            IF($CreateFlag){
    
                TryAction -ActionType MakeNewFileWithValue -ActionFrom $FlagPath -ActionError $FlagPath -FileValue $FlagValue
                Logging -EventID $SuccessEventID -EventType Success -EventMessage "�t���O�t�@�C��[$($FlagPath)]�̐����ɐ������܂���"
    
                }
        }



#�I�����b�Z�[�W�o��

Finalize $NormalReturnCode

