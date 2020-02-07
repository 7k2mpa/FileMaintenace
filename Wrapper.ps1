#Requires -Version 3.0

<#
.SYNOPSIS
�w�肵���v���O������ݒ�t�@�C���ɏ����ꂽ�p�����[�^��ǂݍ���ŁA�����Ăяo���v���O�����ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B
�Z�b�g�ŊJ�����Ă���FileMaintenance.ps1�ƕ��p����ƕ����̃��O�������ꊇ���s�ł��܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
�ݒ�t�@�C������1�s�Âp�����[�^��ǂݍ��݁A�w�肵���v���O�����ɏ������s�����܂��B

�ݒ�t�@�C���͔C�ӂɐݒ�\�ł��B
�ݒ�t�@�C���̍s����#�Ƃ���Ɠ��Y�s�̓R�����g�Ƃ��ď�������܂��B
�ݒ�t�@�C���̋󔒍s�̓X�L�b�v���܂��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B



�ݒ�t�@�C����ł��B�Ⴆ�Έȉ���DailyMaintenance.txt�ɕۑ�����-CommandFile .\DailyMaintenance.txt�Ǝw�肵�ĉ������B

---
#14���o�߂���.log�ŏI���t�@�C�����폜
-TargetFolder D:\IIS\LOG -RegularExpression '^.*\.log$' -Action Delete -Days 14

#7���o�߂����A�N�Z�X���O��Old_Log�֑ޔ�
-TargetFolder D:\AccessLog -MoveToFolder .\Old_Log -Days 7
---



.EXAMPLE

Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Command.txt
�@���̃v���O�����Ɠ���t�H���_�ɑ��݂���FileMaintenance.ps1���N�����܂��B
�N������ۂɓn���p�����[�^�͐ݒ�t�@�C��Comman.txt��1�s�Âǂݍ��݁A�������s���܂��B


.EXAMPLE

Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Command.txt -Continue
�@���̃v���O�����Ɠ���t�H���_�ɑ��݂���FileMaintenance.ps1���N�����܂��B
�N������ۂɓn���p�����[�^�͐ݒ�t�@�C��Comman.txt��1�s�Âǂݍ��݁A�������s���܂��B
�����AFileMaintenance.ps1�����s�������ʂ��ُ�I���ƂȂ����ꍇ�́AWrapper.ps1���ُ�I���������ACommand.txt�̎��s��ǂݍ��݌p�����������܂��B



.PARAMETER CommandPath
�@�N������v���O�����p�X���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER CommandFile
�@�N������v���O�����ɓn���R�}���h�t�@�C�����w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER CommandFileEncode
�@�R�}���h�t�@�C���̕����R�[�h���w�肵�܂��B
�f�t�H���g��[Default]��Shif-Jis�ł��B


.PARAMETER Continue
�@�N�������v���O�������ُ�I�����Ă��A�R�}���h�t�@�C���̎��s���p���������܂��B
�f�t�H���g�ł͂��̂܂܈ُ�I�����܂��B



.PARAMETER Log2EventLog
�@Windows Event Log�ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE��Event Log�o�͂��܂��B

.PARAMETER NoLog2EventLog
�@Event Log�o�͂�}�~���܂��B-Log2EventLog $False�Ɠ����ł��B

.PARAMETER ProviderName
�@Windows Event Log�o�͂̃v���o�C�_�����w�肵�܂��B�f�t�H���g��[Infra]�ł��B

.PARAMETER EventLogLogName
�@Windows Event Log�o�͂̃��O�������Ă��܂��B�f�t�H���g��[Application]�ł��B

.PARAMETER Log2Console 
�@�R���\�[���ւ̃��O�o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE�ŃR���\�[���o�͂��܂��B

.PARAMETER NoLog2Console
�@�R���\�[�����O�o�͂�}�~���܂��B-Log2Console $False�Ɠ����ł��B

.PARAMETER Log2File
�@���O�t�B���ւ̏o�͂𐧌䂵�܂��B�f�t�H���g��$False�Ń��O�t�@�C���o�͂��܂���B

.PARAMETER NoLog2File
�@���O�t�@�C���o�͂�}�~���܂��B-Log2File $False�Ɠ����ł��B

.PARAMETER LogPath
�@���O�t�@�C���o�̓p�X���w�肵�܂��B�f�t�H���g��$NULL�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���΃p�X�\�L�́A.����n�߂�\�L�ɂ��ĉ������B�i�� .\Log\Log.txt , ..\Script\log\log.txt�j
���C���h�J�[�h* ? []�͎g�p�ł��܂���B
�t�H���_�A�t�@�C�����Ɋ��� [ , ] ���܂ޏꍇ�̓G�X�P�[�v�����ɂ��̂܂ܓ��͂��Ă��������B
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


#>

Param(

[parameter(position=0, mandatory=$true , HelpMessage = '�N���Ώۂ�powershell�v���O�������w��(ex. .\FileMaintenance.ps1) �S�Ă�Help��Get-Help Wrapper.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*\.ps1$')]$CommandPath ,
[parameter(position=1, mandatory=$true , HelpMessage = 'powershell�v���O�����Ɏw�肷��R�}���h�t�@�C�����w��(ex. .\Command.txt) �S�Ă�Help��Get-Help Wrapper.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommandFile,


[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default', #Default�w���Shift-Jis

[Switch]$Continue,
[Switch]$Script:NoAction,

[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath ,
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath = ..\Log\FileMaintenance.log ,
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
$THIS_PATH = $PSScriptRoot


#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�


#�p�����[�^�̊m�F


#�R�}���h�̗L�����m�F


    $CommandPath = ConvertToAbsolutePath -CheckPath $CommandPath -ObjectName '���s�R�}���h -CommandPath'

    CheckLeaf -CheckPath $CommandPath -ObjectName '���s�R�}���h -CommandPath' -IfNoExistFinalize > $NULL

#�R�}���h�t�@�C���̗L�����m�F
    

    $CommandFile = ConvertToAbsolutePath -CheckPath $CommandFile -ObjectName '�R�}���h�t�@�C�� -CommandFile'

    CheckLeaf -CheckPath $CommandFile -ObjectName '�R�}���h�t�@�C�� -CommandFile' -IfNoExistFinalize > $NULL


#�����J�n���b�Z�[�W�o��


Logging -EventID $InfoEventID -EventType Information -EventMessage "�p�����[�^�͐���ł�"

Logging -EventID $InfoEventID -EventType Information -EventMessage "���s�R�}���h��[$($CommandPath)]�ł�"

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

    IF(-NOT(($NormalCount -eq 0) -and ($WarningCount -eq 0) -and ($ErrorCount -eq 0))){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "���s���ʂ͐���I��[$($NormalCount)]�A�x���I��[$($WarningCount)]�A�ُ�I��[$($ErrorCount)]�ł�"

        If(($Continue) -and ($ErrorCount -gt 0)){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-Continue[${Continue}]���w�肳��Ă��邽�ߏ����ُ�ňُ�I���������̒�`���������܂���"
            }


    }


EndingProcess $ReturnCode

}



#####################   ��������{��  ######################

[int][ValidateRange(0,2147483647)]$NormalCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$ErrorCount = 0

$Version = '20200207_1615'

#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

    Try{

        $Lines = Get-Content $CommandFile -Encoding $CommandFileEncode

        }
                    catch [Exception]
                    {
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "-CommandFile�ǂݍ��݂Ɏ��s���܂����B"
                    $ErrorDetail = $Error[0] | Out-String
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "�N�����G���[���b�Z�[�W : $ErrorDetail"
                    Finalize $ErrorReturnCode
                    }


For ( $i = 0 ; $i -lt $Lines.Count; $i++ )

{

    $Line = $Lines[$i]

    Logging -EventID $InfoEventID -EventType Information -EventMessage "[$($CommandFile)]��$($i+1)�s�ڂ����s���܂��B"



    Switch -Regex ($Line){

        #����1 �s��#�ŃR�����g
        '^#.*$'
                {Logging -EventID $InfoEventID -EventType Information -EventMessage "�R�����g[$($Line)]"}

        #����2 ��
        '^$'
                {Logging -EventID $InfoEventID -EventType Information -EventMessage "�󔒍s"}

        #����3 �R�}���h���s
        default 
                {
                   Try{
        
                    Logging -EventID $InfoEventID -EventType Information -EventMessage "���s�R�}���h��[$($CommandPath)]�A������[$($Line)]�ł�"
                    Invoke-Expression "$CommandPath $Line" -ErrorAction Stop

                    }
                    catch [Exception]
                    {
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "[$($CommandPath)]�̋N���Ɏ��s���܂����B"
                    $ErrorDetail = $Error[0] | Out-String
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "�N�����G���[���b�Z�[�W : $ErrorDetail"
                    Finalize $ErrorReturnCode
                    }

                    Logging -EventID $InfoEventID -EventType Information -EventMessage "[$($CommandFile)]��$($i+1)�s�ڂ̎��s���ʂ�[$($LastExitCode)]�ł�"
                    

                    #�I���R�[�h�ŕ���
                    Switch ($LastExitCode){

                        #����1 �ُ�I��
                        {$_ -ge $ErrorReturnCode}{
 
                            $ErrorCount ++
                            Logging -EventID $WarningEventID -EventType Warning -EventMessage "[$($CommandFile)]��$($i+1)�s�ڂُ͈�I�����܂���"
       

                            IF($Continue){
                                Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]�̂��ߏ������p�����܂��B"   
                                ;Break     
     
                                }else{
                                Finalize $ErrorReturnCode
                                }
                        }
                    
                        #����2 �x���I��
                        {$_ -ge $WarningReturnCode}{
                            
                            $WarningCount ++
                            Logging -EventID $WarningEventID -EventType Warning -EventMessage "[$($CommandFile)]��$($i+1)�s�ڂ͌x���I�����܂����B�p�����܂�" 
                            ;Break        
                        }
                        
                        #����3 ����I��
                        Default {
                        $NormalCount ++
                        Logging -EventID $SuccessEventID -EventType Success -EventMessage "[$($CommandFile)]��$($i+1)�s�ڂ͐���I�����܂���"
                        }
                   }
    
   
                # ����3 �R�}���h���s default�I�[ 
                }

    #Switch -Regex ($Line)�I�[
    }

#�ΏیQ�̏������[�v�I�[
}


#�I�����b�Z�[�W�o�́B�����ł�NormalReturnCode�ŌĂяo�����AFinalize�ŃG���[�J�E���g�����ď������Ă����

Finalize $NormalReturnCode