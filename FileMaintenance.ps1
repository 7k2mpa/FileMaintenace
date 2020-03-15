#Requires -Version 5.0
#If you do not use '-PreAction compress or archive' without 7z in FileMaintenance.ps1, you will be able to use '-Version 3.0' insted of  '-Version 5.0'

<#
.SYNOPSIS
This script processes log files to delete, move, archive, etc.... with multi functions.
CommonFunctions.ps1 is required.
You can process log files in multiple folders with Wrapper.ps1
<Common Parameters> is not supported.


���O�t�@�C�����k�A�폜���n�߂Ƃ����F�X�ȏ��������閜�\�c�[���ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B
�Z�b�g�ŊJ�����Ă���Wrapper.ps1�ƕ��p����ƕ����������ꊇ���s�ł��܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
This script filters files and folders with multiple criterias.
Process the files and filders filtered.


�Ώۂ̃t�H���_�Ɋ܂܂��A�t�@�C���A�t�H���_���e������Ńt�B���^���đI�����܂��B
�t�B���^���ʂ��p�����[�^�Ɋ�Â��A�O�����A�又���A�㏈�����܂��B

�t�B���^���ʂɑ΂��ĉ\�ȏ����͈ȉ��ł��B

-�O����:�Ώۃt�@�C������ʃt�@�C���𐶐����܂��B�\�ȏ����́u�t�@�C�����Ƀ^�C���X�^���v�t���v�u���k�v�u���������ʃt�@�C���̈ړ��v�u�����̃t�@�C����1�t�@�C���ɃA�[�J�C�u�v�ł��B���p�w��\�ł��B�u���������ʃt�@�C���̈ړ��v���w�肵�Ȃ��ƑΏۃt�@�C���Ɠ���t�H���_�ɔz�u���܂��B
-�又��:�Ώۃt�@�C�����u�ړ��v�u�����v�u�폜�v�u���e�����i�k���N���A�j�v�A�t�H���_���u��t�H���_�폜�v���܂��B
-�㏈��:�Ώۃt�@�C�����u���e�����i�k���N���A�j�v�u���̕ύX�v���܂��B

�t�B���^�́u�o�ߓ����v�u�e�ʁv�u���K�\���v�u�Ώۃt�@�C���A�t�H���_�̐e�p�X�Ɋ܂܂�镶���̐��K�\���v�Ŏw��ł��܂��B

���̃v���O�����P�̂ł́A1�x�ɏ����ł���̂�1�t�H���_�ł��B�����t�H���_�������������ꍇ�́AWrapper.ps1�𕹗p���Ă��������B


���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B

���̃v���O������PowerShell 5.0�ȍ~���K�v�ł��B
Windows Server 2008,2008R2��WMF(Windows Management Framework)5.0�ȍ~��ǉ��C���X�g�[�����Ă��������B����ȑO��OS�ł͉ғ����܂���B

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

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Copy -MoveToFolder C:\TEST1 -Size 10KB -continue
C:\TEST�ȉ��̃t�@�C����10KB�ȏ�̂��̂��ċA�I��C:\TEST1�֕������܂��B�ړ���Ɏq�t�H���_��������΍쐬���܂�
�ړ���ɓ��ꖼ�̂̃t�@�C�����������ꍇ�̓X�L�b�v���ď������p�����܂�

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,AddTimeStamp -Action NullClear
C:\TEST�ȉ��̃t�@�C�����ċA�I�� �u.log�ŏI���v���̂փt�@�C�����ɓ��t��t�����Ĉ��k���܂��B
���t�@�C���͎c��܂����A���e�����i�k���N���A�j���܂��B

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,MoveNewFile -Action Delete -MoveToFolder C:\TEST1 -OverRide -Days 10

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

.PARAMETER PreAction
�����Ώۂ̃t�@�C���ɑ΂��鑀���ݒ肵�܂��B�ȉ��̃p�����[�^���w�肵�ĉ������B
PreAction��(Action|PostAction)�ƈقȂ蕡���p�����[�^���w��ł��܂��B
�p�����[�^�̓J���},�ŋ�؂��ĉ������B

None:������������܂���B���̐ݒ肪�f�t�H���g�ł��B����͌둀��h�~�̂��߂ɂ���܂��B���쌟�؂ɂ�-NoAction�X�C�b�`�𗘗p���ĉ������B
Compress:�Ώۃt�@�C�����爳�k�����t�@�C����V�K�������܂��B
AddTimeStamp:�Ώۃt�@�C������t�@�C������-TimeStampFormat�Œ�߂�ꂽ�����Ń^�C���X�^���v�t�������t�@�C����V�K�������܂��B
Archive:�Ώۃt�@�C���Q���܂Ƃ߂�1�A�[�J�C�u�t�@�C����V�K�������܂��B-OverRide���w�肷��ƁA�����A�[�J�C�u�t�@�C���֑Ώۃt�@�C���Q��ǉ����܂��B�A�[�J�C�u�t�@�C����-ArchiveFileName�Ŏw�肵���t�@�C�����ł��B
MoveNewFile:-PreAction�̐V�K�����t�@�C����-TargetFolder�Ɠ���ł͂Ȃ��A-MoveToFolder�֔z�u���܂��B
7z:Compress,Archive�Ɏg�p���鈳�k��7z.exe��p���܂��B���k���@��7z.exe�̕W��LZMA2��p���܂��B
7zZip:Compress,Archive�Ɏg�p���鈳�k��7z.exe��p���܂��B���k���@��Zip(Deflate)��p���܂��B

.PARAMETER Action
�����Ώۂ̃t�@�C���ɑ΂��鑀���ݒ肵�܂��B�ȉ��̃p�����[�^���w�肵�ĉ������B

None:������������܂���B���̐ݒ肪�f�t�H���g�ł��B����͌둀��h�~�̂��߂ɂ���܂��B���쌟�؂ɂ�-NoAction�X�C�b�`�𗘗p���ĉ������B
Move:�t�@�C����-MoveToFolder�ֈړ����܂��B
Delete:�t�@�C�����폜���܂��B
Copy:�t�@�C����-MoveToFolder�ɃR�s�[���܂��B
DeleteEmptyFolders:��t�H���_���폜���܂��B
KeepFilesCount:�w�萢�㐔�ɂȂ�܂ŁA�}�b�`�����t�@�C���Q���Â����ɍ폜���܂��B
NullClear:�t�@�C���̓��e�폜 NullClear���܂��B

.PARAMETER PostAction
�����Ώۂ̃t�@�C���ɑ΂��鑀���ݒ肵�܂��B�ȉ��̃p�����[�^���w�肵�ĉ������B

None:������������܂���B���̐ݒ肪�f�t�H���g�ł��B����͌둀��h�~�̂��߂ɂ���܂��B���쌟�؂ɂ�-NoAction�X�C�b�`�𗘗p���ĉ������B
Rename:�t�@�C�����𐳋K�\��-RenameToRegularExpression�Œu�����܂��B
NullClear:�t�@�C���̓��e�폜 NullClear���܂��BPostAction�̂��߁AAction�ƕ��p�\�ł��B�Ⴆ�΃t�@�C��������A���t�@�C�����폜����A�Ƃ������p�r�Ɏg�p���ĉ������B


.PARAMETER MoveToFolder
�@�����Ώۂ̃t�@�C���̈ړ��A�R�s�[��t�H���_���w�肵�܂��B
���΁A��΃p�X�Ŏw��\�ł��B
���΃p�X�\�L�́A.����n�߂�\�L�ɂ��ĉ������B�i�� .\Log , ..\Script\log�j
���C���h�J�[�h* ? []�͎g�p�ł��܂���B
�t�H���_���Ɋ��� [ , ] ���܂ޏꍇ�̓G�X�P�[�v�����ɂ��̂܂ܓ��͂��Ă��������B

.PARAMETER ArchiveFileName
-PreAction Archive�w�莞�̃A�[�J�C�u�t�@�C�������w�肵�܂��B


.PARAMETER 7zFolder 
Compress,Archive�ɊO���v���O����7z.exe���g�p����ۂɁA7-Zip���C���X�g�[������Ă���t�H���_���w�肵�܂��B
�f�t�H���g��[C:\Program Files\7-Zip]�ł��B

.PARAMETER Days
�@�����Ώۂ̃t�@�C���A�t�H���_���X�V�o�ߓ����Ńt�B���^���܂��B
�f�t�H���g��0���őS�Ẵt�@�C�����ΏۂƂȂ�܂��B

.PARAMETER Size
�@�����Ώۂ̃t�@�C����e�ʂŃt�B���^���܂��B
�f�t�H���g��0KB�őS�Ẵt�@�C�����ΏۂƂȂ�܂��B
�����\�L�ɉ����āAKB,MB,GB�̐ڔ��������p�\�ł��B
�Ⴆ��-Size 10MB�́A�����I��10*1024^6�Ɋ��Z���Ă���܂��B

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

.PARAMETER RenameToRegularExpression
-PostAction Rename���w�肵���ꍇ�̃t�@�C�������K�\���u���K�����w�肵�܂��B
-RegularExpression�ɑ΂���u���p�^�[�����w�肵�܂��B
https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/substitutions-in-regular-expressions


.PARAMETER Recurse
�@-TargetFolder�̒����̍ċA�I�܂��͔�ċA�ɏ����̎w�肪�\�ł��B
�f�t�H���g��$TRUE�ōċA�I�����ł��B

.PARAMETER NoRecurse
�@-TargetFolder�̒����݂̂������ΏۂƂ��܂��B-Recurse $FALSE�Ɠ����ł��B
Recurse�p�����[�^���D�悵�܂��B

.PARAMETER OverRide
�@�ړ��A�R�s�[��Ɋ��ɓ����̃t�@�C�������݂��Ă������I�ɏ㏑�����܂��B
�f�t�H���g�ł͏㏑�������Ɉُ�I�����܂��B

.PARAMETER Continue
�@�ړ��A�R�s�[��Ɋ��ɓ����̃t�@�C�������݂����ꍇ���Y�t�@�C���̏������X�L�b�v���܂��B
�X�L�b�v����ƌx���I�����܂��B
�f�t�H���g�ł̓X�L�b�v�����Ɉُ�I�����܂��B

.PARAMETER ContinueAsNormal
�@�ړ��A�R�s�[��Ɋ��ɓ����̃t�@�C�������݂����ꍇ���Y�t�@�C���̏������X�L�b�v���܂��B
-Continue�ƈقȂ�X�L�b�v���Ă�����I�����܂��B�t�@�C���̍����R�s�[���ŗ��p���Ă��������B
-Continue�ɗD�悵�܂��B
�f�t�H���g�ł̓X�L�b�v�����Ɉُ�I�����܂��B

.PARAMETER NoAction
�t�@�C���A�t�H���_�����ۂɍ폜���̑���������Ɏ��s���܂��B�S�Ă̏����͐��������ɂȂ�܂��B
����m�F����Ƃ��ɓ��Y�X�C�b�`���w�肵�Ă��������B
���O��͌x�����o�͂���܂����A���s���ʂł͂��̌x���͖�������܂��B

.PARAMETER NoneTargetAsWarning
����Ώۂ̃t�@�C���A�t�H���_�����݂��Ȃ��ꍇ�Ɍx���I�����܂��B
���̃X�C�b�`��ݒ肵�Ȃ��Ƒ��݂��Ȃ��ꍇ�͒ʏ�I�����܂��B


.PARAMETER CompressedExtString
�@-PreAction Compress�w�莞�̃t�@�C���g���q���w��ł��܂��B
�f�t�H���g��[.zip]�ł��B

.PARAMETER TimeStampFormat
�@-PreAction AddTimeStamp�w�莞�̏������w��ł��܂��B
�f�t�H���g��[_yyyyMMdd_HHmmss]�ł��B

.PARAMETER KeepFiles
-Action KeepFilesCount�w�莞�̐��㐔���w�肵�܂��B
�f�t�H���g��1�ł��B

.PARAMETER Compress
���̃p�����[�^�͔p�~�\��ł��B����݊����̂��߂Ɏc���Ă��܂����A-PreAction Compress���g�p���Ă��������B
�Ώۃt�@�C�������k���ĕʃt�@�C���Ƃ��ĕۑ����܂��B

.PARAMETER AddTimeStamp
���̃p�����[�^�͔p�~�\��ł��B����݊����̂��߂Ɏc���Ă��܂����A-PreAction AddTimeStamp���g�p���Ă��������B
�Ώۃt�@�C�����ɓ�����t�����ĕʃt�@�C���Ƃ��ĕۑ����܂��B

.PARAMETER MoveNewFile
���̃p�����[�^�͔p�~�\��ł��B����݊����̂��߂Ɏc���Ă��܂����A-PreAction MoveNewFile���g�p���Ă��������B
-PreAction Compress , AddTimeStamp���w�肵���ۂɐ��������ʃt�@�C����-MoveToFolder�̎w���ɕۑ����܂��B
�f�t�H���g�͑Ώۃt�@�C���Ɠ���f�B���N�g���֕ۑ����܂��B

.PARAMETER NullOriginalFile
���̃p�����[�^�͔p�~�\��ł��B����݊����̂��߂Ɏc���Ă��܂����A-PostAction NullClear�܂���-Action NullClear���g�p���Ă��������B
�Ώۃt�@�C���̓��e�����i�k���N���A�j���܂��B
-PostAction NullClear�Ɠ����ł��B



.PARAMETER Log2EventLog
�@Windows Event Log�ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE��Event Log�o�͂��܂��B

.PARAMETER NoLog2EventLog
�@Event Log�o�͂�}�~���܂��B-Log2EventLog $FALSE�Ɠ����ł��B
Log2EventLog���D�悵�܂��B

.PARAMETER ProviderName
�@Windows Event Log�o�͂̃v���o�C�_�����w�肵�܂��B
�f�t�H���g��[Infra]�ł��B

.PARAMETER EventLogLogName
�@Windows Event Log�o�͂̃��O�����w�肵�܂��B
�f�t�H���g��[Application]�ł��B

.PARAMETER Log2Console 
�@�R���\�[���ւ̃��O�o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE�ŃR���\�[���o�͂��܂��B

.PARAMETER NoLog2Console
�@�R���\�[�����O�o�͂�}�~���܂��B-Log2Console $FALSE�Ɠ����ł��B
Log2Console���D�悵�܂��B

.PARAMETER Log2File
�@���O�t�B���ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$FALSE�Ń��O�t�@�C���o�͂��܂���B

.PARAMETER NoLog2File
�@���O�t�@�C���o�͂�}�~���܂��B-Log2File $FALSE�Ɠ����ł��B
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
�@���O�t�@�C���o�͂Ɋ܂܂������\���t�H�[�}�b�g���w�肵�܂��B
�f�t�H���g��[yyyy-MM-dd-HH:mm:ss]�`���ł��B

.PARAMETER LogFileEncode
���O�t�@�C���̕����R�[�h���w�肵�܂��B
�f�t�H���g��Shift-JIS�ł��B

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

.PARAMETER InfoLoopStartEventID
�@Event Log�o�͂Ńt�@�C��/�t�H���_�����J�n��Information�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��2�ł��B

.PARAMETER InfoLoopEndEventID
�@Event Log�o�͂Ńt�@�C��/�t�H���_�����I����Information�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��3�ł��B

.PARAMETER WarningEventID
�@Event Log�o�͂�Warning�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��10�ł��B

.PARAMETER SuccessEventID
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


The origin of [Delete Empty Folders] function comes from Martin Pugh's Remove-EmptyFolders released under MIT License.
 (https://github.com/martin9700/Remove-EmptyFolders)
See also LICENSE_Remove-EmptyFolders.txt File.

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

[parameter(position=0, mandatory=$TRUE , HelpMessage = '�����Ώۂ̃t�H���_���w��(ex. D:\Logs) �S�Ă�Help��Get-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$TargetFolder,

#[parameter(position=0, mandatory=$TRUE , HelpMessage = '�����Ώۂ̃t�H���_���w��(ex. D:\Logs) �S�Ă�Help��Get-Help FileMaintenance.ps1')][String]$TargetFolder,  #Validation debug�p�ɗp�ӂ��Ă���܂��B�ʏ�͎g��Ȃ�
#[parameter(position=0, mandatory=$TRUE , HelpMessage = '�����Ώۂ̃t�H���_���w��(ex. D:\Logs) �S�Ă�Help��Get-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$TargetFolder ,
 

[Array][parameter(position=1)][ValidateSet("AddTimeStamp", "Compress", "MoveNewFile" , "none" , "Archive" , "7z" , "7zZip")]$PreAction = 'none',

[String][parameter(position=2)][ValidateSet("Move", "Copy", "Delete" , "none" , "DeleteEmptyFolders" , "NullClear" , "KeepFilesCount")]$Action = 'none',

[String][parameter(position=3)][ValidateSet("none"  , "NullClear" , "Rename")]$PostAction = 'none',


[String][parameter(position=4)][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$MoveToFolder,


[String][ValidatePattern('^(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$ArchiveFileName = "archive.zip" ,

[Int][ValidateRange(0,2147483647)]$KeepFiles = 1,
[Int][ValidateRange(0,730000)]$Days = 0,
[Int64][ValidateRange(0,9223372036854775807)]$Size = 0,

#[Regex]$RegularExpression = 'applog([0-9][0-9])([0-9][0-9])([0-9][0-9])',
#[Regex]$RegularExpression = '\.txt$',
[Regex]$RegularExpression = '.*',
[Regex]$ParentRegularExpression = '.*',

[Regex]$RenameToRegularExpression = '.loglog',
#[Regex]$RenameToRegularExpression = 'applicationlog-20$1-$2-$3',

[Boolean]$Recurse = $TRUE,
[Switch]$NoRecurse,


[Switch]$OverRide,
[Switch]$Continue,
[Switch]$ContinueAsNormal,
[Switch]$NoAction,
[Switch]$NoneTargetAsWarning,

[String]$CompressedExtString = '.zip',
[String]$7zFolder = 'C:\Program Files\7-Zip',

[String][ValidatePattern('^(?!.*(\\|\/|:|\?|`"|<|>|\|)).*$')]$TimeStampFormat = '_yyyyMMdd_HHmmss',

#�ȉ��X�C�b�`�Q�͔p�~�\��
[Switch]$Compress,
[Switch]$AddTimeStamp,
[Switch]$MoveNewFile,
[Switch]$NullOriginalFile,
#�ȏ�X�C�b�`�Q�͔p�~�\��


[Boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[Boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,

[Boolean]$Log2File = $FALSE,
[Switch]$NoLog2File,
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath = '.\SC_Logs\Infra.log',
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath = ..\Log\FileMaintenance.log ,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath  ,
[String]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss',
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default�w���Shift-Jis

[Int][ValidateRange(0,2147483647)]$NormalReturnCode = 0,
[Int][ValidateRange(0,2147483647)]$WarningReturnCode = 1,
[Int][ValidateRange(0,2147483647)]$ErrorReturnCode = 8,
[Int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16,

[Int][ValidateRange(1,65535)]$InfoEventID = 1,
[Int][ValidateRange(1,65535)]$InfoLoopStartEventID = 2,
[Int][ValidateRange(1,65535)]$InfoLoopEndEventID = 3,
[Int][ValidateRange(1,65535)]$WarningEventID = 10,
[Int][ValidateRange(1,65535)]$SuccessEventID = 73,
[Int][ValidateRange(1,65535)]$InternalErrorEventID = 99,
[Int][ValidateRange(1,65535)]$ErrorEventID = 100,

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

function CheckLeafNotExists {

<#
.SYNOPSIS
�@�w�肵���p�X�Ƀt�@�C�������݂��Ȃ������m�F����

.INPUT
�@Strings of File Path

.OUTPUT
�@Boolean
    �`�F�b�N�Ώۂ̃t�@�C�������݂��邪�A-OverRide���w��...$TRUE�@�i���̎w���-Continue�ɗD�悷��j�Ȃ�TryAction�͊��Ƀt�@�C�������݂���ꍇ�͋����㏑��
    �`�F�b�N�Ώۂ̃t�@�C�������݂��邪�A-Continue���w��...$FALSE
    �`�F�b�N�Ώۂ̃t�@�C�������݂���...$ErrorReturnCode ��Finalize�֐i�ށA�܂���Break
    �`�F�b�N�Ώۂ̓��ꖼ�̂̃t�H���_�����݂��邪�A-OverRide���w��...�㏑�����o���Ȃ��̂�$ErrorReturnCode ��Finalize�֐i�ށA�܂���Break
    �`�F�b�N�ΏۂƓ��ꖼ�̂̃t�H���_�����݂��邪�A-Continue���w��...$FALSE
    �`�F�b�N�ΏۂƓ��ꖼ�̂̃t�H���_�����݂���...$ErrorReturnCode ��Finalize�֐i�ށA�܂���Break
    �`�F�b�N�Ώۂ̃t�@�C���A�t�H���_�����݂��Ȃ�...$TRUE
#>

Param(
[parameter(mandatory=$TRUE)][String]$CheckLeaf
)

Logging -EventID $InfoEventID -EventType Information -EventMessage "Check existence of $($CheckLeaf)"

    #���Ƀt�@�C�������邪�AOverRide�w��͖����B����āA�ُ�I�� or Continue�w�肠��Ōp��

    If ((Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -and (-not($OverRide))) {

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "File $($CheckLeaf) exists already."

        IF (-not($ContinueAsNormal)) {
            $Script:WarningFlag = $TRUE
            }    
        If (-not($Continue)) {
 
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "File $($CheckLeaf) exists already, thus force to terminate $($ShellName)"
            
                IF ($ForceEndLoop) {
                    $Script:ErrorFlag = $TRUE
                    $Script:ForceFinalize = $TRUE
                    Break
                    }else{
                    Finalize $ErrorReturnCode
                    }
            }else{
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "Specified -Continue[$($Continue)] option, continue to process objects."
            $Script:ContinueFlag = $TRUE

            #�����t�@�C��������̂�$FALSE��Ԃ��ăt�@�C�����������Ȃ�
            Return $FALSE
            }

      #���Ƀt�@�C�������邪�AOverRide�w�肪����B����Čp��  

     }elseIF ((Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -and ($OverRide)) {

            Logging -EventID $InfoEventID -EventType Information -EventMessage "File $($CheckLeaf) exists already, but specified -OverRide[$OverRide] option,thus override the file."
            $Script:OverRideFlag = $TRUE

            #�����܂ŗ���΃t�@�C�������݂��Ȃ��͊m��B���ꖼ�̂̃t�H���_�����݂���\���͎c���Ă���
            #���ꖼ�̂̃t�H���_�����݂����OverRide�o���Ȃ��̂ŁAContinue�w�肠��̏ꍇ�͌p���B�w��Ȃ��ňُ�I��

            }elseIF (Test-Path -LiteralPath $CheckLeaf -PathType Container) {

                Logging -EventID $WarningEventID -EventType Warning -EventMessage "Same name folder $($CheckLeaf) exists already."
                $Script:WarningFlag = $TRUE

                IF (-not($Continue)) {

                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "Same name folder $($CheckLeaf) exists already, thus force to terminate $($ShellName)"

                    IF ($ForceEndLoop) {
                        $Script:ErrorFlag = $TRUE
                        $Script:ForceFinalize = $TRUE
                        Break
                        }else{
                        Finalize $ErrorReturnCode
                        }
            
                    }else{
                    Logging -EventID $WarningEventID -EventType Warning -EventMessage "Specified -Continue[$($Continue)] option, thus continue to process objects."
                    $Script:ContinueFlag = $TRUE

                    #�����t�H���_������̂�$FALSE��Ԃ��ăt�@�C�����������Ȃ�
                    Return $FALSE
                    }

            
            #���ꖼ�̂̃t�@�C���A�t�H���_���ɑ��݂��Ȃ�

            }else{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "File $($CheckLeaf) dose not exist."            
            }

Return $TRUE
}


filter ComplexFilter{

<#
.SYNOPSIS
�@�I�u�W�F�N�g�𕡐������Ńt�B���^�A�K��������̂�����OUTPUT

.DESCRIPTION
$FileType�̎w��Ɋ�Â��A�t�H���_�A�t�@�C���𒊏o
�ŏI�ύX������$Days���Â�
(�t�@�C��|�t�H���_)�������K�\��$RegularExpression�Ƀ}�b�`
�t�@�C���e�ʂ� $Size���傫��
C:\TargetFolder                    :TargetFolder
C:\TargetFolder\A\B\C\target.txt   :TargetObject
��L�̎�\A\B\C\���������K�\��$ParentRegularExpression�Ƀ}�b�`

.INPUT
PSobject

.OUTPUT
PSobject passed the filter

#>
 
    IF (($_.PSIsContainer -eq ($FilterType -eq 'Folder')) -or ( -not($_.PSIsContainer) -eq ($FilterType -eq 'File'))) {
    IF ($_.LastWriteTime -lt (Get-Date).AddDays(-$Days)) {
    IF ($_.Name -match $RegularExpression) {
    IF ($_.Length -ge $Size) {
    IF (($_.FullName).Substring($TargetFolder.Length , (Split-Path -Path $_.FullName -Parent).Length - $TargetFolder.Length +1) -match $ParentRegularExpression)
        {Return $_}
    }
    } 
    }                                                                              
    }
}

 
function GetObjects{

<#
.SYNOPSIS
�@�w��t�H���_����I�u�W�F�N�g�Q�i�t�@�C��|�t�H���_�j�𒊏o

.INPUT
System.String. Path of the folder to get objects

.OUTPUT
Strings Array of Objects's path
#>

Param(
[parameter(mandatory=$TRUE)][String]$TargetFolder
)

    $candidateObjects = Get-ChildItem -LiteralPath $TargetFolder -Recurse:$Recurse -Include * 

    $objects = @()

#�t�B���^��̃I�u�W�F�N�g�Q��z��ɓ����
#�\�[�g�ɔ����ĕK�v�ȏ����z��ɒǉ�
 
    ForEach ($object in ($candidateObjects | ComplexFilter))
          
        {
        $objects += New-Object PSObject -Property @{
            Object = $object
            Time   = $object.LastWriteTime
            Depth  = ($object.FullName.Split("\\")).Count
        }
    }

#�ꕔ��Action��Object�����̏����ŏ������邽�߁A�K�v�ɉ����ă\�[�g����

    Switch -Regex ($Action) {
 
        #KeepFilesCount�z��ɓ��ꂽ�p�X�ꎮ���Â����ɐ���
        '^KeepFilesCount$' {
            Return ($objects | Sort-Object -Property Time | ForEach-Object {$_.Object.FullName})
            }

        #DeleteEmptyFolders�z��ɓ��ꂽ�p�X�ꎮ���p�X���[�����ɐ���B��t�H���_����t�H���_�ɓ���q�ɂȂ��Ă���ꍇ�A�[���K�w����폜����K�v������B
        '^DeleteEmptyFolders$' {
            Return ($objects | Sort-Object -Property Depth -Descending | ForEach-Object {$_.Object.FullName})        
            }


        Default{
            Return ($objects | ForEach-Object {$_.Object.FullName})
            }
    }
}


function Initialize {

$ShellName = Split-Path -Path $PSCommandPath -Leaf

#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�


#Switch����

IF ($NoRecurse) {[Boolean]$Script:Recurse = $FALSE}
IF ($NullOriginalFile) {[String]$Script:PostAction = 'NullClear'}
IF ($ContinueAsNormal) {[Switch]$Script:Continue = $TRUE}

IF ($AddTimeStamp) {$Script:PreAction +='AddTimeStamp'}
IF ($MoveNewFile) {$Script:PreAction +='MoveNewFile'}
IF ($Compress) {$Script:PreAction +='Compress'}

#�p�����[�^�̊m�F


#�w��t�H���_�̗L�����m�F
#CheckContainer function��$TRUE,$FALSE���ߒl�Ȃ̂�$NULL�֎̂Ă�B�̂ĂȂ��ƃR���\�[���o�͂����

    $TargetFolder = ConvertToAbsolutePath -CheckPath $TargetFolder -ObjectName  '-TargetFolder'

    CheckContainer -CheckPath $TargetFolder -ObjectName '-TargetFolder' -IfNoExistFinalize > $NULL


#�ړ���t�H���_�̗v�s�v�ƗL�����m�F

    If ( ($Action -match "^(Move|Copy)$") -or ($PreAction -contains 'MoveNewFile') ) {    

        $MoveToFolder = ConvertToAbsolutePath -CheckPath $MoveToFolder -ObjectName '-MoveToFolder'

        CheckContainer -CheckPath $MoveToFolder -ObjectName '-MoveToFolder' -IfNoExistFinalize > $NULL
 
       
     }elseIF (-not (CheckNullOrEmpty -CheckPath $MoveToFolder)) {
                Logging -EventID $ErrorEventID -EventType Error -EventMessage "Specified -Action [$($Action)] option, must not specifiy -MoveToFolder option."
                Finalize $ErrorReturnCode
                }


#ArchiveFileName�̗v�s�v�ƗL���AValidation

    IF ($PreAction -contains 'Archive') {
        CheckNullOrEmpty -CheckPath $ArchiveFileName -ObjectName '-ArchiveFileName' -IfNullOrEmptyFinalize > $NULL
        
        IF ($ArchiveFileName -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-ArchiveFileName may contain characters that can not use by NTFS."
				Finalize $ErrorReturnCode
                } 
        }


#7z�t�H���_�̗v�s�v�ƗL�����m�F

    If ( $PreAction -match "^(7z|7zZip)$") {    

        $7zFolder = ConvertToAbsolutePath -CheckPath $7zFolder -ObjectName '-7zFolder'

        CheckContainer -CheckPath $7zFolder -ObjectName '-7zFolder' -IfNoExistFinalize > $NULL
        }

#�g�ݍ��킹���s���Ȏw����m�F


    If (($TargetFolder -eq $MoveToFolder) -and (($Action -match "move|copy") -or  ($PreAction -contains 'MoveNewFile'))) {
				Logging -EventType Error -EventID $ErrorEventID -EventMessage "Specified -Action option for Move or Copy files, -TargetFolder and -MoveToFolder must not be same."
				Finalize $ErrorReturnCode
                }

    If (($Action -match "^(Move|Delete|KeepFilesCount)$") -and  ($PostAction -ne 'none')) {

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "Specified -Action option for Delete or Move files, must not specify -PostAction[$($PostAction)] option."
				Finalize $ErrorReturnCode
                }

   If (($PreAction -contains 'MoveNewFile' ) -and (-not($PreAction -match "^(Compress|AddTimeStamp|Archive)$") )) {

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "Secified -PreAction MoveNewFile option, must specify -PreAction Compres or AddTimeStamp or Archive option also. If you move the original files, will specify -Action Move option."
				Finalize $ErrorReturnCode
                }

   If (($PreAction -contains 'Compress') -and  ($PreAction -contains 'Archive')) {

				Logging -EventType Error -EventID $ErrorEventID "Must not specify -PreAction both Compress and Archive options in the same time."
				Finalize $ErrorReturnCode
                }

   If (($PreAction -contains '7z' ) -and  ($PreAction -Contains '7zZip')) {

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "Must not specify -PreAction both 7z and 7zZip options for the archive method in the same time."
				Finalize $ErrorReturnCode
                }

   If (($PreAction -match "^(7z|7zZip)$" ) -and  (-not($PreAction -match "^(Compress|Archive)$"))) {

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "Must not specify -PreAction only 7z or 7zZip option. Must specify -PreAction Compress or Archive option with them."
				Finalize $ErrorReturnCode
                }

   IF ($Action -eq "DeleteEmptyFolders") {
        IF ( ($PreAction -match '^(Compress|Archive|AddTimeStamp)$') -or ($PostAction -ne 'none' )) {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "Specified -Action [$Action] , must not specify -PreAction or -PostAction options for modify files."
				Finalize $ErrorReturnCode

        }elseIF ($Size -ne 0) {
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "Specified -Action [$Action] , must not specify -size option."
				Finalize $ErrorReturnCode
                }
    }


    IF ($TimeStampFormat -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-TimeStampFormat  may contain characters that can not use by NTFS."
				Finalize $ErrorReturnCode
                }



#�����J�n���b�Z�[�W�o��


Logging -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

    IF ($Action -eq "DeleteEmptyFolders") {

        Logging -EventID $InfoEventID -EventType Information -EventMessage "Delete empty folders [in target folder $($TargetFolder)][older than $($Days)days][match to regular expression [$($RegularExpression)]][recursively[$($Recurse)]]"
        
        }else{

        Logging -EventID $InfoEventID -EventType Information -EventMessage ("Files [in the folder $($TargetFolder)][older than $($Days)days][match to regular expression [$($RegularExpression)]][parent path match to regular expression [$($ParentRegularExpression)]][size is over"+($Size / 1KB)+"KB]")

        IF ($PreAction -notcontains 'none') {

            $message = "Process files matched "
            IF ($PreAction -contains 'MoveNewFile') { $message += "to move to [$($MoveToFolder)] "}

            IF ($PreAction -match "^(Compress|Archive)$") {
                
                #$PreAction�͔z��Ȃ̂�Switch�ŏ�������ƕ�������s�����̂ŁAIF�ŏ���
                IF ($PreAction -contains '7z') {
                        $message += "with compress method [7z] "            
                        }elseIF ($PreAction -contains '7zZIP') {
                            $message += "with compress method [7zZip] "
                            }else{
                            $message += "with compress method [Powershell cmdlet Compress-Archive] "
                            }
                               
            }
            
            $message += "recursively [$($Recurse)] PreAction(Add time stamp to filename["+[Boolean]($PreAction -contains 'AddTimeStamp')+"] | Compress["+[Boolean]($PreAction -contains 'Compress')+"] | Archive to 1file["+[Boolean]($PreAction -contains 'Archive')+"] )"

            Logging -EventID $InfoEventID -EventType Information -EventMessage $message
            }



        IF ($Action -ne 'none') {

            $message = "Process files matched "
            IF ($Action -eq 'KeepFilesCount') { $message += "[keep file generation only($($KeepFiles))] "}
            IF ($Action -match '^(Copy|Move)$') { $message += "moving to[$($MoveToFolder)] "}
            $message += "recursively[$($Recurse)] Action[$($Action)]"

            Logging -EventID $InfoEventID -EventType Information -EventMessage $message
            }

        IF ($PostAction -ne 'none') {

            $message = "Process files matched"
            IF ($PostAction -eq 'Rename') { $message += "rename with rule[$($RenameToRegularExpression)] "}
            $message += "recursively[$($Recurse)] PostAction[$($PostAction)]"

            Logging -EventID $InfoEventID -EventType Information -EventMessage $message
            }
    }

    IF ($NoAction) {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -NoAction[$($NoAction)] option, thus do not process files or folders."
        }

    IF ($OverRide) {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -OverRide[$($OverRide)] option, thus if files exist with the same name, will override them."
        }

    If ($ContinueAsNormal) {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -ContinueAsNormal[$($ContinueAsNormal)] option, thus if file exist in the same name already, will process next file as NORMAL without termination."
        
        }elseIF ($Continue) {
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -Continue[$($Continue)] option, thus if a file exist in the same name already, will process next file as WARNING without termination."
            }

}


#���k�t���O�܂��̓^�C���X�^���v�t���t���O��True�̏���

function CompressAndAddTimeStamp {

Param(
[parameter(mandatory=$TRUE)][String]$TargetObject
) 

    [String]$targetFileParentFolder = Split-Path -Path $TargetObject -Parent

#���k�t���OTrue�̎�

    IF ($PreAction -match '^(Compress)$') {

        #$PreAction�͔z��ł���B�����Switch���������1�v�f�Â��[�v����B
        #'Compress'���͈�UDefault�ɗ����邪�A'7z' or '7zZip'�������$ActionType�͏㏑�������

        Switch -Regex ($PreAction) {    
        
          '^7z$' {
                $Script:ActionType = "7z"
                $extString = '.7z'
                Break                
                }
                
           '^7zZip$' {
                $Script:ActionType = "7zZip"
                $extString = '.zip'
                Break
                }
                    
             Default {
                $Script:ActionType = ""
                $extString = $CompressedExtString
                }    
        }
                        
        IF ($PreAction -contains 'AddTimeStamp') {

                $archiveFile = Join-Path -Path $targetFileParentFolder -ChildPath ((AddTimeStampToFileName -TargetFileName (Split-Path $TargetObject -Leaf )  -TimeStampFormat $TimeStampFormat )+$extString )
                $Script:ActionType += "CompressAndAddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "Create new file [$(Split-Path -Path $archiveFile -Leaf)] compressed and added time stamp."

                }else{
                $archiveFile = $TargetObject+$extString
                $Script:ActionType += "Compress"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "Create new file [$(Split-Path -Path $archiveFile -Leaf)] compressed." 
                }          
 
    }else{

#�^�C���X�^���v�t���̂�True�̎�

                $archiveFile = Join-Path -Path $targetFileParentFolder -ChildPath (AddTimeStampToFileName -TargetFileName (Split-Path -Path $TargetObject -Leaf )  -TimeStampFormat $TimeStampFormat )
                $Script:ActionType = "AddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "Create new file [$(Split-Path -Path $archiveFile -Leaf)] added time stamp."
                }


#�ړ��t���O��True�Ȃ�΁A�쐬�������kor�^�C���X�^���v�t�������t�@�C�����ړ�����

    IF ($PreAction -contains 'MoveNewFile') {

        Logging -EventID $InfoEventID -EventType Information -EventMessage ("Specified -PreAction MoveNewFile["+[Boolean]($PreAction -contains 'MoveNewFile')+"] option, thus place the new file in the folder $($MoveToNewFolder)")
        Return ( Join-Path -Path $MoveToNewFolder -ChildPath (Split-Path -Path $archiveFile -Leaf) )

        }else{
        Return $archiveFile
        }

}


function Finalize{

Param(
[parameter(mandatory=$TRUE)][Int]$ReturnCode
)
    $ForceFinalize = $FALSE
 
    IF ( ($NormalCount + $WarningCount + $ErrorCount) -ne 0 ) {    

       Logging -EventID $InfoEventID -EventType Information -EventMessage "The results of execution NORMAL[$($NormalCount)] WARNING[$($WarningCount)] ERROR[$($ErrorCount)]"


        IF ($OverRide -and ($OverRideCount -gt 0)) {
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -OverRide[$($OverRide)] option, thus overrided old files with new files created in the same name in [$($OverRideCount)] times."
            }

        IF (($Continue) -and ($ContinueCount -gt 0)) {
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -Continue [$($Continue)] option, thus continued to process next objects in [$($ContinueCount)] times even though error occured with the same name file/folders existed already."
            }
    }

EndingProcess $ReturnCode
}






#####################   ��������{��  ######################

[Boolean]$ErrorFlag = $FALSE
[Boolean]$WarningFlag = $FALSE
[Boolean]$NormalFlag = $FALSE
[Boolean]$OverRideFlag = $FALSE
[Boolean]$ContinueFlag = $FALSE
[Boolean]$ForceFinalize = $FALSE          ;#$TRUE�ŃI�u�W�F�N�g�������[�v�������I���B
[Boolean]$ForceEndloop = $FALSE           ;#$FALSE�ł�Finalize , $TRUE�ł̓��[�v����Break
[Int][ValidateRange(0,2147483647)]$ErrorCount = 0
[Int][ValidateRange(0,2147483647)]$WarningCount = 0
[Int][ValidateRange(0,2147483647)]$NormalCount = 0
[Int][ValidateRange(0,2147483647)]$OverRideCount = 0
[Int][ValidateRange(0,2147483647)]$ContinueCount = 0
[Int][ValidateRange(0,2147483647)]$InLoopDeletedFilesCount = 0

$DatumPath = $PSScriptRoot

$Version = '20200305_1030'


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize


#�Ώۂ̃t�H���_�܂��̓t�@�C����T���Ĕz��ɓ����


    IF ($Action -eq "DeleteEmptyFolders") {

        $FilterType = "Folder"

        }else{
        $FilterType = "File"
        }

$TargetObjects = @()

$TargetObjects = GetObjects -TargetFolder $TargetFolder

    If ($NULL -eq $TargetObjects) {

        Logging -EventID $InfoEventID -EventType Information -EventMessage "In -TargetFolder [$($TargetFolder)] no [$($FilterType)] exists for processing."

        IF ($NoneTargetAsWarning) {
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "Specified -NoneTargetAsWarning option, thus terminiate $($ShellName) with WARNING."
            Finalize $WarningReturnCode

            }else{
            Finalize $NormalReturnCode
            }
    }

Logging -EventID $InfoEventID -EventType Information -EventMessage "[$($TargetObjects.Length)] [$($FilterType)(s)] exist for processing."

Write-Output "[$($FilterType)(s)] are for processing..."

Write-Output $TargetObjects
    �@
#-PreAction Archive�͕����t�@�C����1�t�@�C���Ɉ��k����B����āA���[�v�O�Ɉ��k���1�t�@�C���̃t���p�X���m�肵�Ă���

IF ($PreAction -contains 'Archive') {

    IF ($PreAction -contains 'MoveNewFile') {
        
        $archiveToFolder = $MoveToFolder
        }else{
        $archiveToFolder = $TargetFolder
        }

    IF ($PreAction -contains 'AddTimeStamp') {  

        $archivePath = Join-Path -Path $archiveToFolder -ChildPath ( AddTimeStampToFileName -TimeStampFormat $TimeStampFormat -TargetFileName $archiveFileName )
        }else{
        $archivePath = Join-Path -Path $archiveToFolder -ChildPath $archiveFileName
        }

    $archivePath = ConvertToAbsolutePath -CheckPath $archivePath -ObjectName "ArchiveFile output path"

    IF (-not(CheckLeafNotExists $ArchivePath)) {
        
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "File/Folder exists in the path [$($archivePath)] already, thus terminate $($ShellName) with ERROR"
        Finalize $ErrorReturnCode        
        }

}


#�Ώۃt�H���_or�t�@�C���Q�̏������[�v

ForEach ($TargetObject in $TargetObjects)
{
<#
Powershell��GOTO�������݂����������򂪂ł��Ȃ��B
���̂���Do/While��p���ď����r���ŃG���[�����������ꍇ�̕�����������Ă���

Do/While()�͍Ō�ɕ]�����s���郋�[�v�B�Ō�̕]����False�ƂȂ�ƃ��[�v���I������B������While($FALSE)�Ƃ��Ă���̂ŁA
Do/While�̊Ԃ�1�񂾂����s�����B
Do/While�̓��[�v�̂��߁A�����r����Break����ƁAWhile��jump����B

�t�@�C���Q�������[�v���̃G���[�i�Ⴆ�΁A�t�@�C����Delete���s�������A�����������č폜�ł��Ȃ����j�őz�肳��鏈���A�w����@�͈ȉ��ł���B

1.While�ȍ~�̏����I�����b�Z�[�W�o�͂�Jump���āA���̃t�@�C���������p��
 Break , $ForceEndloog = $TRUE , $ForceFinalize = $FALSE 
2.While�ȍ~�̏����I�����b�Z�[�W�o�͂�Jump���āA���̃t�@�C���͏���������Finalize�֐i�ށi�����ł��؂�j
 Break , $ForceEndloog = $TRUE , $ForceFinalize = $TRUE
3.�����I�����b�Z�[�W�o�͂��Ȃ��BFinalize�֐i�ށi�����ł��؂�j
 Finalize $ErrorReturnCode
#>
Do
{
    [Boolean]$ErrorFlag = $FALSE
    [Boolean]$WarningFlag = $FALSE
    [Boolean]$NormalFlag = $FALSE
    [Boolean]$OverRideFlag = $FALSE
    [Boolean]$ContinueFlag = $FALSE
    [Boolean]$ForceEndloop = $TRUE   ;#���̃��[�v���ňُ�I�����鎞�̓��[�v�I�[��Break���āA�������ʂ�\������B������Finalize���Ȃ�
    [Int]$InLoopOverRideCount = 0    ;#$OverRideCount�͏����S�̂�OverRide�񐔁B$InLoopOverRideCount��1�������[�v���ł�OverRide�񐔁B1�I�u�W�F�N�g�ŕ�����OverRide�����蓾�邽��

    [String]$TargetFileParentFolder = Split-Path -Path $TargetObject -Parent

    Logging -EventID $InfoLoopStartEventID -EventType Information -EventMessage "--- Start processing [$($FilterType)] $($TargetObject) ---"


#�ړ����̃t�@�C���p�X����ړ���̃t�@�C���p�X�𐶐��B
#�ċA�I�łȂ���΁A�ړ���p�X�͊m���ɑ��݂���̂ŃX�L�b�v

#Action[(Move|Copy)]�ȊO�̓t�@�C���ړ��������B�ړ���p�X���m�F����K�v���Ȃ��̂ŃX�L�b�v
#PreAction[Archive]��MoveNewFile[TRUE]�ł��o�̓t�@�C����1�ŊK�w�\�������Ȃ��B����ăX�L�b�v

    If ( (($Action -match "^(Move|Copy)$")) -or (($PreAction -contains 'MoveNewFile') -and ($PreAction -notcontains 'Archive')) ) {

        #�t�@�C�����ړ�����Action�p�Ƀt�@�C���ړ���̐e�t�H���_�p�X$MoveToNewFolder�𐶐�����
        
        #C:\TargetFolder                    :TargetFolder
        #C:\TargetFolder\A\B\C              :TargetFileParentFolder
        #C:\TargetFolder\A\B\C\target.txt   :TargetFile
        #D:\MoveToFolder                    :MoveToFolder
        #D:\MoveToFolder\A\B\C              :MoveToNewFolder

        #D:\MoveToFolder\A\B\C\target.txt   :�t�@�C���̈ړ���p�X

        #MoveToNewFolder�����ɂ� \A\B\C\�@�̕��������o���āA�ړ���t�H���_MoveToFolder��Join-Path����
        #String.Substring���\�b�h�͕����񂩂�A�����ʒu����Ō�܂ł����o��
        #MoveToNewFolder��NoRecurse�ł�Move|Copy�ňꗥ�g�p����̂ō쐬

        $MoveToNewFolder = Join-Path -Path $MoveToFolder -ChildPath ($TargetFileParentFolder).Substring($TargetFolder.Length)
        If ($Recurse) {

            If (-not(CheckContainer -CheckPath $MoveToNewFolder -ObjectName 'Moving the file to, Folder ')) {

                Logging -EventID $InfoEventID -EventType Information -EventMessage "Create a new folder $($MoveToNewFolder)"

                TryAction -ActionType MakeNewFolder -ActionFrom $MoveToNewFolder -ActionError $MoveToNewFolder

                #$TryAction���ُ�I��&-Continue $TRUE����$ContinueFlag $TRUE�ɂȂ�̂ŁA���̏ꍇ�͌㑱�����͂��Ȃ��Ŏ���Object�����ɐi��
                IF ($ContinueFlag) {
                    Break                
                    }
            }
        }
    }


#Pre Action

    IF (( $PreAction -match '^(Compress|AddTimeStamp)$') -and ($PreAction -notcontains 'Archive')) {

        $archivePath = CompressAndAddTimeStamp -TargetObject $TargetObject

        IF (CheckLeafNotExists $archivePath) {

            TryAction -ActionType $ActionType -ActionFrom $TargetObject -ActionTo $archivePath -ActionError $TargetObject
            }

        
        }elseIF ($PreAction -contains 'Archive') {

            Switch -Regex ($PreAction) {        
        
                '^7z$' {
                    $actionType = "7zArchive"
                    Break
                    }
                
                '^7zZip$' {
                    $actionType = "7zZipArchive"
                    Break
                    }
                    
                Default {
                    $actionType = "Archive"
                    }       
            }        
       
        TryAction -ActionType $actionType -ActionFrom $TargetObject -ActionTo $archivePath -ActionError $TargetObject
        }


#Main Action

    Switch -Regex ($Action) {

    #����1 �������Ȃ�
    '^none$' {
            IF ( ($PostAction -eq 'none') -and ($PreAction -contains 'none') ) {

                Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -Action [$($Action)] option, thus do not process $($TargetObject)"
                }
            }

    #����2 �폜
    '^Delete$' {
            TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject
            } 

    #����3 �ړ� or ���� �@����̃t�@�C�����i�ړ�|������j�ɑ��݂��Ȃ����Ƃ��m�F���Ă��珈��
    '^(Move|Copy)$' {
            $targetFileMoveToPath = Join-Path -Path $MoveToNewFolder -ChildPath (Split-Path -Path $TargetObject -Leaf)

            IF (CheckLeafNotExists $targetFileMoveToPath) {

                TryAction -ActionType $Action -ActionFrom $TargetObject -ActionTo $targetFileMoveToPath -ActionError $TargetObject
                }           
            }

    #����4 ��t�H���_�𔻒肵�č폜
    '^DeleteEmptyFolders$' {
            Logging -EventID $InfoEventID -EventType Information -EventMessage  "Check the folder $($TargetObject) is empty."

            IF ((Get-Item -LiteralPath $TargetObject).GetFileSystemInfos().Count -eq 0) {

                Logging -EventID $InfoEventID -EventType Information -EventMessage  "The folder $($TargetObject) is empty."
                TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject

                }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage "The folder $($TargetObject) is not empty." 
                }
            }


    #����5 NullClear
    '^NullClear$' {
            TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject          
            }

    #����6 KeepFilesCount
    '^KeepFilesCount$' {
            IF (($TargetObjects.Length - $InLoopDeletedFilesCount) -gt $KeepFiles) {
                Logging -EventID $InfoEventID -EventType Information -EventMessage  "In the folder more than [$($KeepFiles)] files exist, thus delete the oldest [$($TargetObject)]"
                TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject

                #$TryAction���ُ�I��&-Continue $TRUE����$ContinueFlag $TRUE�ɂȂ�̂ŁA���̏ꍇ�͌㑱�����͂��Ȃ��Ŏ���Object�����ɐi��
                IF ($ContinueFlag) {
                    Break                
                    }
                $InLoopDeletedFilesCount++
            
            }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage  "Tn the foler less [$($KeepFiles)] files exist, thus do not delete [$($TargetObject)]"
                }
            }

    #����7 $Action���������̂ǂꂩ�ɓK�����Ȃ��ꍇ�́A�v���O�����~�X
    Default {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error at Switch Action section. It may cause a bug in regex."
            Finalize $InternalErrorReturnCode
            }
    }


#Post Action

    Switch -Regex ($PostAction) {

    #����1 �������Ȃ�
    '^none$' {            
            }

    #����2 Rename Rename��̓��ꖼ�̃t�@�C�����ɑ��݂��Ȃ����Ƃ��m�F���Ă��珈��
    '^Rename$' {
            $newFilePath = Join-Path -Path $TargetFileParentFolder -ChildPath  ((Split-Path -Path $TargetObject -Leaf) -replace "$RegularExpression" , "$RenameToRegularExpression")

            $newFilePath = ConvertToAbsolutePath -CheckPath $newFilePath -ObjectName 'Filename renamed'

                    IF (CheckLeafNotExists $newFilePath) {

                        TryAction -ActionType Rename -ActionFrom $TargetObject -ActionTo $newFilePath -ActionError $TargetObject
                        }else{
                        Logging -EventID $InfoEventID -EventType Information -EventMessage  "A file [$($newFilePath)] already exists same as attempting rename, thus do not rename [$($TargetObject)]"
                        }
            }

    #����3 NullClear
    '^NullClear$' {
            TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject          
            }


    #����4 $Action���������̂ǂꂩ�ɓK�����Ȃ��ꍇ�́A�v���O�����~�X
    Default {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal error at Switch PostAction section. It may cause a bug in regex."
            Finalize $InternalErrorReturnCode
            }
    }



#�ُ�I���Ȃǂ�Break���ăt�@�C�������I�[�֔�����B
}
While($FALSE)


#�ُ�A�x�����m�F�B�ُ�>�x��>����̏��ʂŎ��s���ʐ��J�E���g�A�b�v

    IF ($ErrorFlag) {
        $ErrorCount++
        }elseIF ($WarningFlag) {
            $WarningCount++
            }elseIF ($NormalFlag) {
                $NormalCount++
                }

    IF ($ContinueFlag) {
        $ContinueCount++
        }
         
    Logging -EventID $InfoLoopEndEventID -EventType Information -EventMessage "--- End processing [$($FilterType)] $($TargetObject)  Results  Normal[$($NormalFlag)] Warning[$($WarningFlag)] Error[$($ErrorFlag)]  Continue[$($ContinueFlag)]  OverRide[$($InLoopOverRideCount)] ---"

    IF ($ForceFinalize) {    
        Finalize $ErrorReturnCode
        }

#�ΏیQ�̏������[�v�I�[
   
}


#�I�����b�Z�[�W�o��

Finalize $NormalReturnCode

