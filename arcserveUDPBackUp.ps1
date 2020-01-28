#Requires -Version 3.0

<#
.SYNOPSIS
arcserveUDP ver.6�ȍ~�Ŏ������ꂽCLI�o�R�Ńo�b�N�A�b�v�W���u���N������v���O�����ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B
�Z�b�g�ŊJ�����Ă���FileMaintenance.ps1�ƕ��p����ƕ����̏������ꊇ���s�ł��܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
arcserveUDP CLI�o�R�Ńo�b�N�A�b�v�W���u���N������v���O�����ł��B
�o�b�N�A�b�v�̓t���o�b�N�A�b�v�A�����o�b�N�A�b�v��I���ł��܂��B
�F�؂̓p�X���[�h�����A�p�X���[�h�t�@�C���A�������T�|�[�g���Ă��܂��B
�p�X���[�h�t�@�C����p����ꍇ�A���s���[�U�̓p�X���[�h���쐬�������[�U�Ɠ���ɂ���K�v������܂��B�����WindowsOS�̎d�l�ł��B
�Ⴆ�ΐݒ�t�@�C����$ExecUser��'arcserve'�Ƃ��A�v���O���������s���Ă��郆�[�U���قȂ�ꍇ�̓p�X���[�h�t�@�C����'arcserve'���[�U�ō쐬���Ă��F�؂��鎖�͏o���܂���B
�W���u�X�P�W���[�����Ŏ��s���鎞�̃��[�U��'arcserve'�Ƃ��Ď��s���ĉ������B

���̃v���O�����ƃo�b�N�A�b�v�R���\�[���T�[�o�Ƃ͓���܂��͈قȂ�z�X�g�A�������T�|�[�g���Ă��܂��B
�o�b�N�A�b�v�R���\�[����CPU�R�A���̑����o�b�N�A�b�v�T�[�o�ɓ��ڂ����ꍇ�A��ʂ̃W���u�X�P�W���[�����C�Z���X���K�v�ł����A�قȂ�z�X�g�ɓ��v���O������z�u���鎖�Ń��C�Z���X��ߖ�\�ł��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B

�t�@�C���z�u��

D:\script\infra\arcserveUDPBackUp.ps1
D:\script\infra\Log\backup.flg
D:\script\infra\UDP.psw




---



.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -Server SVDB01 -BackUpJobType Incr
arcserveUDP�̃o�b�N�A�b�v�v����[SSDB]�Ɋ܂܂��A�T�[�o[SVDB01]�������o�b�N�A�b�v�N�����܂��B

.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -AllServers -BackUpJobType Full -UDPConsoleServerName BKUPSV01.corp.local
arcserveUDP�̃o�b�N�A�b�v�v����[SSDB]�Ɋ܂܂��A�S�ẴT�[�o���t���o�b�N�A�b�v�N�����܂��B
arcserveUDP�̃R���\�[���T�[�o��BKUPSV01.corp.local���w�肵�܂��B

.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -Server SVDB02 -BackUpJobType Incr -AuthorizationType PlainText -ExecUser = 'arcserve' -ExecUserDomain = 'INTRA' -ExecUserPassword = 'hogehoge'
arcserveUDP�̃o�b�N�A�b�v�v����[SSDB]�Ɋ܂܂��A�T�[�o[SVDB02]�������o�b�N�A�b�v�N�����܂��B
�F�ؕ����͕����p�X���[�h�Ƃ��܂��B
�o�b�N�A�b�v�R���\�[���T�[�o�̊Ǘ����[�U�̓h���C�����[�UINTRA\arcserve�A�p�X���[�h��hogehoge���w�肵�܂��B
�F�ؕ����𕽕��p�X���[�h�Ƃ����ꍇ�A���̃v���O���������s���Ă��郆�[�U�ƈقȂ郆�[�U���w�肷�鎖���o���܂��B


.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -AllServers -BackUpJobType Full -AuthorizationType JobExecUserAndPasswordFile -ExecUserPasswordFilePath '.\UDP.psw'
arcserveUDP�̃o�b�N�A�b�v�v����[SSDB]�Ɋ܂܂��A�S�ẴT�[�o���t���o�b�N�A�b�v�N�����܂��B
�F�ؕ����̓W���u���s���[�U�ƃp�X���[�h�t�@�C���Ƃ��܂��B�W���u���s���[�U�Ńo�b�N�A�b�v�R���\�[���T�[�o�Ƀ��O�I�����܂��B
���̎��̃p�X���[�h�͗\�߃W���u���s���[�U�̃p�X���[�h�t�@�C�����쐬���Ă����K�v������܂��B
�p�X���[�h�t�@�C���͎w�肵���t�@�C����UDP.psw�������ϊ����܂��B
���̃v���O���������s���郆�[�U��Domain\arcserve�̎��ɂ́A�t�@�C�����{�̂ɃA���_�[�X�R�A'_'�ɑ����ă��[�U��[arcserve]�������I�ɕt�������t�@�C����UDP_arcserve.psw��ǂݍ��݁A�p�X���[�h�t�@�C���Ƃ��Ďg�p���܂��B


.PARAMETER Plan
arcserveUDP�ɓo�^���Ă���v���������w�肵�܂��B
�w��͕K�{�ł��B

���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER Server
arcserveUDP�ɓo�^���Ă���v�����Ɋ܂܂��T�[�o����1�䕪�w�肵�܂��B
�v�����Ɋ܂܂�Ȃ��T�[�o�͎w��ł��܂���B
���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER AllServers
arcserveUDP�ɓo�^���Ă���v�����Ɋ܂܂��T�[�o�S�Ă��o�b�N�A�b�v�Ώۂɂ��܂��B

.PARAMETER BackUpJobType
�Ώۂ̃o�b�N�A�b�v���������Ă��܂��B

Full:�t���o�b�N�A�b�v
Incr:�����o�b�N�A�b�v




.PARAMETER BackupFlagFilePath = '.\SC_Logs\BackUp.flg' ,
�o�b�N�A�b�v���������o�b�N�A�b�v�t�@�C���̕ۑ���p�X���w�肵�܂��B
�t�@�C����.�g���q�Ŏw�肵�܂����A�t�@�C�����Ɏ����I��_Plan��_�o�b�N�A�b�v�ΏۃT�[�o����t�������t�@�C�����ŕۑ����܂��B
AllServers���w�肵���ꍇ�A�o�b�N�A�b�v�T�[�o����All�ƂȂ�܂��B


.PARAMETER PROTOCOL
arcserveUDP�R���\�[���T�[�o�Ƀ��O�I�����鎞�̃v���g�R�����w�肵�܂��B
http / https���w�肵�Ă��������B
�f�t�H���g��http�ł��B

.PARAMETER UDPConsolePort
arcserveUDP�R���\�[���T�[�o�Ƀ��O�I�����鎞�̒ʐM�|�[�g�ԍ����w�肵�܂��B
�f�t�H���g��8015�ł��B


.PARAMETER UDPCLIPath
arcserveUDP CLI���z�u���ꂽ�p�X���w�肵�܂��B
���΁A��΃p�X�Ŏw��\�ł��B


.PARAMETER AuthorizationType
arcserveUDP�R���\�[���T�[�o�Ƀ��O�I������F�ؕ������w�肵�܂��B

JobExecUserAndPasswordFile:�{�v���O���������s���Ă��郆�[�U / �{�v���O���������s���Ă��郆�[�U�����܂ރp�X���[�h�t�@�C��
FixedPasswordFile:�w�肵�����[�U / �w�肵���p�X���[�h�t�@�C��
PlanText:�w�肵�����[�U / �����p�X���[�h

.PARAMETER ExecUser
�F�ؕ�����PlainText , FixedPasswordFile�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I����OS���[�U�����w�肵�܂��B
�h���C�����[�U�̏ꍇ�A�h���C�������������������̂��w�肵�Ă��������B

��:FooDOMAIN\BarUSER�ł���΁ABarUSER


.PARAMETER ExecUserDomain
�F�ؕ�����PlainText , FixedPasswordFile�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I��OS���[�U�̃h���C�������w�肵�܂��B

��:FooDOMAIN\BarUSER�ł���΁AFooDOMAIN

.PARAMETER ExecUserPassword
�F�ؕ�����PlainText�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I��OS���[�U�̃p�X���[�h�𕽕��Ŏw�肵�܂��B


.PARAMETER FixedPasswordFilePath
�F�ؕ�����FixedPasswordFile�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I��OS���[�U�̃p�X���[�h�t�@�C�����w�肵�܂��B



.PARAMETER ExecUserPasswordFilePath
�F�ؕ�����JobExecUserAndPasswordFile�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I��OS���[�U�̃p�X���[�h�t�@�C���p�X���w�肵�܂��B

��:'.\UDP.psw' , �{�v���O���������s���Ă��郆�[�U��FooDOMAIN\BarUSER
'.UDP_BarUSER.psw'���p�X���[�h�t�@�C���Ƃ��Ďw�肳��܂��B
�A���_�[�X�R�A_�ȍ~�̕����͎��s���Ă��郆�[�U���������I�ɑ}������܂��B


.PARAMETER UDPConsoleServerName
arcserveUDP�R���\�[���T�[�o�̃z�X�g���AIP�A�h���X���w�肵�܂��B



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
[String]$Server = 'hoge-hoge',
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

[String][ValidateSet("JobExecUserAndPasswordFile","FixedPasswordFile" , "PlainText")]$AuthorizationType = 'PlainText' ,

[String]$UDPConsoleServerName = 'localhost' ,



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

IF(-NOT($AllServers)){

    CheckHostname -CheckHostName $Server -ObjectName '�o�b�N�A�b�v�Ώ� -Server' > $NULL
    }

    CheckHostname -CheckHostName $UDPConsoleServerName -ObjectName 'arcserveUDP Console Server -UDPConsoleServerName' > $NULL

#[String][ValidateSet("JobExecUserAndPasswordFile","FixedPasswordFile" , "PlanText")]$AuthorizationType = 'JobExecUserAndPasswordFile' ,


IF($AuthorizationType -match '^(FixedPasswordFile|PlainText)$' ){

    CheckDomainName -CheckDomainName $ExecUserDomain -ObjectName '���s���[�U����������h���C�� -ExecUserDomain'  > $NULL
    
    CheckUserName -CheckUserName $ExecUser -ObjectName '���s���[�U -ExecUser ' > $NULL

    }

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
    
    CheckContainer -CheckPath (Split-Path -Parent -Path $ExecUserPasswordFilePath) -ObjectName '-ExecUserPasswordFilePath�̐e�t�H���_'  -IfNoExistFinalize > $NULL

    }

    $BackupFlagFilePath  = ConvertToAbsolutePath -CheckPath $BackupFlagFilePath -ObjectName '-BackupFlagFilePath'
    
    CheckContainer -CheckPath (Split-Path -Parent -Path $BackupFlagFilePath) -ObjectName '-BackupFlagFilePath�̐e�t�H���_'  -IfNoExistFinalize > $NULL


#arcserveUDP CLI�̗L�����m�F
    

    $UDPCLIPath = ConvertToAbsolutePath -CheckPath $UDPCLIPath -ObjectName 'arcserveUDP CLI -UDPCLIPath'

    CheckLeaf -CheckPath $UDPCLIPath -ObjectName 'arcserveUDP CLI -UDPCLIPath' -IfNoExistFinalize > $NULL



#�����J�n���b�Z�[�W�o��


Logging -EventID $InfoEventID -EventType Information -EventMessage "�p�����[�^�͐���ł�"

Logging -EventID $InfoEventID -EventType Information -EventMessage "arcserve UDP�o�b�N�A�b�v�@����[$($BackUpJobType)]���J�n���܂�"

}

function GetUserAndDomain{

$UserInfo = @()

#���[�U����domain\user�̌`���ŏo�͂����̂ŁA�o�b�N�X���b�V��\����؂�L���Ƃ��āA�z��ɑ��
#-Split�͐��K�\���Ȃ̂ŃG�X�P�[�v�L���̓o�b�N�X���b�V��\�@Powershell�̃G�X�P�[�v�ł���o�b�N�N�I�[�g`�ł͂Ȃ�

$UserInfo = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -split '\\'


$Script:DoDomain = $UserInfo[0]
$Script:DoUser = $UserInfo[1]

}



function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

    IF(CheckLeaf -CheckPath $BackupFlagFilePath -ObjectName 'BackUp Flag'){
        TryAction -ActionType Delete -ActionFrom  $BackupFlagFilePath -ActionError "BackUp Flag [$($BackupFlagFilePath)]"
        }

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