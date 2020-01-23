#Requires -Version 3.0

<#
.SYNOPSIS
���O�t�@�C�����k�A�폜���n�߂Ƃ����F�X�ȏ��������閜�\�c�[���ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B
�Z�b�g�ŊJ�����Ă���Wrapper.ps1�ƕ��p����ƕ����������ꊇ���s�ł��܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
�Ώۂ̃t�H���_�Ɋ܂܂��A�t�@�C���A�t�H���_���e������Ńt�B���^���đI�����܂��B
�t�B���^���ʂ��p�����[�^�Ɋ�Â��A�O�����A�又���A�㏈�����܂��B

�t�B���^���ʂɑ΂��ĉ\�ȏ����͈ȉ��ł��B

-�O����:�Ώۃt�@�C������ʃt�@�C���𐶐����܂��B�\�ȏ����́u�t�@�C�����Ƀ^�C���X�^���v�t���v�u���k�v�u���������ʃt�@�C���̈ړ��v�ł��B���p�w��\�ł��B�u���������ʃt�@�C���̈ړ��v���w�肵�Ȃ��ƑΏۃt�@�C���Ɠ���t�H���_�ɔz�u���܂��B
-�又��:�Ώۃt�@�C�����u�ړ��v�u�����v�u�폜�v�u���e�����i�k���N���A�j�v�A�t�H���_���u��t�H���_�폜�v���܂��B
-�㏈��:�Ώۃt�@�C�����u���e�����i�k���N���A�j�v���܂��B

�t�B���^�́u�o�ߓ����v�u�e�ʁv�u���K�\���v�u�Ώۃt�@�C���A�t�H���_�̐e�p�X�Ɋ܂܂�镶���̐��K�\���v�Ŏw��ł��܂��B

���̃v���O�����P�̂ł́A1�x�ɏ����ł���̂�1�t�H���_�ł��B�����t�H���_�������������ꍇ�́AWrapper.ps1�𕹗p���Ă��������B


���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B

���̃v���O������PowerShell 3.0�ȍ~���K�v�ł��B
Windows Server 2008,2008R2��WMF(Windows Management Framework)3.0�ȍ~��ǉ��C���X�g�[�����Ă��������B����ȑO��OS�ł͉ғ����܂���B

https://docs.microsoft.com/ja-jp/powershell/scripting/install/installing-windows-powershell?view=powershell-7#upgrading-existing-windows-powershell


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -noLog2Console
C:\TEST�ȉ��̃t�@�C�����ċA�I�Ɍ����������܂��i�q�t�H���_���Ώہj
��Ƃׂ̍������e���R���\�[���ɕ\�����܂���B
�悸�̓����e�i���X�Ώۂ̂��̂��\������邩�m�F���Ă݂ĉ������B


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete
C:\TEST�ȉ��̃t�@�C�����ċA�I�ɍ폜���܂��i�q�t�H���_���Ώہj

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action DeleteEmptyFolders
C:\TEST�ȉ��̋�t�H���_���ċA�I�ɍ폜���܂��i�q�t�H���_���Ώہj

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete -noRecurse
C:\TEST�ȉ��̃t�@�C�����ċA�I�ɍ폜���܂��i�q�t�H���_�͑ΏۊO�j

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Copy -MoveToFolder C:\TEST1 -KBsize 10 -continue
C:\TEST�ȉ��̃t�@�C����10KB�ȏ�̂��̂��ċA�I��C:\TEST1�֕������܂��B�ړ���Ɏq�t�H���_��������΍쐬���܂�
�ړ���ɓ��ꖼ�̂̃t�@�C�����������ꍇ�̓X�L�b�v���ď������p�����܂�

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -Compress -Action none -AddTimeStamp -NullOriginalFile
C:\TEST�ȉ��̃t�@�C�����ċA�I�� �u.log�ŏI���v���̂փt�@�C�����ɓ��t��t�����Ĉ��k���܂��B
���t�@�C���͎c��܂����A���e�����i�k���N���A�j���܂��B

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -Compress $True -Action Delete -MoveNewFile $True -MoveToFolder C:\TEST1 -OverRide -Days 10

C:\TEST�ȉ��̃t�@�C�����ċA�I�� �u.log�ŏI���v����10���ȑO�̂��̂����k��C:\TEST1�ֈړ����܂��B
�ړ���ɓ��ꖼ�̂̂��̂��������ꍇ�͏㏑�����܂��B
���̃t�@�C���͍폜���܂�


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\OLD\Log -RegularExpression '^.*\.log$' -Action Delete -ParentRegularExpression '\\OLD\\'

C:\OLD\Log�ȉ��̃t�@�C���ōċA�I�Ɂu.log�ŏI���v���̂��폜���܂��B
�A���A�t�@�C���̃t���p�X����C:\OLD\Log���폜�����p�X�Ɂu\OLD\�v���܂܂��t�@�C���������ΏۂɂȂ�܂��B���K�\���̂��߁A�p�X�Ɋ܂܂��\�i�o�b�N�X���b�V���j��\�i�o�b�N�X���b�V���j�ŃG�X�P�[�v����Ă��܂��B
�Ⴆ�Έȉ��̃t�@�C���z�u�ł�C:\OLD\Log�܂ł̓}�b�`�ΏۊO�ƂȂ�C:\OLD\Log\IIS\Current\Infra.log , C:\OLD\Log\Java\Current\Infra.log , C:\OLD\Log\Infra.log�͍폜����܂���B

C:\OLD\Log\IIS\Current\Infra.log
C:\OLD\Log\IIS\OLD\Infra.log
C:\OLD\Log\Java\Current\Infra.log
C:\OLD\Log\Java\OLD\Infra.log
C:\OLD\Log\Infra.log

 
.PARAMETER TargetFolder
�����Ώۂ̃t�@�C���A�t�H���_���i�[����Ă���t�H���_���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���΃p�X�\�L�́A.����n�߂�\�L�ɂ��ĉ������B�i�� .\Log , ..\Script\log�j
���C���h�J�[�h* ? []�͎g�p�ł��܂���B
�t�H���_���Ɋ��� [ , ] ���܂ޏꍇ�̓G�X�P�[�v�����ɂ��̂܂ܓ��͂��Ă��������B

.PARAMETER Action
�@�����Ώۂ̃t�@�C���ɑ΂��鑀���ݒ肵�܂��B�ȉ��̃p�����[�^���w�肵�ĉ������B

None:������������܂���B���̐ݒ肪�f�t�H���g�ł��B����͌둀��h�~�̂��߂ɂ���܂��B���쌟�؂ɂ�-NoAction�X�C�b�`�𗘗p���ĉ������B
Move:�t�@�C����-MoveToFolder�ֈړ����܂��B
Delete:�t�@�C�����폜���܂��B
Copy:�t�@�C����-MoveToFolder�ɃR�s�[���܂��B
DeleteEmptyFolders:��t�H���_���폜���܂��B
NullClear:�t�@�C���̓��e�폜 NullClear���܂��B

.PARAMETER MoveToFolder
�@�����Ώۂ̃t�@�C���̈ړ��A�R�s�[��t�H���_���w�肵�܂��B
���΁A��΃p�X�Ŏw��\�ł��B
���΃p�X�\�L�́A.����n�߂�\�L�ɂ��ĉ������B�i�� .\Log , ..\Script\log�j
���C���h�J�[�h* ? []�͎g�p�ł��܂���B
�t�H���_���Ɋ��� [ , ] ���܂ޏꍇ�̓G�X�P�[�v�����ɂ��̂܂ܓ��͂��Ă��������B

.PARAMETER Days
�@�����Ώۂ̃t�@�C���A�t�H���_���X�V�o�ߓ����Ńt�B���^���܂��B
�f�t�H���g��0���őS�Ẵt�@�C�����ΏۂƂȂ�܂��B

.PARAMETER KBSize
�@�����Ώۂ̃t�@�C����KB�T�C�Y�Ńt�B���^���܂��B
�f�t�H���g��0KB�őS�Ẵt�@�C�����ΏۂƂȂ�܂��B

.PARAMETER RegularExpression
�@�����Ώۂ̃t�@�C���A�t�H���_�𐳋K�\���Ńt�B���^���܂��B
�f�t�H���g�� .* �őS�Ă��ΏۂƂȂ�܂��B
�L�q�̓V���O���N�I�[�e�[�V�����Ŋ����ĉ������B
PowerShell�̎d�l��A�啶���������̋�ʂ͂��Ȃ����ł����A���ۂɂ͋�ʂ����̂Œ��ӂ��ĉ������B

.PARAMETER ParentRegularExpression
�@�����Ώۂ̃t�@�C���A�t�H���_�̏�ʃp�X����-TargetFolder�̃p�X�܂ł𐳋K�\���Ńt�B���^���܂��B-TargetFolder�Ɋ܂܂��p�X�̓t�B���^�ΏۊO�ł��B
�f�t�H���g�� .* �őS�Ă��ΏۂƂȂ�܂��B
�L�q�̓V���O���N�I�[�e�[�V�����Ŋ����ĉ������B
PowerShell�̎d�l��A�啶���������̋�ʂ͂��Ȃ����ł����A���ۂɂ͋�ʂ����̂Œ��ӂ��ĉ������B



.PARAMETER Recurse
�@-TargetFolder�̒����̍ċA�I�܂��͔�ċA�ɏ����̎w�肪�\�ł��B
�f�t�H���g��$TRUE�ōċA�I�����ł��B

.PARAMETER NoRecurse
�@-TargetFolder�̒����݂̂������ΏۂƂ��܂��B-Recurse $False�Ɠ����ł��B
Recurse�p�����[�^���D�悵�܂��B

.PARAMETER OverRide
�@�ړ��A�R�s�[��Ɋ��ɓ����̃t�@�C�������݂��Ă������I�ɏ㏑�����܂��B
�f�t�H���g�ł͏㏑�������Ɉُ�I�����܂��B

.PARAMETER Continue
�@�ړ��A�R�s�[��Ɋ��ɓ����̃t�@�C�������݂����ꍇ���Y�t�@�C���̏������X�L�b�v���܂��B
�X�L�b�v����ƌx���I�����܂��B
�f�t�H���g�ł̓X�L�b�v�����Ɉُ�I�����܂��B

.PARAMETER NoAction
�t�@�C���A�t�H���_�����ۂɍ폜���̑���������Ɏ��s���܂��B
����m�F�œ��Y�X�C�b�`���w�肵�Ă��������B
-Action None��-Compress����Pre Action�APost Action�͎��s����܂����A���̃X�C�b�`�͑S�Ẵt�@�C����������s���Ȃ��Ȃ�܂��B
���O��͌x�����o�͂���܂����A���s���ʂł͂��̌x���͖�������܂��B

.PARAMETER NoneTargetAsWarning
����Ώۂ̃t�@�C���A�t�H���_�����݂��Ȃ��ꍇ�Ɍx���I�����܂��B
���̃X�C�b�`��ݒ肵�Ȃ��Ƒ��݂��Ȃ��ꍇ�͒ʏ�I�����܂��B


.PARAMETER Compress
�@�Ώۃt�@�C�������k���ĕʃt�@�C���Ƃ��ĕۑ����܂��B
-Action -AddTimeStamp -ClearNullOriginal�Ɠ����Ɏw��\�ł��B

.PARAMETER CompressedExtString
�@-Compress�w�莞�̃t�@�C���g���q���w��ł��܂��B
�f�t�H���g��[.zip]�ł��B

.PARAMETER AddTimeStamp
�@�Ώۃt�@�C�����ɓ�����t�����ĕʃt�@�C���Ƃ��ĕۑ����܂��B
-Action -Compres -ClearNullOriginal�ƕ��p�\�ł��B

.PARAMETER TimeStampFormat
�@-AddTimeStamp�w�莞�̏������w��ł��܂��B
�f�t�H���g��[_yyyyMMdd_HHmmss]�ł��B

.PARAMETER MoveNewFile
�@-Compress -AddTimeStamp���w�肵���ۂɐ��������ʃt�@�C����-MoveToFolder�̎w���ɕۑ����܂��B
�f�t�H���g�͑Ώۃt�@�C���Ɠ���f�B���N�g���֕ۑ����܂��B

.PARAMETER NullOriginalFile
�@�Ώۃt�@�C���̓��e�����i�k���N���A�j���܂��B
-Action NullClear�Ɠ����ł��B


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

[parameter(position=0, mandatory=$true , HelpMessage = '�����Ώۂ̃t�H���_���w��(ex. D:\Logs) �S�Ă�Help��Get-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$TargetFolder,
#[parameter(position=0, mandatory=$true , HelpMessage = '�����Ώۂ̃t�H���_���w��(ex. D:\Logs) �S�Ă�Help��Get-Help FileMaintenance.ps1')][String]$TargetFolder,  #debug�p�ɗp�ӂ��Ă���܂��B�ʏ�͎g��Ȃ�
#[parameter(position=0, mandatory=$true , HelpMessage = '�����Ώۂ̃t�H���_���w��(ex. D:\Logs) �S�Ă�Help��Get-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$TargetFolder ,

[String][parameter(position=1)][ValidateSet("Move", "Copy", "Delete" , "none" , "DeleteEmptyFolders" , "NullClear")]$Action='none',

[String][parameter(position=2)][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$MoveToFolder,

[int][ValidateRange(0,2147483647)]$Days = 0,
[int][ValidateRange(0,2147483647)]$KBsize = 0,
[Regex]$RegularExpression ='.*',
[Regex]$ParentRegularExpression ='.*',


[boolean]$Recurse = $TRUE,
[Switch]$NoRecurse,

[Switch]$OverRide,
[Switch]$Continue,
[Switch]$NoAction,
[Switch]$NoneTargetAsWarning,


[Switch]$Compress,
[String]$CompressedExtString = '.zip',
[Switch]$AddTimeStamp,
[String][ValidatePattern('^(?!.*(\\|\/|:|\?|`"|<|>|\|)).*$')]$TimeStampFormat = '_yyyyMMdd_HHmmss',
[Switch]$MoveNewFile,

[Switch]$NullOriginalFile,



[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,

[boolean]$Log2File = $false,
[Switch]$NoLog2File,
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath = '.\SC_Logs\Infra.log',
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath = ..\Log\FileMaintenance.log ,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath  ,
[String]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss',
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default�w���Shift-Jis

[int][ValidateRange(0,2147483647)]$NormalReturnCode = 0,
[int][ValidateRange(0,2147483647)]$WarningReturnCode = 1,
[int][ValidateRange(0,2147483647)]$ErrorReturnCode = 8,
[int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16,

[int][ValidateRange(1,65535)]$InfoEventID = 1,
[int][ValidateRange(1,65535)]$InfoLoopStartEventID = 2,
[int][ValidateRange(1,65535)]$InfoLoopEndEventID = 3,
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


#CheckLeafNotExists�߂�l

#�`�F�b�N�Ώۂ̃t�@�C�������݂��邪�A-OverRide���w��...$TRUE�@�i���̎w���-Continue�ɗD�悷��j
#�`�F�b�N�Ώۂ̃t�@�C�������݂��邪�A-Continue���w��...$False
#�`�F�b�N�Ώۂ̃t�@�C�������݂���...$ErrorReturnCode ��Finalize�֐i�ށA�܂���Break
#�`�F�b�N�Ώۂ̓��ꖼ�̂̃t�H���_�����݂��邪�A-OverRide���w��...�㏑�����o���Ȃ��̂�$ErrorReturnCode ��Finalize�֐i�ށA�܂���Break
#�`�F�b�N�ΏۂƓ��ꖼ�̂̃t�H���_�����݂��邪�A-Continue���w��...$False
#�`�F�b�N�ΏۂƓ��ꖼ�̂̃t�H���_�����݂���...$ErrorReturnCode ��Finalize�֐i�ށA�܂���Break
#�`�F�b�N�Ώۂ̃t�@�C���A�t�H���_�����݂��Ȃ�...$TRUE

function CheckLeafNotExists {

Param(
[parameter(mandatory=$true)][String]$CheckLeaf
)

Logging -EventID $InfoEventID -EventType Information -EventMessage "$($CheckLeaf)�̑��݂��m�F���܂�"

    #���Ƀt�@�C�������邪�AOverRide�w��͖����B����āA�ُ�I�� or Continue�w�肠��Ōp��

    If( (Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -AND (-NOT($OverRide)) ){

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "����$($CheckLeaf)�����݂��܂�"
        $Script:WarningFlag = $TRUE
        
        If(-NOT($Continue)){
 
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "����$($CheckLeaf)�����݂��邽�߁A${SHELLNAME}���I�����܂�"
            
            IF($ForceEndLoop){
                $Script:ErrorFlag = $TRUE
                $Script:ForceFinalize = $TRUE
                Break
                }else{
                Finalize $ErrorReturnCode
                }
            }else{
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]�̂��ߏ������p�����܂��B"
            $Script:ContinueFlag = $true

            #�����t�@�C��������̂�$False��Ԃ��ăt�@�C�����������Ȃ�
            Return $False
            }

      #���Ƀt�@�C�������邪�AOverRide�w�肪����B����Čp��  

     }elseif( (Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -AND ($OverRide) ){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "����$($CheckLeaf)�����݂��܂���-OverRide[$OverRide]�̂��ߏ㏑�����܂�"
            $Script:OverRideFlag = $TRUE

            #�����܂ŗ���΃t�@�C�������݂��Ȃ��͊m��B���ꖼ�̂̃t�H���_�����݂���\���͎c���Ă���
            #���ꖼ�̂̃t�H���_�����݂����OverRide�o���Ȃ��̂ŁAContinue�w�肠��̏ꍇ�͌p���B�w��Ȃ��ňُ�I��

            }elseif(Test-Path -LiteralPath $CheckLeaf -PathType Container){

                Logging -EventID $WarningEventID -EventType Warning -EventMessage "���ɓ��ꖼ�̃t�H���_$($CheckLeaf)�����݂��܂�"
                $Script:WarningFlag = $TRUE

                IF(-NOT($Continue)){

                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "���ɓ��ꖼ�̃t�H���_$($CheckLeaf)�����݂��邽�߁A${SHELLNAME}���I�����܂�"

                    IF($ForceEndLoop){
                        $Script:ErrorFlag = $TRUE
                        $Script:ForceFinalize = $TRUE
                        Break
                        }else{
                        Finalize $ErrorReturnCode
                        }
            
                    }else{
                    Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]�̂��ߏ������p�����܂��B"
                    $Script:ContinueFlag = $true

                    #�����t�H���_������̂�$False��Ԃ��ăt�@�C�����������Ȃ�
                    Return $False
                    }

            
            #���ꖼ�̂̃t�@�C���A�t�H���_���ɑ��݂��Ȃ�

            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($CheckLeaf)�͑��݂��܂���"            
            }

Return $true
}


filter ComplexFilter{

    IF ($_.LastWriteTime -lt (Get-Date).AddDays(-$Days)) {
    IF ($_.Name -match ${RegularExpression}){
    IF ($_.Length -ge (1024*$KBsize)){
    IF (($_.FullName).Substring($TargetFolder.Length , (Split-Path -Parent $_.FullName).Length - $TargetFolder.Length +1) -match ${ParentRegularExpression})
        {Return $_}
    }
    } 
    }                                                                              

}



function GetFolders{

Param(
[parameter(mandatory=$true)][String]$TargetFolder
)


$Folders = @()

    If($Recurse){

            $TargetFolders = Get-ChildItem -LiteralPath $TargetFolder -Directory -Recurse      
                           
            }else{

            $TargetFolders = Get-ChildItem -LiteralPath $TargetFolder -Directory
            }
    

ForEach ($Folder in ($TargetFolders | ComplexFilter))
          
    {
    $Folders += New-Object PSObject -Property @{
      Object = $Folder
      Depth = ($Folder.FullName.Split("\\")).Count
    }
}

#�z��ɓ��ꂽ�p�X�ꎮ���p�X���[�����ɐ���B��t�H���_����t�H���_�ɓ���q�ɂȂ��Ă���ꍇ�A�[���K�w����폜����K�v������B

$Folders = $Folders | Sort Depth -Descending

Return $Folders

}


function GetFiles{

Param(
[parameter(mandatory=$true)][String]$TargetFolder
)


    If($Recurse){

         
            Return Get-ChildItem -LiteralPath $TargetFolder -File -Recurse -Include * | ComplexFilter | ForEach-Object {$_.FullName}            
                                                     
            }else{

            Return Get-ChildItem -LiteralPath $TargetFolder -File -Include * | ComplexFilter | ForEach-Object {$_.FullName}
            }
    
}


function Initialize {



#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�


#Switch����

IF($NoRecurse){[boolean]$Script:Recurse = $false}


#�p�����[�^�̊m�F


#�w��t�H���_�̗L�����m�F
#CheckContainer function��$True,$False���ߒl�Ȃ̂�$Null�֎̂Ă�B�̂ĂȂ��ƃR���\�[���o�͂����

    $TargetFolder = ConvertToAbsolutePath -CheckPath $TargetFolder -ObjectName  '�w��t�H���_-TargetFolder'

   CheckContainer -CheckPath $TargetFolder -ObjectName '�w��t�H���_-TargetFolder' -IfNoExistFinalize > $NULL



#�ړ���t�H���_�̗v�s�v�ƗL�����m�F

    If (  ($Action -match "^(Move|Copy)$") -OR ($MoveNewFile)  ){
    

        $MoveToFolder = ConvertToAbsolutePath -CheckPath $MoveToFolder -ObjectName '�ړ���t�H���_-MoveToFolder'

        CheckContainer -CheckPath $MoveToFolder -ObjectName '�ړ���t�H���_-MoveToFolder' -IfNoExistFinalize > $NULL
 

                  
     }elseif(-NOT (CheckNullOrEmpty -CheckPath $MoveToFolder)){
                Logging -EventID $ErrorEventID -EventType Error -EventMessage "Action[$($Action)]�̎��A-MoveToFolder�w��͕s�v�ł�"
                Finalize $ErrorReturnCode
                }

#�g�ݍ��킹���s���Ȏw����m�F

    If(($TargetFolder -eq $MoveToFolder) -AND (($Action -match "move|copy") -OR  ($MoveNewFile))){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "�ړ���t�H���_�ƈړ���t�H���_�Ƃ�����̎��ɁA�t�@�C���̈ړ��A�����͏o���܂���"
				Finalize $ErrorReturnCode
                }


    If (($Action -match "^(Move|Delete)$") -AND  ($NullOriginalFile)){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "�Ώۃt�@�C�����폜�܂��͈ړ���ANullClear���邱�Ƃ͏o���܂���"
				Finalize $ErrorReturnCode
                }


    If (($MoveNewFile) -AND  (-NOT(($Compress) -OR ($AddTimeStamp)))){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "-MoveNewFile�́A-Compres�܂���-AddTimeStamp�ƕ��p����K�v������܂��B���t�@�C���̈ړ��ɂ�-Action Move���w�肵�Ă�������"
				Finalize $ErrorReturnCode
                }


    IF ($Action -eq "DeleteEmptyFolders"){
        IF( ($Compress) -OR ($AddTimeStamp) -OR ($MoveNewFile) -OR($NullOriginalFile)){
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "��t�H���_�폜-Action[$Action]���w�肵�����̓t�@�C������͍s���܂���"
				Finalize $ErrorReturnCode

        }elseif($KBSize -ne 0){
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "��t�H���_�폜-Action[$Action]���w�肵�����̓t�@�C���e�ʎw��-KBsize�͍s���܂���"
				Finalize $ErrorReturnCode
                }
    }


    IF ($TimeStampFormat -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-TimeStampFormat��NTFS�Ŏg�p�ł��Ȃ��������w�肵�Ă��܂�"
				Finalize $ErrorReturnCode
                }



#�����J�n���b�Z�[�W�o��


Logging -EventID $InfoEventID -EventType Information -EventMessage "�p�����[�^�͐���ł�"

    IF ($Action -eq "DeleteEmptyFolders"){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "�w��t�H���_$($TargetFolder)��$($Days)���ȑO�̐��K�\�� $($RegularExpression) �Ƀ}�b�`�����t�H���_���ċA�I[$($Recurse)]�ɍ폜���܂�"
        
        }else{
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�w��t�H���_$($TargetFolder)��$($Days)���ȑO�̐��K�\�� $($RegularExpression) �Ƀ}�b�`����$($KBSize)KB�ȏ�̃t�@�C�����ړ���t�H���_$($MoveToFolder)�֍ċA�I[$($Recurse)]��Action[$($Action)]���܂��B"
        }

    IF( ($Compress) -OR ($AddTimeStamp)){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "�}�b�`�����t�@�C���̓t�@�C�����ɓ��t�t��[${AddTimeStamp}]�A���k[${Compress}]���āA�ړ���t�H���_$($MoveToFolder)�֍ċA�I[$($Recurse)]�Ɉړ�[$($MoveNewFile)]���܂�"
        }


    IF($OverRide){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-OverRide[${OverRide}]���w�肳��Ă��邽�ߐ��������t�@�C���Ɠ����̂��̂��������ꍇ�͏㏑�����܂�"
        }

    If($Continue){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-Continue[${Continue}]���w�肳��Ă��邽�ߐ��������t�@�C���Ɠ����̂��̂��������ꍇ���̏����ُ�ňُ�I���������̃t�@�C���A�t�H���_���������܂�"
        }

}

function GetTargetObjectName{

Param(
[parameter(mandatory=$true)]$TargetObject
)

    IF ($Action -eq "DeleteEmptyFolders"){

        Return $TargetObject.Object.Fullname
        
     }else{
        Return $TargetObject
        }

}

function CompressAndAddTimeStamp{

#���k�t���O�܂��̓^�C���X�^���v�t���t���O��True�̏���

 

#���k�t���OTrue�̎�

        IF($Compress){

            IF($AddTimeStamp){
                $ArchiveFile = Join-Path $TargetFileParentFolder ($FileNameWithOutExtentionString+$FormattedDate+$ExtensionString+$CompressedExtString)
                $ActionType = "CompressAndAddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "���k&�^�C���X�^���v�t������[$(Split-Path -Leaf $ArchiveFile)]���쐬���܂�"
            }else{
                $ArchiveFile = $TargetObject+$CompressedExtString
                $ActionType = "Compress"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "���k����[$(Split-Path -Leaf $ArchiveFile)]���쐬���܂�" 
            }          
 
        }else{


#�^�C���X�^���v�t���̂�True�̎�

                $ArchiveFile = Join-Path $TargetFileParentFolder ($FileNameWithOutExtentionString+$FormattedDate+$ExtensionString)
                $ActionType = "AddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "�^�C���X�^���v�t������[$(Split-Path -Leaf $ArchiveFile)]���쐬���܂�"
                }


#�ړ��t���O��True�Ȃ�΁A�쐬�������kor�^�C���X�^���v�t�������t�@�C�����ړ�����

    IF($MoveNewFile){

        $ArchiveFileCheckPath = Join-Path $MoveToNewFolder (Split-Path -Leaf $ArchiveFile)
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-MoveNewFile[$($MoveNewFile)]�̂��߁A�쐬�����t�@�C����$($MoveToNewFolder)�ɔz�u���܂�"

        }else{
        $ArchiveFileCheckPath = $ArchiveFile        
        }


      If(CheckLeafNotExists $ArchiveFileCheckPath){

            TryAction -ActionType $ActionType -ActionFrom $TargetObject -ActionTo $ArchiveFileCheckPath -ActionError $TargetObject
            }
}

function Finalize{

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)
    $ForceFinalize = $False

    IF(-NOT(($NormalCount -eq 0) -and ($WarningCount -eq 0) -and ($ErrorCount -eq 0))){
    

       Logging -EventID $InfoEventID -EventType Information -EventMessage "���s���ʂ͐���I��[$($NormalCount)]�A�x���I��[$($WarningCount)]�A�ُ�I��[$($ErrorCount)]�ł�"

       IF ($Action -eq "DeleteEmptyFolders"){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "�w��t�H���_$($TargetFolder)��$($Days)���ȑO�̐��K�\�� $($RegularExpression) �Ƀ}�b�`�����t�H���_���ċA�I[$($Recurse)]�ɍ폜���܂���"
            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "�w��t�H���_${TargetFolder}��${Days}���ȑO�̐��K�\�� ${RegularExpression} �Ƀ}�b�`����${KBSize}KB�ȏ�̑S�Ẵt�@�C�����ړ���t�H���_${MoveToFolder}�֍ċA�I[${Recurse}]��Action[${Action}]���܂���"
            }

        IF( ($Compress) -OR ($AddTimeStamp)){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "�}�b�`�����t�@�C���̓t�@�C�����ɓ��t�t��[${AddTimeStamp}]�A���k[${Compress}]���āA�ړ���t�H���_$($MoveToFolder)�֍ċA�I[$($Recurse)]�Ɉړ�[$($MoveNewFile)]���܂���"

            }

        IF($OverRide -and ($OverRideCount -gt 0)){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-OverRide[${OverRide}]���w�肳��Ă��邽�ߐ��������t�@�C���Ɠ����̂��̂�[$($OverRideCount)]��A�㏑�����܂���"
            }

        IF(($Continue) -and ($ContinueCount -gt 0)){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-Continue[${Continue}]���w�肳��Ă��邽�ߐ��������t�@�C���Ɠ����̂��̂��������ꍇ���̏����ُ�ňُ�I���������̃t�@�C���A�t�H���_��[$($ContinueCount)]�񏈗����܂���"
            }
    }


EndingProcess $ReturnCode

}






#####################   ��������{��  ######################

[boolean]$ErrorFlag = $False
[boolean]$WarningFlag = $False
[boolean]$NormalFlag = $False
[boolean]$OverRideFlag = $False
[boolean]$ContinueFlag = $False
[Boolean]$ForceFinalize = $False
[Boolean]$ForceEndloop = $False
[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0
[int][ValidateRange(0,2147483647)]$OverRideCount = 0
[int][ValidateRange(0,2147483647)]$ContinueCount = 0

${THIS_FILE}=$MyInvocation.MyCommand.Path       �@�@                    #�t���p�X
${THIS_PATH}=Split-Path -Parent ($MyInvocation.MyCommand.Path)          #���̃t�@�C���̃p�X
${SHELLNAME}=[System.IO.Path]::GetFileNameWithoutExtension($THIS_FILE)  # �V�F����

${Version} = '20200123_1145'


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize



#�Ώۂ̃t�H���_�܂��̓t�@�C����T���Ĕz��ɓ����

$TargetObjects = @()

Write-Output '�����Ώۂ͈ȉ��ł�'

    IF($Action -eq "DeleteEmptyFolders"){

        $TargetObjects = GetFolders $TargetFolder
        Write-Output $TargetObjects.Object.Fullname

        }else{
        $TargetObjects = GetFiles $TargetFolder
        Write-Output $TargetObjects
        }

    If ($null -eq $TargetObjects){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($TargetFolder)�ɏ����ΏۂƂȂ�t�@�C���A�܂��̓t�H���_�͂���܂���"

        IF($NoneTargetAsWarning){
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-NoneTargetAsWarning���w�肳��Ă��邽�߁A�x���I�������ɂ��܂�"
            Finalize $WarningReturnCode
            }
            else{
            Finalize $NormalReturnCode
            }
    }


#�Ώۃt�H���_or�t�@�C���Q�̏������[�v
#�Ώۃt�H���_�̓I�u�W�F�N�g�A�Ώۃt�@�C���̓t�@�C�����ύXor�ړ������邽�߃p�X������Ƃ��ď���

ForEach ($TargetObject in $TargetObjects)
{

#Powershell��GOTO�������݂����������򂪂ł��Ȃ��B
#���̂���Do/While��p���ď����r���ŃG���[�����������ꍇ�̕�����������Ă���

#Do/While()�͍Ō�ɕ]�����s���郋�[�v�B�Ō�̕]����False�ƂȂ�ƃ��[�v���I������B������While($false)�Ƃ��Ă���̂ŁA
#Do/While�̊Ԃ�1�񂾂����s�����B
#Do/While�̓��[�v�̂��߁A�����r����Break����ƁAWhile��jump����B

#�t�@�C���Q�������[�v���̃G���[�i�Ⴆ�΁A�t�@�C����Delete���s�������A�����������č폜�ł��Ȃ����j�őz�肳��鏈���A�w����@�͈ȉ��ł���B

#1.While�ȍ~�̏����I�����b�Z�[�W�o�͂�Jump���āA���̃t�@�C���������p��
# Break , $ForceEndloog = $TRUE , $ForceFinalize = $False 
#2.While�ȍ~�̏����I�����b�Z�[�W�o�͂�Jump���āA���̃t�@�C���͏���������Finalize�֐i�ށi�����ł��؂�j
# Break , $ForceEndloog = $TRUE , $ForceFinalize = $TRUE
#3.�����I�����b�Z�[�W�o�͂��Ȃ��BFinalize�֐i�ށi�����ł��؂�j
#Finalize $ErrorReturnCode
 

Do
{

    [boolean]$ErrorFlag = $False
    [boolean]$WarningFlag = $False
    [boolean]$NormalFlag = $False
    [boolean]$OverRideFlag = $False
    [boolean]$ContinueFlag = $False
    [Boolean]$ForceEndloop = $TRUE
    [int]$InLoopOverRideCount = 0

    $FormattedDate = (Get-Date).ToString($TimeStampFormat)
    $ExtensionString = [System.IO.Path]::GetExtension($TargetObject)
    $FileNameWithOutExtentionString = [System.IO.Path]::GetFileNameWithoutExtension($TargetObject)
    $TargetFileParentFolder = Split-Path $TargetObject -Parent

    $TargetObjectName = GetTargetObjectName $TargetObject

    Logging -EventID $InfoLoopStartEventID -EventType Information -EventMessage "--- �Ώ�Object $($TargetObjectName) �����J�n---"



#�ړ����̃t�@�C���p�X����ړ���̃t�@�C���p�X�𐶐��B
#�ċA�I�łȂ���΁A�ړ���p�X�͊m���ɑ��݂���̂ŃX�L�b�v
#�t�@�C���폜�܂��͉������Ȃ��Ƃ��͈ړ���p�X���m�F����K�v���Ȃ��̂ŃX�L�b�v

    If( (($Action -match "^(Move|Copy)$")) -OR ($MoveNewFile)) {

        #�t�@�C�����ړ�����Action�p�Ƀt�@�C���ړ���̐e�t�H���_�p�X$MoveToNewFolder�𐶐�����
        
        #C:\TargetFolder                    :TargetFolder
        #C:\TargetFolder\A\B\C              :TargetFileParentFolder
        #C:\TargetFolder\A\B\C\target.txt   :TargetFile
        #D:\MoveToFolder                    :MoveToFolder
        #D:\MoveToFolder\A\B\C              :MoveToNewFolder

        #D:\MoveToFolder\A\B\C\target.txt   :�t�@�C���̈ړ���p�X

        #MoveToNewFolder�����ɂ� \A\B\C\�@�̕��������o���āA�ړ���t�H���_MoveToFolder��Join-Path����
        # String.Substring���\�b�h�͕����񂩂�A�����ʒu����Ō�܂ł����o��

        $MoveToNewFolder = Join-Path $MoveToFolder ($TargetFileParentFolder).Substring($TargetFolder.Length)
        If($Recurse){

            If (-NOT(CheckContainer -CheckPath $MoveToNewFolder -ObjectName �ړ���t�H���_)){

                Logging -EventID $InfoEventID -EventType Information -EventMessage "�V�K��$($MoveToNewFolder)���쐬���܂�"

                TryAction -ActionType MakeNewFolder -ActionFrom $MoveToNewFolder -ActionError $MoveToNewFolder

                IF($ContinueFlag){
                    Break                
                    }
            }
        }
    }


#Pre Action
#���k�t���O�܂��̓^�C���X�^���v�t���t���O��True�̏���

   IF( ($Compress) -OR ($AddTimeStamp)){
        CompressAndAddTimeStamp
        }


#Main Action


    Switch -Regex ($Action){

    #����1 �������Ȃ�
    '^none$'
            {
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Action[${Action}]�̂��ߑΏۃt�@�C��${TargetObject}�͑��삵�܂���"
            }

    #����2 �폜
    '^Delete$'
            {
            TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject
            } 

    #����3 �ړ� or ���� �@����̃t�@�C�����i�ړ�|������j�ɑ��݂��Ȃ����Ƃ��m�F���Ă��珈��
    '^(Move|Copy)$'
            {
            $TargetFileMoveToPath = Join-Path $MoveToNewFolder (Split-Path -Leaf $TargetObject)

            If(CheckLeafNotExists $TargetFileMoveToPath){

                TryAction -ActionType $Action -ActionFrom $TargetObject -ActionTo $TargetFileMoveToPath -ActionError $TargetObject
                }           
            }

    #����4 ��t�H���_�𔻒肵�č폜
    '^DeleteEmptyFolders$'
            {
            Logging -EventID $InfoEventID -EventType Information -EventMessage  "�t�H���_$($TargetObjectName)���󂩂��m�F���܂�"


            If ($TargetObject.Object.GetFileSystemInfos().Count -eq 0){
     
                Logging -EventID $InfoEventID -EventType Information -EventMessage  "�t�H���_$($TargetObjectName)�͋�ł�"
                TryAction -ActionType Delete -ActionFrom $TargetObjectName -ActionError $TargetObjectName


                }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage "�t�H���_$($TargetObjectName)�͋�ł͂���܂���" 
                }
            }


    #����5 NullClear
    '^NullClear$'
            {
            TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject          
            }


    #����6 $Action���������̂ǂꂩ�ɓK�����Ȃ��ꍇ�́A�v���O�����~�X
    Default 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Action����̓����G���[�B���莮��bug������܂�"
            Finalize $InternalErrorReturnCode
            }
    }


#Post Action
#null clear�t���O�����̏ꍇ��null clear����

    IF ($NullOriginalFile){

        TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject
        }



#�ُ�I���Ȃǂ�Break���ăt�@�C�������I�[�֔�����B
}
While($False)


#�ُ�A�x�����m�F�B�ُ�>�x��>����̏��ʂŎ��s���ʐ��J�E���g�A�b�v

    IF($ErrorFlag){
        $ErrorCount ++
        }elseif($WarningFlag) {
            $WarningCount ++
            }elseif($NormalFlag){
                $NormalCount ++
                }

    IF($ContinueFlag){
        $ContinueCount ++
        }
         
    Logging -EventID $InfoLoopEndEventID -EventType Information -EventMessage "--- �Ώ�Object $($TargetObjectName) �����I�� Normal[$($NormalFlag)] Warning[$($WarningFlag)] Error[$($ErrorFlag)]  Continue[$($ContinueFlag)]  OverRide[$($InLoopOverRideCount)]---"
  

    IF($ForceFinalize){
    
        Finalize $ErrorReturnCode
        }

#�ΏیQ�̏������[�v�I�[
   
}


#�I�����b�Z�[�W�o��

Finalize $NormalReturnCode

