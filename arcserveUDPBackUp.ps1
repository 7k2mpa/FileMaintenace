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

[String][parameter(mandatory=$true)]$Plan ,
[String]$Server,
[Switch]$AllServers,
[String][ValidateSet("Full", "Incr")]$BackUpJobType = 'Incr',

[String]$BackupFlagFilePath = '.\SC_Logs\BackUp.flg' ,


[String][ValidateSet("http", "https")]$PROTOCOL = 'http' ,
[int]$UDPConsolePort = 8015 ,

[String]$UDPCLIPath = 'D:\arcserve\Management\PowerCLI\UDPPowerCLI.ps1',

[String]$ExecUser = 'arcserve',
[String]$ExecUserDomain = 'PNX',
[String]$ExecUserPassword = 'hogehoge',
[String]$ExecUserPasswordFilePath = '.\UDP.psw' ,
[String]$FixedPasswordFilePath = '.\UDP_arcserve.psw' ,

[String][ValidateSet("JobExecUserAndPasswordFile","FixedPasswordFile" , "PlanText")]$AuthorizationType = 'JobExecUserAndPasswordFile' ,

[String]$UDPConsoleServerName = 'localhost' ,


[Switch]$NoAction,

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

#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�


#�p�����[�^�̊m�F

#UDPConsole�̑��݂��m�F

    IF(Test-Connection -ComputerName $UDPConsoleServerName -Quiet){
    
    Logging -EventID $SuccessEventID -EventType Success -EventMessage "UDP�R���\�[���T�[�o[$($UDPConsoleServerName)]���������܂����B"
    }else{
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "UDP�R���\�[���T�[�o[$($UDPConsoleServerName)]���������܂���B -UDPConsoleServerName���������ݒ肳��Ă��邩�m�F���ĉ������B"
    Exit $ErrorReturnCode
    }


#Password File�̗L�����m�F

IF($AuthorizationType -match '^FixedPasswordFile$' ){

    $FixedPasswordFilePath  = ConvertToAbsolutePath -CheckPath $FixedPasswordFilePath -ObjectName '-FixedPasswordFilePath'

    CheckLeaf -CheckPath $FixedPasswordFilePath -ObjectName '-FixedPasswordFilePath' -IfNoExistFinalize > $NULL
    }

IF($AuthorizationType -match '^JobExecUserAndPasswordFile$' ){

    $ExecUserPasswordFilePath  = ConvertToAbsolutePath -CheckPath $ExecUserPasswordFilePath -ObjectName '-ExecUserPasswordFilePath'
    
    CheckContainer -CheckPath (Split-Path -Parent -Path $ExecUserPasswordFilePath) -ObjectName '-ExecUserPasswordFilePath�̐e�t�H���_' > $NULL

    }

    $BackupFlagFilePath  = ConvertToAbsolutePath -CheckPath $BackupFlagFilePath -ObjectName '-ackupFlagFilePath'
    
    CheckContainer -CheckPath (Split-Path -Parent -Path $BackupFlagFilePath) -ObjectName '-BackupFlagFilePath�̐e�t�H���_' > $NULL


#arcserveUDP CLI�̗L�����m�F
    

    $UDPCLIPath = ConvertToAbsolutePath -CheckPath $UDPCLIPath -ObjectName 'arcserveUDP CLI -UDPCLIPath'

    CheckLeaf -CheckPath $UDPCLIPath -ObjectName 'arcserveUDP CLI -UDPCLIPath' -IfNoExistFinalize > $NULL



#�����J�n���b�Z�[�W�o��


Logging -EventID $InfoEventID -EventType Information -EventMessage "�p�����[�^�͐���ł�"

Logging -EventID $InfoEventID -EventType Information -EventMessage "arcserve UDP�o�b�N�A�b�v�@����[$($BackUpJobType)]���J�n���܂�"

}

function GetUserAndDomain{

$UserInfo = @()

$UserInfo = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -split '\\'


$Script:DoDomain = $UserInfo[0]
$Script:DoUser = $UserInfo[1]

}



function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

    TryAction -ActionType Delete -ActionFrom  $BackupFlagFilePath -ActionError "BackUp Flag [$($BackupFlagFilePath)]"

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

${THIS_FILE}=$MyInvocation.MyCommand.Path       �@�@                    #�t���p�X
${THIS_PATH}=Split-Path -Parent ($MyInvocation.MyCommand.Path)          #���̃t�@�C���̃p�X
${SHELLNAME}=[System.IO.Path]::GetFileNameWithoutExtension($THIS_FILE)  # �V�F����


${Version} = '20200124_1530'

#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

. GetUserAndDomain


       $Command = "$UDPCLIPath -UDPConsoleServerName $UDPConsoleServerName -Command Backup -BackupJobType $BackUpJobType -UDPConsoleProtocol $PROTOCOL -UDPConsolePort $UDPConsolePort -AgentBasedJob False"


IF($AllServers){

       Logging -EventID $InfoEventID -EventType Information -EventMessage "�o�b�N�A�b�v�̓v����[$($Plan)]�Ɋ܂܂��S�T�[�o���Ώۂł��B"
       $Command +=  " -PlanName $Plan "
       $Server = 'All'
       }
       else{
      Logging -EventID $InfoEventID -EventType Information -EventMessage "�o�b�N�A�b�v�̓v����[$($Plan)]�Ɋ܂܂��T�[�o[$($Server)]���Ώۂł��B"    

      $Command += " -NodeName $Server "

       }



Switch -Regex ($AuthorizationType){

    '^JobExecUser$'
        {
        #���̂Ƃ���A���̔F�ؕ�����arcserve UDP�ł͏o���Ȃ��B���s���[�U�������������Ă��Ă�(�p�X���[�h�t�@�C��|�p�X���[�h)��^����K�v������
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�F�ؕ��@��[$($AuthorizationType)]�ł��B�W���u���s�����[�U���ƔF�؏��ŔF�؂��܂��B"
        }
    '^JobExecUserAndPasswordFile$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�F�ؕ��@��[$($AuthorizationType)]�ł��B�W���u���s�����[�U���A�\�ߗp�ӂ������s���[�U�����܂ރp�X���[�h�t�@�C���ŔF�؂��܂��B"
        $ExecUserPasswordFileName = Split-Path -Path $ExecUserPasswordFilePath -Leaf 
        $ExtensionString = [System.IO.Path]::GetExtension($ExecUserPasswordFileName)
        $FileNameWithOutExtentionString = [System.IO.Path]::GetFileNameWithoutExtension($ExecUserPasswordFileName)
        $ExecUserPasswordFileName = $FileNameWithOutExtentionString + "_"+$DoUser+$ExtensionString
        
        $ExecUserPasswordFilePath = Join-Path (Split-Path -Path $ExecUserPasswordFilePath -Parent ) $ExecUserPasswordFileName

        CheckLeaf -CheckPath $ExecUserPasswordFilePath -ObjectName '-ExecUserPasswordFilePath' -IfNoExistFinalize > $NULL

        $Command += " -UDPConsoleUserName `'$DoUser`' -UDPConsoleDomainName `'$DoDomain`' -UDPConsolePasswordFile `'$ExecUserPasswordFilePath`' "
        }

    '^FixedPasswordFile$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�F�ؕ��@��[$($AuthorizationType)]�ł��B�w�肵�����[�U���A�\�ߗp�ӂ����p�X���[�h�t�@�C���ŔF�؂��܂��B"
        $Command += "-UDPConsoleDomainName `'$ExecUserDomain`' -UDPConsoleUserName `'$ExecUser`' -UDPConsolePasswordFile `'$FixedPasswordFilePath`' "
        }
    '^PlainText$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�F�ؕ��@��[$($AuthorizationType)]�ł��B�w�肵�����[�U���A�w�肵�������p�X���[�h�ŔF�؂��܂��B�B"
        $Command += "-UDPConsoleDomainName `'$ExecUserDomain`' -UDPConsoleUserName `'$ExecUser`' -UDPConsolePassword `'$ExecUserPassword`' "
        }
    Default
        {
        Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "�����G���[�B-AuthorizationType�̎w�肪����������܂���"
        Finalize $ErrorReturnCode
        }
}

        $BackupFlagFileName = Split-Path -Path $BackupFlagFilePath -Leaf 
        $ExtensionString = [System.IO.Path]::GetExtension($BackupFlagFileName)
        $FileNameWithOutExtentionString = [System.IO.Path]::GetFileNameWithoutExtension($BackupFlagFileName)
        $BackupFlagFileName = $FileNameWithOutExtentionString + "_"+$Plan+"_"+$Server+$ExtensionString
        
        $BackupFlagFilePath = Join-Path (Split-Path -Path $BackupFlagFilePath -Parent ) $BackupFlagFileName



IF(CheckLeaf -CheckPath $BackupFlagFilePath -ObjectName '�o�b�N�A�b�v���s���t���O'){

            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Back Up���s���ł��B�d�����s�͏o���܂���"
            Finalize $ErrorReturnCode
            }

CheckLogPath -CheckPath $BackupFlagFilePath -ObjectName '�o�b�N�A�b�v���s���t���O�i�[�t�H���_'



        Logging -EventID $InfoEventID -EventType Information -EventMessage "arcserveUDP CLI [$($UDPCLIPath)]���N�����܂�"

        Try{


         $Return = Invoke-Expression $Command 2>$ErrorMessage -ErrorAction Stop
        
        }
        catch [Exception]{

            Logging -EventID $ErrorEventID -EventType Error -EventMessage "arcserveUDP CLI [$($UDPCLIPath)]�̋N���Ɏ��s���܂����B"
            $ErrorDetail = $Error[0] | Out-String
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "�N�����G���[���b�Z�[�W : $ErrorDetail"
            Finalize $ErrorReturnCode
        }


        IF ($Return -ne 0){
                   
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "[$($Plan)]�Ɋ܂܂��T�[�o[$($Server)]�̃o�b�N�A�b�v����[$($BackUpJobType)]�Ɏ��s���܂����B"
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Error Message [$($ErrorMessage)]"

        Finalize $ErrorReturnCode         
        }

Logging -EventID $SuccessEventID -EventType Success -EventMessage "[$($Plan)]�Ɋ܂܂��T�[�o[$($Server)]�̃o�b�N�A�b�v����[$($BackUpJobType)]�̊J�n�ɐ������܂����B"

Finalize $NormalReturnCode