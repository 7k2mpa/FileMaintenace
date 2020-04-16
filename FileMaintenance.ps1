#Requires -Version 5.0
#If you do not use '-PreAction compress or archive', install WMF 3.0 and place '#Requires -Version 3.0' insted of '#Requires -Version 5.0'
#If you use '-PreAction compress or archive' with 7z, install WMF 3.0 and place '#Requires -Version 3.0' insted of '#Requires -Version 5.0'

<#
.SYNOPSIS
This script processes log files or temp files to delete, move, archive, etc.... with multiple methods.
CommonFunctions.ps1 is required.
You can process files in multiple folders with Wrapper.ps1


���O�t�@�C�����k�A�폜���n�߂Ƃ����F�X�ȏ��������閜�\�c�[���ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B
�Z�b�g�ŊJ�����Ă���Wrapper.ps1�ƕ��p����ƕ����������ꊇ���s�ł��܂��B


.DESCRIPTION
This script filters files and folders with multiple criteria.
And process the files and folders filtered in multiple methods with PreAction, Action and PostAction.

Methods are

-PreAction:
Create new files from filtered files. Methods [Add time stamp to file name][Compress][Archive to 1file][Move the file created to new location]
are offered and can be used together.
Without specification -MoveNewFile option, place the file created in the same folder of the original file.

-Action:
Process files filtered to [Move][Copy][Delete][NullClear][KeepFilesCount] , folders filtered to [DeleteEmptyFolders]

-PostAction:
Process files filtered to [NullClear][Rename]


Filtering criteria are [(Older than)-Days][-Size][-RegularExpression][-Parent(Path)RegularExpression]

This script processes only 1 folder at once.
If you process multiple folders, can do with Wrapper.ps1

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 

This scrpit requires Powershell 5.0 or later basically.

If the script run on Windows Server 2008, 2008R2, 2012 and 2012R2, install WMF(Windows Management Framework)5.0.
If you do not use '-PreAction compress or archive', install WMF 3.0 and place '#Requires -Version 3.0' insted of '#Requires -Version 5.0' at top of the script.
If you use '-PreAction compress or archive' with 7z, install WMF 3.0 and place '#Requires -Version 3.0' insted of '#Requires -Version 5.0' at top of the script.

https://docs.microsoft.com/ja-jp/powershell/scripting/install/installing-windows-powershell?view=powershell-7#upgrading-existing-windows-powershell



�Ώۂ̃t�H���_�Ɋ܂܂��A�t�@�C���A�t�H���_���e������Ńt�B���^���đI�����܂��B
�t�B���^���ʂ��p�����[�^�Ɋ�Â��A�O�����A�又���A�㏈�����܂��B

�t�B���^���ʂɑ΂��ĉ\�ȏ����͈ȉ��ł��B

-�O����:�Ώۃt�@�C������ʃt�@�C���𐶐����܂��B�\�ȏ����́u�t�@�C�����Ƀ^�C���X�^���v�t���v�u���k�v�u���������ʃt�@�C���̈ړ��v�u�����̃t�@�C����1�t�@�C���ɃA�[�J�C�u�v�ł��B
���p�w��\�ł��B�u���������ʃt�@�C���̈ړ��v���w�肵�Ȃ��ƑΏۃt�@�C���Ɠ���t�H���_�ɔz�u���܂��B
-�又��:�Ώۃt�@�C�����u�ړ��v�u�����v�u�폜�v�u���e�����i�k���N���A�j�v�A�t�H���_���u��t�H���_�폜�v���܂��B
-�㏈��:�Ώۃt�@�C�����u���e�����i�k���N���A�j�v�u���̕ύX�v���܂��B

�t�B���^�́u�o�ߓ����v�u�e�ʁv�u���K�\���v�u�Ώۃt�@�C���A�t�H���_�̐e�p�X�Ɋ܂܂�镶���̐��K�\���v�Ŏw��ł��܂��B

���̃v���O�����P�̂ł́A1�x�ɏ����ł���̂�1�t�H���_�ł��B�����t�H���_�������������ꍇ�́AWrapper.ps1�𕹗p���Ă��������B


���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B

���̃v���O������PowerShell 5.0�ȍ~���K�v�ł��B
Windows Server 2008,2008R2��WMF(Windows Management Framework)5.0�ȍ~��ǉ��C���X�g�[�����Ă��������B����ȑO��OS�ł͉ғ����܂���B

https://docs.microsoft.com/ja-jp/powershell/scripting/install/installing-windows-powershell?view=powershell-7#upgrading-existing-windows-powershell


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -noLog2Console -verbose

Find files in C:\TEST and child folders recuresively.
All logs are not output at console.
You would confirm getting files to process. 

C:\TEST�ȉ��̃t�@�C�����ċA�I�Ɍ����������܂��i�q�t�H���_���Ώہj
��Ƃׂ̍������e���R���\�[���ɕ\�����܂���B
�悸�̓����e�i���X�Ώۂ̂��̂��\������邩�m�F���Ă݂ĉ������B


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete

Delete files in C:\TEST and child folders recuresively.

C:\TEST�ȉ��̃t�@�C�����ċA�I�ɍ폜���܂��i�q�t�H���_���Ώہj

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action DeleteEmptyFolders

Delete empty folders in C:\TEST and child folders recuresively.

C:\TEST�ȉ��̋�t�H���_���ċA�I�ɍ폜���܂��i�q�t�H���_���Ώہj

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete -noRecurse

Delete files only in C:\TEST non-recuresively.

C:\TEST�ȉ��̃t�@�C�����ċA�I�ɍ폜���܂��i�q�t�H���_�͑ΏۊO�j

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Copy -MoveToFolder C:\TEST1 -Size 10KB -continue

Copy files over than 10KByte to C:\TEST1 recuresively.
If no child foler in the desitination, make the new folder.
If same name file be in the destination, skip copying and continue process a next object.

C:\TEST�ȉ��̃t�@�C����10KB�ȏ�̂��̂��ċA�I��C:\TEST1�֕������܂��B�ړ���Ɏq�t�H���_��������΍쐬���܂�
�ړ���ɓ��ꖼ�̂̃t�@�C�����������ꍇ�̓X�L�b�v���ď������p�����܂�

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,AddTimeStamp -Action NullClear

Filter files ending with '.log' and older 10days in C:\TEST recuresively.
Create new files compressed and added time stamp to file name from files filtered.
New files place in the same folder.
The filtered files dose not be deleted, but are null cleared.

C:\TEST�ȉ��̃t�@�C�����ċA�I�� �u.log�ŏI���v���̂փt�@�C�����ɓ��t��t�����Ĉ��k���܂��B
���t�@�C���͎c��܂����A���e�����i�k���N���A�j���܂��B

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,MoveNewFile -Action Delete -MoveToFolder C:\TEST1 -OverRide -Days 10

Filter files ending with '.log' and older 10days in C:\TEST recuresively.
Create new files compressed and move to C:\TEST1
If same name file exists in the destination, override old one.
The original files are deleted. 

C:\TEST�ȉ��̃t�@�C�����ċA�I�� �u.log�ŏI���v����10���ȑO�̂��̂����k��C:\TEST1�ֈړ����܂��B
�ړ���ɓ��ꖼ�̂̂��̂��������ꍇ�͏㏑�����܂��B
���̃t�@�C���͍폜���܂�


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\OLD\Log -RegularExpression '^.*\.log$' -Action Delete -ParentRegularExpression '\\OLD\\'

Filter files ending with '.log' recuresively.
-ParentRegularExpresssion option is specified with regular expression, thus path's backslash\ is escaped with backslash\
Delete them with '\OLD\' in the rest of the path characters next to the -TargetFolder(C:\OLD\Log).
At the sample blow, 'C:\OLD\Los' is not for -ParentRegularExpression matching.
Thus 'C:\OLD\Log\IIS\Current\Infra.log' , 'C:\OLD\Log\Java\Current\Infra.log' and 'C:\OLD\Log\Infra.log' are not deleted.

C:\OLD\Log\IIS\Current\Infra.log
C:\OLD\Log\IIS\OLD\Infra.log
C:\OLD\Log\Java\Current\Infra.log
C:\OLD\Log\Java\OLD\Infra.log
C:\OLD\Log\Infra.log


C:\OLD\Log�ȉ��̃t�@�C���ōċA�I�Ɂu.log�ŏI���v���̂��폜���܂��B
�A���A�t�@�C���̃t���p�X����C:\OLD\Log���폜�����p�X�Ɂu\OLD\�v���܂܂��t�@�C���������ΏۂɂȂ�܂��B���K�\���̂��߁A�p�X�Ɋ܂܂��\�i�o�b�N�X���b�V���j��\�i�o�b�N�X���b�V���j�ŃG�X�P�[�v����Ă��܂��B
�Ⴆ�Έȉ��̃t�@�C���z�u�ł�C:\OLD\Log�܂ł̓}�b�`�ΏۊO�ƂȂ�C:\OLD\Log\IIS\Current\Infra.log , C:\OLD\Log\Java\Current\Infra.log , C:\OLD\Log\Infra.log�͍폜����܂���B

C:\OLD\Log\IIS\Current\Infra.log
C:\OLD\Log\IIS\OLD\Infra.log
C:\OLD\Log\Java\Current\Infra.log
C:\OLD\Log\Java\OLD\Infra.log
C:\OLD\Log\Infra.log

 
.PARAMETER TargetFolder
Specify a folder of the target files or the folders placed.
Specification is required.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


�����Ώۂ̃t�@�C���A�t�H���_���i�[����Ă���t�H���_���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���΃p�X�\�L�́A.����n�߂�\�L�ɂ��ĉ������B�i�� .\Log , ..\Script\log�j
���C���h�J�[�h* ? []�͎g�p�ł��܂���B
�t�H���_���Ɋ��� [ , ] ���܂ޏꍇ�̓G�X�P�[�v�����ɂ��̂܂ܓ��͂��Ă��������B

.PARAMETER PreAction

Specify methods to process files.
-PreAction option accept multiple arguments.
Separate arguments with comma,

None:Do nothing, and is default. If you want to test the action, specify -WhatIf or -Confirm option.
Compress:Create compressed files from the original files.
AddTimeStamp:Create new files with file name added time stamp.
Archive:Create an archive file from files. Specify archive file name with -ArchiveFileName option.
MoveNewFile:place new files in -MoveNewFolder path.
7z:Specify to use 7-Zip and make .7z(LZMA2) for compress or archive option.
7zZip:Specify to use 7-Zip and make .zip(Deflate) for compress or arvhice option.

�����Ώۂ̃t�@�C���ɑ΂��鑀���ݒ肵�܂��B�ȉ��̃p�����[�^���w�肵�ĉ������B
PreAction��(Action|PostAction)�ƈقȂ蕡���p�����[�^���w��ł��܂��B
�p�����[�^�̓J���},�ŋ�؂��ĉ������B

None:������������܂���B���̐ݒ肪�f�t�H���g�ł��B����͌둀��h�~�̂��߂ɂ���܂��B���쌟�؂ɂ�-WhatIf�X�C�b�`�𗘗p���ĉ������B
Compress:�Ώۃt�@�C�����爳�k�����t�@�C����V�K�������܂��B
AddTimeStamp:�Ώۃt�@�C������t�@�C������-TimeStampFormat�Œ�߂�ꂽ�����Ń^�C���X�^���v�t�������t�@�C����V�K�������܂��B
Archive:�Ώۃt�@�C���Q���܂Ƃ߂�1�A�[�J�C�u�t�@�C����V�K�������܂��B-OverRide���w�肷��ƁA�����A�[�J�C�u�t�@�C���֑Ώۃt�@�C���Q��ǉ����܂��B�A�[�J�C�u�t�@�C����-ArchiveFileName�Ŏw�肵���t�@�C�����ł��B
MoveNewFile:-PreAction�̐V�K�����t�@�C����-TargetFolder�Ɠ���ł͂Ȃ��A-MoveToFolder�֔z�u���܂��B
7z:Compress,Archive�Ɏg�p���鈳�k��7z.exe��p���܂��B���k���@��7z.exe�̕W��LZMA2��p���܂��B
7zZip:Compress,Archive�Ɏg�p���鈳�k��7z.exe��p���܂��B���k���@��Zip(Deflate)��p���܂��B

.PARAMETER Action

Specify method to process files.

None:Do nothing, and is default. If you want to test the action, specify -WhatIf or -Confirm option.
Move:Move the files to -MoveNewFolder path.
Delete:Delete the files.
Copy:Copy the files and place in -MoveNewFolder path.
DeleteEmptyFolders:Delete empty folders.
KeepFilesCount:Delete old generation files.
NullClear:Clear the files with null.

�����Ώۂ̃t�@�C���ɑ΂��鑀���ݒ肵�܂��B�ȉ��̃p�����[�^���w�肵�ĉ������B

None:������������܂���B���̐ݒ肪�f�t�H���g�ł��B����͌둀��h�~�̂��߂ɂ���܂��B���쌟�؂ɂ�-WhatIf�X�C�b�`�𗘗p���ĉ������B
Move:�t�@�C����-MoveToFolder�ֈړ����܂��B
Delete:�t�@�C�����폜���܂��B
Copy:�t�@�C����-MoveToFolder�ɃR�s�[���܂��B
DeleteEmptyFolders:��t�H���_���폜���܂��B
KeepFilesCount:�w�萢�㐔�ɂȂ�܂ŁA�}�b�`�����t�@�C���Q���Â����ɍ폜���܂��B
NullClear:�t�@�C���̓��e�폜 NullClear���܂��B

.PARAMETER PostAction

Specify method to process files.

None:Do nothing, and is default. If you want to test the action, specify -WhatIf or -Confirm option.
Rename:Rename the files with -RenameToRegularExpression
NullClear:Clear the files with null.


�����Ώۂ̃t�@�C���ɑ΂��鑀���ݒ肵�܂��B�ȉ��̃p�����[�^���w�肵�ĉ������B

None:������������܂���B���̐ݒ肪�f�t�H���g�ł��B����͌둀��h�~�̂��߂ɂ���܂��B���쌟�؂ɂ�-WhatIf�X�C�b�`�𗘗p���ĉ������B
Rename:�t�@�C�����𐳋K�\��-RenameToRegularExpression�Œu�����܂��B
NullClear:�t�@�C���̓��e�폜 NullClear���܂��BPostAction�̂��߁AAction�ƕ��p�\�ł��B�Ⴆ�΃t�@�C��������A���t�@�C�����폜����A�Ƃ������p�r�Ɏg�p���ĉ������B


.PARAMETER MoveToFolder

Specify a desitination folder of the target files moved to.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


�@�����Ώۂ̃t�@�C���̈ړ��A�R�s�[��t�H���_���w�肵�܂��B
���΁A��΃p�X�Ŏw��\�ł��B
���΃p�X�\�L�́A.����n�߂�\�L�ɂ��ĉ������B�i�� .\Log , ..\Script\log�j
���C���h�J�[�h* ? []�͎g�p�ł��܂���B
�t�H���_���Ɋ��� [ , ] ���܂ޏꍇ�̓G�X�P�[�v�����ɂ��̂܂ܓ��͂��Ă��������B

.PARAMETER ArchiveFileName

Specify the file name of the archive file with -PreAction Archive option.
Specify it without extension.
Extension strings will be added automatically with archive method.

-PreAction Archive�w�莞�̃A�[�J�C�u�t�@�C�������w�肵�܂��B


.PARAMETER 7zFolder 

Specify a folder of 7-Zip installed.
[C:\Program Files\7-Zip] is default.

Compress,Archive�ɊO���v���O����7z.exe���g�p����ۂɁA7-Zip���C���X�g�[������Ă���t�H���_���w�肵�܂��B
�f�t�H���g��[C:\Program Files\7-Zip]�ł��B

.PARAMETER Days
Specify how many days older than today to process files.
0 day is default and, process all files.

�@�����Ώۂ̃t�@�C���A�t�H���_���X�V�o�ߓ����Ńt�B���^���܂��B
�f�t�H���g��0���őS�Ẵt�@�C�����ΏۂƂȂ�܂��B

.PARAMETER Size

Specify size of files to process.
0 byte is default, and process all files.
Units of KB,MB,GB are accepted.

�@�����Ώۂ̃t�@�C����e�ʂŃt�B���^���܂��B
�f�t�H���g��0KB�őS�Ẵt�@�C�����ΏۂƂȂ�܂��B
�����\�L�ɉ����āAKB,MB,GB�̐ڔ��������p�\�ł��B
�Ⴆ��-Size 10MB�́A�����I��10*1024^6�Ɋ��Z���Ă���܂��B

.PARAMETER RegularExpression

Specify regular expression to match processing files.
'.*' is default, and process all files.

�@�����Ώۂ̃t�@�C���A�t�H���_�𐳋K�\���Ńt�B���^���܂��B
�f�t�H���g�� .* �őS�Ă��ΏۂƂȂ�܂��B
�L�q�̓V���O���N�I�[�e�[�V�����Ŋ����ĉ������B
PowerShell�̎d�l��A�啶���������̋�ʂ͂��Ȃ����ł����A���ۂɂ͋�ʂ����̂Œ��ӂ��ĉ������B

.PARAMETER ParentRegularExpression

Specify regular expression to match processing path of the files excluding -TargetFolder.
'.*' is default, and process all files.

�@�����Ώۂ̃t�@�C���A�t�H���_�̏�ʃp�X����-TargetFolder�̃p�X�܂ł𐳋K�\���Ńt�B���^���܂��B-TargetFolder�Ɋ܂܂��p�X�̓t�B���^�ΏۊO�ł��B
�f�t�H���g�� .* �őS�Ă��ΏۂƂȂ�܂��B
�L�q�̓V���O���N�I�[�e�[�V�����Ŋ����ĉ������B
PowerShell�̎d�l��A�啶���������̋�ʂ͂��Ȃ����ł����A���ۂɂ͋�ʂ����̂Œ��ӂ��ĉ������B

.PARAMETER RenameToRegularExpression

Specify regular expression for rename rule.

https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/substitutions-in-regular-expressions

-PostAction Rename���w�肵���ꍇ�̃t�@�C�������K�\���u���K�����w�肵�܂��B
-RegularExpression�ɑ΂���u���p�^�[�����w�肵�܂��B
https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/substitutions-in-regular-expressions


.PARAMETER Recurse
Specify to process the files or folders in the path recursively or non-recuresively.
[$TRUE(recuresively)] is default.

�@-TargetFolder�̒����̍ċA�I�܂��͔�ċA�ɏ����̎w�肪�\�ł��B
�f�t�H���g��$TRUE�ōċA�I�����ł��B

.PARAMETER NoRecurse
Specify if you want to filter files non-recursively.
The option override -Recurse option.

�@-TargetFolder�̒����݂̂������ΏۂƂ��܂��B-Recurse $FALSE�Ɠ����ł��B
Recurse�p�����[�^���D�悵�܂��B

.PARAMETER OverRide
Specify if you want to override old same name files moved or copied.
[terminate with an Error and do not override] is default.

�@�ړ��A�R�s�[��Ɋ��ɓ����̃t�@�C�������݂��Ă������I�ɏ㏑�����܂��B
�f�t�H���g�ł͏㏑�������Ɉُ�I�����܂��B

.PARAMETER Continue
Specify if you want to skip the process when old files existed and to process remains.
If skip the process, process remains and terminate with a Warning.
[terminate with an Error immediately and do not skip] is default. 

�@�ړ��A�R�s�[��Ɋ��ɓ����̃t�@�C�������݂����ꍇ���Y�t�@�C���̏������X�L�b�v���܂��B
�X�L�b�v����ƌx���I�����܂��B
�f�t�H���g�ł̓X�L�b�v�����Ɉُ�I�����܂��B

.PARAMETER ContinueAsNormal
Specify if you want to skip old files do not want to override.
If has skip to process, exit successfully.
[terminate with an Error immediately and do not skip] is default. 

�@�ړ��A�R�s�[��Ɋ��ɓ����̃t�@�C�������݂����ꍇ���Y�t�@�C���̏������X�L�b�v���܂��B
-Continue�ƈقȂ�X�L�b�v���Ă�����I�����܂��B�t�@�C���̍����R�s�[���ŗ��p���Ă��������B
-Continue�ɗD�悵�܂��B
�f�t�H���g�ł̓X�L�b�v�����Ɉُ�I�����܂��B


.PARAMETER NoneTargetAsWarning
Specify if you want to terminate with a Warning when no file exists in the folder.
[exit with Normal when no file exists in the folder] is default.

����Ώۂ̃t�@�C���A�t�H���_�����݂��Ȃ��ꍇ�Ɍx���I�����܂��B
���̃X�C�b�`��ݒ肵�Ȃ��Ƒ��݂��Ȃ��ꍇ�͒ʏ�I�����܂��B


.PARAMETER CompressedExtString
Specify file extention strings in specifing -PreAction Compress option.
[.zip] is default.

�@-PreAction Compress�w�莞�̃t�@�C���g���q���w��ł��܂��B
�f�t�H���g��[.zip]�ł��B

.PARAMETER TimeStampFormat
Specify time stamp format in specifing -PreAction AddTimeStamp option
[_yyyyMMdd_HHmmss] is default.
It is deffernt from time stamp format of script log.


�@-PreAction AddTimeStamp�w�莞�̏������w��ł��܂��B
�f�t�H���g��[_yyyyMMdd_HHmmss]�ł��B

.PARAMETER KeepFiles
Specify how many newer files in the folder to keep with -Action KeepFileCount option.
[1] is default.

-Action KeepFilesCount�w�莞�̐��㐔���w�肵�܂��B
�f�t�H���g��1�ł��B

.PARAMETER Compress
Planed to obsolute.
use -PreAction Compress

���̃p�����[�^�͔p�~�\��ł��B����݊����̂��߂Ɏc���Ă��܂����A-PreAction Compress���g�p���Ă��������B
�Ώۃt�@�C�������k���ĕʃt�@�C���Ƃ��ĕۑ����܂��B

.PARAMETER AddTimeStamp
Planed to obsolute.
use -PreAction AddTimeStamp


���̃p�����[�^�͔p�~�\��ł��B����݊����̂��߂Ɏc���Ă��܂����A-PreAction AddTimeStamp���g�p���Ă��������B
�Ώۃt�@�C�����ɓ�����t�����ĕʃt�@�C���Ƃ��ĕۑ����܂��B

.PARAMETER MoveNewFile
Planed to obsolute.
use -PreAction MoveNewFile

���̃p�����[�^�͔p�~�\��ł��B����݊����̂��߂Ɏc���Ă��܂����A-PreAction MoveNewFile���g�p���Ă��������B
-PreAction Compress , AddTimeStamp���w�肵���ۂɐ��������ʃt�@�C����-MoveToFolder�̎w���ɕۑ����܂��B
�f�t�H���g�͑Ώۃt�@�C���Ɠ���f�B���N�g���֕ۑ����܂��B

.PARAMETER NullOriginalFile
Planed to obsolute.
use -PostAction NullClear or -Action NullClear

���̃p�����[�^�͔p�~�\��ł��B����݊����̂��߂Ɏc���Ă��܂����A-PostAction NullClear�܂���-Action NullClear���g�p���Ă��������B
�Ώۃt�@�C���̓��e�����i�k���N���A�j���܂��B
-PostAction NullClear�Ɠ����ł��B



.PARAMETER Log2EventLog

Specify if you want to output log to Windows Event Log.
[$TRUE] is default.

�@Windows Event Log�ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE��Event Log�o�͂��܂��B

.PARAMETER NoLog2EventLog
Specify if you want to suppress log to Windows Event Log.
Specification override -Log2EventLog

�@Event Log�o�͂�}�~���܂��B-Log2EventLog $FALSE�Ɠ����ł��B
Log2EventLog���D�悵�܂��B

.PARAMETER ProviderName

Specify provider name of Windows Event Log.
[Infra] is default.


�@Windows Event Log�o�͂̃v���o�C�_�����w�肵�܂��B
�f�t�H���g��[Infra]�ł��B

.PARAMETER EventLogLogName

Specify log name of Windows Event Log.
[Application] is default.

�@Windows Event Log�o�͂̃��O�����w�肵�܂��B
�f�t�H���g��[Application]�ł��B

.PARAMETER Log2Console

Specify if you want to output log to PowerShell console.
[$TRUE] is default.

�@�R���\�[���ւ̃��O�o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE�ŃR���\�[���o�͂��܂��B

.PARAMETER NoLog2Console

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2Console

�@�R���\�[�����O�o�͂�}�~���܂��B-Log2Console $FALSE�Ɠ����ł��B
Log2Console���D�悵�܂��B

.PARAMETER Log2File

Specify if you want to output log to text log.
[$FALSE] is default.

�@���O�t�B���ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$FALSE�Ń��O�t�@�C���o�͂��܂���B

.PARAMETER NoLog2File

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2File

�@���O�t�@�C���o�͂�}�~���܂��B-Log2File $FALSE�Ɠ����ł��B
Log2File���D�悵�܂��B

.PARAMETER LogPath

Specify the path of text log file.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.
[$NULL] is default.

If the log file dose not exist, make new file.
If the log file exists, write log additionally.

�@���O�t�@�C���o�̓p�X���w�肵�܂��B�f�t�H���g��$NULL�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���΃p�X�\�L�́A.����n�߂�\�L�ɂ��ĉ������B�i�� .\Log\Log.txt , ..\Script\log\log.txt�j
���C���h�J�[�h* ? []�͎g�p�ł��܂���B
�t�H���_�A�t�@�C�����Ɋ��� [ , ] ���܂ޏꍇ�̓G�X�P�[�v�����ɂ��̂܂ܓ��͂��Ă��������B
�t�@�C�������݂��Ȃ��ꍇ�͐V�K�쐬���܂��B
�t�@�C���������̏ꍇ�͒ǋL���܂��B

.PARAMETER LogDateFormat

Specicy time stamp format in the text log.
[yyyy-MM-dd-HH:mm:ss] is default.

�@���O�t�@�C���o�͂Ɋ܂܂������\���t�H�[�}�b�g���w�肵�܂��B
�f�t�H���g��[yyyy-MM-dd-HH:mm:ss]�`���ł��B

.PARAMETER LogFileEncode

Specify the character encode in the log file.
[Default] is default and it works as ShiftJIS.


���O�t�@�C���̕����R�[�h���w�肵�܂��B
�f�t�H���g��Shift-JIS�ł��B

.PARAMETER NormalReturnCode

Specify Normal Return code.
[0] is default.
Must specify NormarReturnCode =< WarningReturnCode =< ErrorReturnCode(InternalErrorReturnCode)


�@����I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��0�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER WarningReturnCode

Specify Warning Return code.
[1] is default.
Must specify NormarReturnCode =< WarningReturnCode =< ErrorReturnCode(InternalErrorReturnCode)

�@�x���I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��1�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER ErrorReturnCode

Specify Error Return code.
[8] is default.
Must specify NormarReturnCode =< WarningReturnCode =< ErrorReturnCode(InternalErrorReturnCode)

�@�ُ�I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��8�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER InternalErrorReturnCode

Specify Internal Error Return code.
[16] is default.
Must specify NormarReturnCode =< WarningReturnCode =< ErrorReturnCode(InternalErrorReturnCode)

�@�v���O���������ُ�I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��16�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER InfoEventID

Specify information event id in the log.
[1] is default.


.PARAMETER InfoLoopStartEventID

Specify start loop event id in the log.
[2] is default.


�@Event Log�o�͂Ńt�@�C��/�t�H���_�����J�n��Information�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��2�ł��B

.PARAMETER InfoLoopEndEventID

Specify end loop event id in the log.
[3] is default.

�@Event Log�o�͂Ńt�@�C��/�t�H���_�����I����Information�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��3�ł��B

.PARAMETER WarningEventID


Specify Warning event id in the log.
[10] is default.


�@Event Log�o�͂�Warning�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��10�ł��B

.PARAMETER SuccessEventID

Specify Successfully complete event id in the log.
[73] is default.

�@Event Log�o�͂�Success�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��73�ł��B

.PARAMETER InternalErrorEventID

Specify Internal Error event id in the log.
[99] is default.

�@Event Log�o�͂�Internal Error�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��99�ł��B

.PARAMETER ErrorEventID

Specify Error event id in the log.
[100] is default.

�@Event Log�o�͂�Error�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��100�ł��B

.PARAMETER ErrorAsWarning

Specfy if you want to return WARNING exit code when the script terminate with an Error.

�@�ُ�I�����Ă��x���I����ReturnCode��Ԃ��܂��B

.PARAMETER WarningAsNormalaaaaaaa

Specify if you want to return NORMAL exit code when the script terminate with a Warning.

�@�x���I�����Ă�����I����ReturnCode��Ԃ��܂��B

.PARAMETER ExecutableUser

Specify the user who is allowed to execute the script in regular expression.
[.*] is default and all users are allowed to execute.
Parameter must be quoted with single quote'
Escape the back slash in the separeter of a domain name.
example [domain\\.*]

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

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
Param(

[String]
[parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Specify the folder to process (ex. D:\Logs)  or Get-Help FileMaintenance.ps1')]
[ValidateNotNullOrEmpty()]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("Path","LiteralPath","FullName")]$TargetFolder ,

#[String]$TargetFolder,  #for Validation debug
 

[Array][parameter(position = 1)][ValidateNotNullOrEmpty()]
[ValidateSet("none" , "AddTimeStamp" , "Compress", "MoveNewFile" , "Archive" , "7z" , "7zZip")]$PreAction = 'none' ,

[String][parameter(position = 2)][ValidateNotNullOrEmpty()]
[ValidateSet("none" , "Move", "Copy", "Delete" , "DeleteEmptyFolders" , "NullClear" , "KeepFilesCount")]$Action = 'none' ,

[String][parameter(position = 3)][ValidateNotNullOrEmpty()]
[ValidateSet("none" , "NullClear" , "Rename")]$PostAction = 'none' ,


[String][parameter(position = 4)][ValidateNotNullOrEmpty()]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("DestinationPath")]$MoveToFolder ,

#[String]$MoveToFolder,  #for Validation debug

[String][ValidateNotNullOrEmpty()][ValidatePattern('^(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$ArchiveFileName = "archive" ,

[Int][ValidateRange(0,2147483647)]$KeepFiles = 1 ,
[Int][ValidateRange(0,730000)]$Days = 0 ,
[Int64][ValidateRange(0,9223372036854775807)]$Size = 0 ,

#[Regex][Alias("Regex")]$RegularExpression = '$(.*)\.txt$' , #RenameRegex Sample

[Regex][Alias("Regex")]$RegularExpression = '.*' ,
[Regex][Alias("PathRegex")]$ParentRegularExpression = '.*' ,
[Regex][Alias("RenameRegex")]$RenameToRegularExpression = '$1.log' ,

[Boolean]$Recurse = $TRUE ,
[Switch]$NoRecurse ,


[Switch]$OverRide ,
[Switch]$Continue ,
[Switch]$ContinueAsNormal ,
[Switch]$NoneTargetAsWarning ,

[String]$CompressedExtString = '.zip',

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]
[ValidateNotNullOrEmpty()]$7zFolder = 'C:\Program Files\7-Zip' ,

[String][ValidatePattern('^(?!.*(\\|\/|:|\?|`"|<|>|\|)).*$')]$TimeStampFormat = '_yyyyMMdd_HHmmss' ,


#Switches planned to be obsolute please use -PreAction start
[Switch]$Compress,
[Switch]$AddTimeStamp,
[Switch]$MoveNewFile,
[Switch]$NullOriginalFile,
#Switches planned to be obsolute please use -PreAction end


[Boolean]$Log2EventLog = $TRUE ,
[Switch]$NoLog2EventLog ,
[String]$ProviderName = 'Infra' ,
[String][ValidateSet("Application")]$EventLogLogName = 'Application' ,

[Boolean]$Log2Console = $TRUE ,
[Switch]$NoLog2Console ,

[Boolean]$Log2File = $FALSE ,
[Switch]$NoLog2File ,

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]
[ValidateNotNullOrEmpty()]$LogPath ,

[String]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss' ,
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default' , #Default ShiftJIS

[Int][ValidateRange(0,2147483647)]$NormalReturnCode = 0 ,
[Int][ValidateRange(0,2147483647)]$WarningReturnCode = 1 ,
[Int][ValidateRange(0,2147483647)]$ErrorReturnCode = 8 ,
[Int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16 ,

[Int][ValidateRange(1,65535)]$InfoEventID = 1 ,
[Int][ValidateRange(1,65535)]$InfoLoopStartEventID = 2 ,
[Int][ValidateRange(1,65535)]$InfoLoopEndEventID = 3 ,
[Int][ValidateRange(1,65535)]$WarningEventID = 10 ,
[Int][ValidateRange(1,65535)]$SuccessEventID = 73 ,
[Int][ValidateRange(1,65535)]$InternalErrorEventID = 99 ,
[Int][ValidateRange(1,65535)]$ErrorEventID = 100 ,

[Switch]$ErrorAsWarning ,
[Switch]$WarningAsNormal ,

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


################ specify upper lines ##################


################# functions  #######################


function Test-LeafNotExists {

<#
.SYNOPSIS
�@�w�肵���p�X�Ƀt�@�C�������݂��Ȃ������m�F����

.INPUT
�@Strings of File Path

.OUTPUT
�@Boolean
1    �`�F�b�N�Ώۂ̃t�@�C�������݂��邪�A-OverRide���w��...$TRUE, $OverRideFlag = $TRUE�i���̎w���-Continue�ɗD�悷��j�Ȃ�Invoke-Action�͊��Ƀt�@�C�������݂���ꍇ�͋����㏑��
2    �`�F�b�N�Ώۂ̃t�@�C�������݂��邪�A-Continue���w��...$FALSE, $ContinueFlag = $TRUE 
3    �`�F�b�N�Ώۂ̃t�@�C�������݂���...$ErrorReturnCode ��Finalize, $FroceEndLoop=$TRUE �Ȃ��$FALSE, $ForceFinalize=$TRUE
4    �`�F�b�N�Ώۂ̓��ꖼ�̂̃t�H���_�����݂��邪�A-OverRide���w��...�㏑�����o���Ȃ��̂�$ErrorReturnCode ��Finalize, $FroceEndLoop=$TRUE �Ȃ��$FALSE, $ForceFinalize=$TRUE
5    �`�F�b�N�ΏۂƓ��ꖼ�̂̃t�H���_�����݂��邪�A-Continue���w��...$FALSE
6    �`�F�b�N�ΏۂƓ��ꖼ�̂̃t�H���_�����݂���...$ErrorReturnCode ��Finalize, $FroceEndLoop=$TRUE �Ȃ��$FALSE, $ForceFinalize=$TRUE
7    �`�F�b�N�Ώۂ̃t�@�C���A�t�H���_�����݂��Ȃ�...$TRUE
#>

[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
[Alias("CheckPath" , "FullName")]$Path ,

[Switch]$ForceEndLoop = $ForceEndLoop ,
[Switch]$OverRide = $OverRide ,
[Switch]$Continue = $Continue ,
[Switch]$ContinueAsNormal = $ContinueAsNormal ,
[int]$InfoEventID = $InfoEventID ,
[int]$WarningEventID = $WarningEventID ,
[int]$ErrorEventID = $ErrorEventID
)

begin {
}
process {
Write-Log -ID $InfoEventID -Type Information -Message "Check existence of $($Path)"

Do {

    #Case 7
    IF (-not(Test-Path -LiteralPath $Path)) {

        Write-Log -ID $InfoEventID -Type Information -Message "File $($Path) dose not exist."
        $noExistFlag = $TRUE
        Break
        }

    #Case 1
    IF (($OverRide) -and (Test-Path -LiteralPath $Path -PathType Leaf)) {
     
        Write-Log -ID $WarningEventID -Type Warning -Message ("Same name file $($Path) exists already, " +
            "but specified -OverRide[$OverRide] option, thus override the file.")
        $Script:OverRideFlag = $TRUE
        $Script:WarningFlag = $TRUE
        $noExistFlag = $TRUE
        Break
        }

    IF (Test-Path -LiteralPath $Path -PathType Leaf) {
        
        Write-Log -ID $WarningEventID -Type Warning -Message "Same name file $($Path) exists already."
        
        } else {
        Write-Log -ID $WarningEventID -Type Warning -Message "Same name folder $($Path) exists already."        
        }

    #Case 2,5
    IF ($Continue) {

        Write-Log -ID $WarningEventID -Type Warning -Message "Specified -Continue[$($Continue)] option, continue to process objects."
    
        $Script:WarningFlag = $TRUE
        $Script:ContinueFlag = $TRUE
        $noExistFlag = $FALSE
        Break
        }           

    #Case 3,4,6
    Write-Log -ID $ErrorEventID -Type Error -Message "Same name object exists already, thus force to terminate $($ShellName)"
            
    IF ((-not($ForceEndLoop)) -and (-not($MYINVOCATION.ExpectingInput))) {

        Finalize $ErrorReturnCode

        } else {
        $Script:ErrorFlag = $TRUE
        $Script:ForceFinalize = $TRUE
        $noExistFlag = $FALSE
        Break 
        }
}

While ($FALSE)

    IF (($ContinueAsNormal) -and ($WarningFlag)) {

        Write-Log -ID $InfoEventID -Type Information -Message "Specified -ContinueAsNormal[$($ContinueAsNormal)] option, count warning event as NORMAL."
        $Script:WarningFlag = $FALSE
        }

Write-Output $noExistFlag
}
end {
}
}


filter ComplexFilter {

<#
.SYNOPSIS
�@�I�u�W�F�N�g�𕡐������Ńt�B���^�A�K��������̂�����OUTPUT

.DESCRIPTION
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
 
    IF ($_.LastWriteTime -lt (Get-Date).AddDays(-$Days)) {
    IF ($_.Name -match $RegularExpression) {
    IF ($_.Length -ge $Size) {
    IF (($_.FullName).Substring($TargetFolder.Length , (Split-Path -Path $_.FullName -Parent).Length - $TargetFolder.Length +1) -match $ParentRegularExpression)
        {$_}
    }
    } 
    }                                                                              
}

 
function Get-Object {

<#
.SYNOPSIS
�@�w��t�H���_����I�u�W�F�N�g�Q�i�t�@�C��|�t�H���_�j�𒊏o

.INPUT
System.String. Path of the folder to get objects

.OUTPUT
PSObject
#>

[OutputType([PSObject])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("TargetFolder" , "FullName")]$Path ,
[String][parameter(position = 1, mandatory)][ValidateSet("File" , "Folder")]$FilterType ,

[Switch]$Recurse = $Recurse ,
[String]$Action = $Action
)

begin {
}
process {
    $candidateObjects = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse -Include * -File:($FilterType -eq 'File') -Directory:($FilterType -eq 'Folder')

    $objects = @()

    ForEach ($object in ($candidateObjects | ComplexFilter)) {

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
            Write-Output $objects | Sort-Object -Property Time
            }

        #DeleteEmptyFolders�z��ɓ��ꂽ�p�X�ꎮ���p�X���[�����ɐ���B��t�H���_����t�H���_�ɓ���q�ɂȂ��Ă���ꍇ�A�[���K�w����폜����K�v������B
        '^DeleteEmptyFolders$' {
            Write-Output $objects | Sort-Object -Property Depth -Descending  
            }

        Default{
            Write-Output $objects
            }
    }
}
end {
}

}


function ConvertTo-PreActionPath {

<#
.SYNOPSIS
ConvertTo new path with extention .zip or adding time stamp

.INPUT
System.String. Path of the file

.OUTPUT
PSobject
#>

[OutputType([PSObject])]
[CmdletBinding()]
Param(
[String][parameter(position = 0 ,mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("TargetObject" , "FullName")]$Path , 
[String][parameter(position = 1 ,mandatory, ValueFromPipelineByPropertyName)][Alias("destinationFolder")]$DestinationPath ,

[Array]$PreAction = $PreAction ,
[String]$CompressedExtString =  $CompressedExtString ,
[String]$TimeStampFormat = $TimeStampFormat
) 

begin {
    $archive = New-Object PSObject -Property @{
        Path = ''
        Type = ''
        }
}
process {
    IF (($PreAction -match '^(Compress|Archive)$')) {

        #$PreAction�͔z��ł���B�����Switch���������1�v�f�Â��[�v����B
        #'Compress'���͈�UDefault�ɗ����邪�A'7z' or '7zZip'�������$ActionType�͏㏑�������

        Switch -Regex ($PreAction) {    
        
          '^7z$' {
                $archive.Type = "7z"
                $extension = '.7z'
                Break                
                }
                
           '^7zZip$' {
                $archive.Type = "7zZip"
                $extension = '.zip'
                Break
                }
                    
             Default {
                $archive.Type = ''
                $extension = $CompressedExtString
                }    
        }

    } else {
    $archive.Type = '' 
    $extension = ''
    }
 
    Switch -Regex ($PreAction) {    
        
          '^Compress$' {
                $archive.Type += "Compress"
                Break                
                }
                
           '^Archive$' {
                $archive.Type += "Archive"
                Break
                }
                    
             Default {
                }    
    }

    IF ($PreAction -contains 'AddTimeStamp') {

        $archive.Path = $DestinationPath | Join-Path -ChildPath (($Path | Split-Path -Leaf | ConvertTo-FileNameAddTimeStamp -TimeStampFormat $TimeStampFormat) + $extension)

        IF ($PreAction -match '^(Compress|Archive)$') {

            $archive.Type += "AndAddTimeStamp"
           
            } else {
            $archive.Type += "AddTimeStamp"        
            }

        } else {        
        $archive.Path = $DestinationPath | Join-Path -ChildPath (($Path | Split-Path -Leaf) + $extension )        
        }

        Write-Log -ID $InfoEventID -Type Information -Message "Create a new file [$($archive.Path | Split-Path -Leaf)] with action [$($archive.Type)]"

    IF ($PreAction -contains 'MoveNewFile') {

            Write-Log -ID $InfoEventID -Type Information -Message ("Specified -PreAction MoveNewFile["+[Boolean]($PreAction -contains 'MoveNewFile')+"] option, " + 
                "thus place the new file in the folder [$($DestinationPath)]")
            }

    Write-Output $archive
}
end {
}
}


function Initialize {

$ShellName = $PSCommandPath | Split-Path -Leaf

#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. Invoke-PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�

#Switch����

IF ($NoRecurse)        {[Boolean]$Script:Recurse = $FALSE}
IF ($ContinueAsNormal) {[Switch]$Script:Continue = $TRUE}

#For Backward Compatibility

IF ($NullOriginalFile) {[String]$Script:PostAction = 'NullClear'}
IF ($AddTimeStamp) {$Script:PreAction +='AddTimeStamp'}
IF ($MoveNewFile)  {$Script:PreAction +='MoveNewFile'}
IF ($Compress)     {$Script:PreAction +='Compress'}

#�p�����[�^�̊m�F


#�w��t�H���_�̗L�����m�F
#Test-Container function��$TRUE,$FALSE���ߒl�Ȃ̂�$NULL�֎̂Ă�B�̂ĂȂ��ƃR���\�[���o�͂����

    $TargetFolder = $TargetFolder | ConvertTo-AbsolutePath -Name '-TargetFolder'

    $TargetFolder | Test-Container -Name '-TargetFolder' -IfNoExistFinalize > $NULL


#�ړ���t�H���_�̗v�s�v�ƗL�����m�F

    IF (($Action -match "^(Move|Copy)$") -or ($PreAction -contains 'MoveNewFile')) {    

        $MoveToFolder = $MoveToFolder | ConvertTo-AbsolutePath -Name '-MoveToFolder'
    
        $MoveToFolder | Test-Container -Name '-MoveToFolder' -IfNoExistFinalize > $NULL
       
    } elseIF (-not($MoveToFolder | Test-PathNullOrEmpty)) {
    
        Write-Log -ID $ErrorEventID -Type Error -Message "Specified -Action [$($Action)] option, must not specifiy -MoveToFolder option."
        Finalize $ErrorReturnCode
        }


#ArchiveFileName�̗v�s�v�ƗL���AValidation

    IF ($PreAction -contains 'Archive') {

        $ArchiveFileName | Test-PathNullOrEmpty -Name '-ArchiveFileName' -IfNullOrEmptyFinalize > $NULL
        
        IF ($ArchiveFileName -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Write-Log -Type Error -ID $ErrorEventID -Message "-ArchiveFileName may contain characters that can not use by NTFS."
                Finalize $ErrorReturnCode
                } 
        }


#7z�t�H���_�̗v�s�v�ƗL�����m�F

    IF ($PreAction -match "^(7z|7zZip)$") {    

        $7zFolder = $7zFolder | ConvertTo-AbsolutePath -Name '-7zFolder'

        $7zFolder | Test-Container -Name '-7zFolder' -IfNoExistFinalize > $NULL
        }

#�g�ݍ��킹���s���Ȏw����m�F


    IF (($TargetFolder -eq $MoveToFolder) -and   (($Action -match "(move|copy)") -or ($PreAction -contains 'MoveNewFile'))) {
    
        Write-Log -Type Error -ID $ErrorEventID -Message ("Specified -(Pre)Action option for Move or Copy files, " +
            "-TargetFolder and -MoveToFolder must not be same.")
        Finalize $ErrorReturnCode
        }

    IF (($Action -match "^(Move|Delete|KeepFilesCount)$") -and  ($PostAction -ne 'none')) {

        Write-Log -Type Error -ID $ErrorEventID -Message ("Specified -Action[$($Action)] option for Delete or Move files, " +
            "must not specify -PostAction[$($PostAction)] option.")
        Finalize $ErrorReturnCode
        }

   IF (($PreAction -contains 'MoveNewFile') -and (-not($PreAction -match "^(Compress|AddTimeStamp|Archive)$")) ) {

        Write-Log -Type Error -ID $ErrorEventID -Message ("Secified -PreAction MoveNewFile option, " + 
            "must specify -PreAction Compres or AddTimeStamp or Archive option also. " +
            "If you move the original files, will specify -Action Move option.")
        Finalize $ErrorReturnCode
        }

   IF (($PreAction -contains 'Compress') -and ($PreAction -contains 'Archive')) {

        Write-Log -Type Error -ID $ErrorEventID "Must not specify -PreAction both Compress and Archive options in the same time."
        Finalize $ErrorReturnCode
        }

   IF (($PreAction -contains '7z') -and ($PreAction -Contains '7zZip')) {

        Write-Log -Type Error -ID $ErrorEventID -Message "Must not specify -PreAction both 7z and 7zZip options for the archive method in the same time."
        Finalize $ErrorReturnCode
        }

   IF (($PreAction -match "^(7z|7zZip)$") -and (-not($PreAction -match "^(Compress|Archive)$"))) {

        Write-Log -Type Error -ID $ErrorEventID -Message ("Must not specify -PreAction only 7z or 7zZip option. " +
            "Must specify -PreAction Compress or Archive option with them.")
        Finalize $ErrorReturnCode
        }

   IF ($Action -eq "DeleteEmptyFolders") {
    
        IF (($PreAction -match '^(Compress|Archive|AddTimeStamp)$')  -or ($PostAction -ne 'none' )) {
    
                Write-Log -Type Error -ID $ErrorEventID -Message ("Specified -Action [$Action] , " +
                    "must not specify -PreAction or -PostAction options for modify files.")
                Finalize $ErrorReturnCode

        } elseIF ($Size -ne 0) {
    
                Write-Log -Type Error -ID $ErrorEventID -Message "Specified -Action [$Action] , must not specify -size option."
                Finalize $ErrorReturnCode
                }
    }


    IF ($TimeStampFormat -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
        Write-Log -Type Error -ID $ErrorEventID -Message "-TimeStampFormat  may contain characters that can not use by NTFS."
        Finalize $ErrorReturnCode
        }



#�����J�n���b�Z�[�W�o��


Write-Log -ID $InfoEventID -Type Information -Message "All parameters are valid."

    IF ($Action -eq "DeleteEmptyFolders") {

        Write-Log -ID $InfoEventID -Type Information -Message ("Delete empty folders [in target folder $($TargetFolder)]" + 
            "[older than $($Days)days][match to regular expression [$($RegularExpression)]][recursively[$($Recurse)]]")
        
        } else {

        Write-Log -ID $InfoEventID -Type Information -Message ("Files [in the folder $($TargetFolder)][older than $($Days)days]" + 
            "[match to regular expression [$($RegularExpression)]]" +
            "[parent path match to regular expression [$($ParentRegularExpression)]]" +
            "[size is over"+($Size / 1KB)+"KB]")

        IF ($PreAction -notcontains 'none') {

            $message = "Process files matched "
            IF ($PreAction -contains 'MoveNewFile') { $message += "to move to [$($MoveToFolder)] "}

            IF ($PreAction -match "^(Compress|Archive)$") {
                
                #$PreAction�͔z��Ȃ̂�Switch�ŏ�������ƕ�������s�����̂ŁAIF�ŏ���
                IF ($PreAction -contains '7z') {
                        $message += "with compress method [7z] "            
                        } elseIF ($PreAction -contains '7zZIP') {
                            $message += "with compress method [7zZip] "
                            } else {
                                $message += "with compress method [Powershell cmdlet Compress-Archive] "
                                }                          
            }
            
            $message += ("recursively [$($Recurse)] PreAction(Add time stamp to filename["+[Boolean]($PreAction -contains 'AddTimeStamp')+"] | " + 
                        "Compress["+[Boolean]($PreAction -contains 'Compress')+"] | Archive to 1file["+[Boolean]($PreAction -contains 'Archive')+"] )")

            Write-Log -ID $InfoEventID -Type Information -Message $message
            }


        IF ($Action -ne 'none') {

            $message = "Process files matched "
            IF ($Action -eq 'KeepFilesCount') { $message += "[keep file generation only($($KeepFiles))] "}
            IF ($Action -match '^(Copy|Move)$') { $message += "moving to[$($MoveToFolder)] "}
            $message += "recursively[$($Recurse)] Action[$($Action)]"

            Write-Log -ID $InfoEventID -Type Information -Message $message
            }

        IF ($PostAction -ne 'none') {

            $message = "Process files matched"
            IF ($PostAction -eq 'Rename') { $message += "rename with rule[$($RenameToRegularExpression)] "}
            $message += "recursively[$($Recurse)] PostAction[$($PostAction)]"

            Write-Log -ID $InfoEventID -Type Information -Message $message
            }
    }


    IF ($OverRide) {
        Write-Log -ID $InfoEventID -Type Information -Message ("Specified -OverRide[$($OverRide)] option, " +
            "thus if files exist with the same name, will override them.")
        }

    IF ($ContinueAsNormal) {
        Write-Log -ID $InfoEventID -Type Information -Message ("Specified -ContinueAsNormal[$($ContinueAsNormal)] option, " +
            "thus if file exist in the same name already, will process next file with a NORMAL logging without termination.")
        
        } elseIF ($Continue) {
            Write-Log -ID $InfoEventID -Type Information -Message ("Specified -Continue[$($Continue)] option, " +
                "thus if a file exist in the same name already, will process next file with a WARNING logging and without termination.")
            }

}


function Finalize {

Param(
[parameter(mandatory)][Int]$ReturnCode
)
    $ForceFinalize = $FALSE
 
    IF ( ($NormalCount + $WarningCount + $ErrorCount) -ne 0 ) {    

       Write-Log -ID $InfoEventID -Type Information -Message "The results of execution NORMAL[$($NormalCount)] WARNING[$($WarningCount)] ERROR[$($ErrorCount)]"


        IF ($OverRide -and ($OverRideCount -gt 0)) {
            Write-Log -ID $InfoEventID -Type Information -Message ("Specified -OverRide[$($OverRide)] option, " +
                "thus overrided old same name files with new files created in [$($OverRideCount)] times.")
            }

        IF (($Continue) -and ($ContinueCount -gt 0)) {
            Write-Log -ID $InfoEventID -Type Information -Message ("Specified -Continue[$($Continue)] option, " +
                "thus continued to process next objects in [$($ContinueCount)] times even though error occured with the same name file/folders existed already.")
            }
    }

 Invoke-PostFinalize $ReturnCode
}


#####################  main  ######################

[Boolean]$ErrorFlag     = $FALSE
[Boolean]$WarningFlag   = $FALSE
[Boolean]$NormalFlag    = $FALSE
[Boolean]$OverRideFlag  = $FALSE
[Boolean]$ContinueFlag  = $FALSE

[Int][ValidateRange(0,2147483647)]$ErrorCount    = 0
[Int][ValidateRange(0,2147483647)]$WarningCount  = 0
[Int][ValidateRange(0,2147483647)]$NormalCount   = 0
[Int][ValidateRange(0,2147483647)]$OverRideCount = 0
[Int][ValidateRange(0,2147483647)]$ContinueCount = 0
[Int][ValidateRange(0,2147483647)]$InLoopDeletedFilesCount = 0

[String]$DatumPath = $PSScriptRoot
[Boolean]$WhatIfFlag = (($PSBoundParameters['WhatIf']) -ne $NULL)

$Version = "2.0.0-RC.1"

[Boolean]$ForceEndloop  = $FALSE          ;#$FALSE�ł�Finalize , $TRUE�ł̓��[�v����Break

#$VerbosePreference = 'Continue'
#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize


#�Ώۂ̃t�H���_�܂��̓t�@�C����T���Ĕz��ɓ����

    IF ($Action -eq "DeleteEmptyFolders") {

        $FilterType = "Folder"

        } else {
        $FilterType = "File"
        }

$targets = @()

$targets = $TargetFolder | Get-Object -FilterType $FilterType

    IF ($NULL -eq $targets) {

        Write-Log -ID $InfoEventID -Type Information -Message "In -TargetFolder [$($targetFolder)] no [$($FilterType)] exists for processing."

        IF ($NoneTargetAsWarning) {
            Write-Log -ID $WarningEventID -Type Warning -Message ("Specified -NoneTargetAsWarning option, " +
                "thus terminiate $($ShellName) with WARNING.")
            Finalize $WarningReturnCode

            } else {
            Finalize $NormalReturnCode
            }
    }

Write-Log -ID $InfoEventID -Type Information -Message ("["+@($targets).Length+"] [$($FilterType)(s)] exist for processing.")

Write-Debug   ("["+@($targets).Length+"][$($FilterType)(s)] are for processing...")

Write-Debug   ("`r`n" + ($targets.Object.fullname | Out-String))

Write-Verbose ("["+@($targets).Length+"][$($FilterType)(s)] are for processing..." + "`r`n" + ($targets.Object.fullname | Out-String))

#-PreAction Archive�͕����t�@�C����1�t�@�C���Ɉ��k����B����āA���[�v�O�Ɉ��k���1�t�@�C���̃t���p�X���m�肵�Ă���

IF ($PreAction -contains 'Archive') {

    IF ($PreAction -contains 'MoveNewFile') {        

        $destination = $MoveToFolder

        } else {
        $destination = $TargetFolder
        }

    $archive = $ArchiveFileName | ConvertTo-PreActionPath -DestinationPath $destination
 
    IF (-not($archive.Path | Test-LeafNotExists)) {
        
        Write-Log -ID $ErrorEventID -Type Error -Message ("File/Folder exists in the path [$($archive.Path)] already, " +
            "thus terminate $($ShellName) with an Error")
        Finalize $ErrorReturnCode        
        }
}


#�Ώۃt�H���_or�t�@�C���Q�̏������[�v

ForEach ($Target in $targets) {
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

Do {

[Boolean]$ErrorFlag     = $FALSE
[Boolean]$WarningFlag   = $FALSE
[Boolean]$NormalFlag    = $FALSE
[Boolean]$OverRideFlag  = $FALSE
[Boolean]$ContinueFlag  = $FALSE
[Boolean]$ForceFinalize = $FALSE          ;#$TRUE���߂�����I�u�W�F�N�g�������[�v�������I��
[Int]$InLoopOverRideCount = 0    ;#$OverRideCount�͏����S�̂�OverRide�񐔁B$InLoopOverRideCount��1�������[�v���ł�OverRide�񐔁B1�I�u�W�F�N�g�ŕ�����OverRide�����蓾�邽��

[Boolean]$ForceEndloop  = $TRUE   ;#���̃��[�v���ňُ�I�����鎞�̓��[�v�I�[��Break���āA�������ʂ�\������B������Finalize���Ȃ�

Write-Log -ID $InfoLoopStartEventID -Type Information -Message "--- Start processing [$($FilterType)] $($Target.Object.FullName) ---"


#�ړ����̃t�@�C���p�X����ړ���̃t�@�C���p�X�𐶐��B
#�ċA�I�łȂ���΁A�ړ���p�X�͊m���ɑ��݂���̂ŃX�L�b�v

#Action[(Move|Copy)]�ȊO�̓t�@�C���ړ��������B�ړ���p�X���m�F����K�v���Ȃ��̂ŃX�L�b�v
#PreAction[Archive]��MoveNewFile[TRUE]�ł��o�̓t�@�C����1�ŊK�w�\�������Ȃ��B����ăX�L�b�v

    IF ( ($Action -match "^(Move|Copy)$") -or (($PreAction -contains 'MoveNewFile') -and ($PreAction -notcontains 'Archive')) ) {

        #�t�@�C�����ړ�����Action�p�Ƀt�@�C���ړ���̐e�t�H���_�p�X$MoveToNewFolder�𐶐�����
        
        #C:\TargetFolder                    :TargetFolder
        #C:\TargetFolder\A\B\C              :TargetFileParentFolder
        #C:\TargetFolder\A\B\C\target.txt   :TargetFile
        #D:\MoveToFolder                    :MoveToFolder
        #D:\MoveToFolder\A\B\C              :MoveToNewFolder

        #D:\MoveToFolder\A\B\C\target.txt   :�t�@�C���̈ړ���p�X

        #destinationFolder�����ɂ� \A\B\C\�@�̕��������o���āA�ړ���t�H���_MoveToFolder��Join-Path����
        #String.Substring���\�b�h�͕����񂩂�A�����ʒu����Ō�܂ł����o��
        #destinationFolder��NoRecurse�ł�Move|Copy�ňꗥ�g�p����̂ō쐬

        $destinationFolder = $MoveToFolder | Join-Path -ChildPath ($Target.Object.DirectoryName).Substring($TargetFolder.Length)
        IF ($Recurse) {

            IF (-not($destinationFolder | Test-Container -Name 'Desitination folder of the file ')) {

                Write-Log -ID $InfoEventID -Type Information -Message "Create a new folder $($destinationFolder)"

                Invoke-Action -ActionType MakeNewFolder -ActionFrom $destinationFolder -ActionError $destinationFolder

                #$Invoke-Action���ُ�I��&-Continue $TRUE����$ContinueFlag $TRUE�ɂȂ�̂ŁA���̏ꍇ�͌㑱�����͂��Ȃ��Ŏ���Object�����ɐi��
                IF ($ContinueFlag) {
                    Break                
                    }
            }
        }
    }

#Pre Action

    IF (($PreAction -match '^(Compress|AddTimeStamp)$') -and ($PreAction -notcontains 'Archive')) {

        IF ($PreAction -contains 'MoveNewFile') {        

            $destination = $destinationFolder

            } else {
            $destination = $Target.Object.DirectoryName
            }

        $archive = $Target.Object.FullName | ConvertTo-PreActionPath -DestinationPath $destination

        IF ($archive.Path | Test-LeafNotExists) {

            Invoke-Action -ActionType $archive.Type -ActionFrom $Target.Object.FullName -ActionTo $archive.Path -ActionError $Target.Object.FullName
            }
        
    } elseIF ($PreAction -contains 'Archive') {
       
        Invoke-Action -ActionType $archive.Type -ActionFrom $Target.Object.FullName -ActionTo $archive.Path -ActionError $Target.Object.FullName
        }


#Main Action

    Switch -Regex ($Action) {

    #����1 �������Ȃ�
    '^none$' {
            IF ( ($PostAction -eq 'none') -and ($PreAction -contains 'none') ) {

                Write-Log -ID $InfoEventID -Type Information -Message ("Specified -Action [$($Action)] option, " +
                    "thus do not process $($Target.Object.FullName)")
                }
            }

    #����2 �폜
    '^Delete$' {
            Invoke-Action -ActionType Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName
            } 

    #����3 �ړ� or ���� �@����̃t�@�C�����i�ړ�|������j�ɑ��݂��Ȃ����Ƃ��m�F���Ă��珈��
    '^(Move|Copy)$' {
            $destinationPath = $destinationFolder | Join-Path -ChildPath ($Target.Object.Name)

            IF ($destinationPath | Test-LeafNotExists) {

                Invoke-Action -ActionType $Action -ActionFrom $Target.Object.FullName -ActionTo $destinationPath -ActionError $Target.Object.FullName 
                }
            }

    #����4 ��t�H���_�𔻒肵�č폜
    '^DeleteEmptyFolders$' {
            Write-Log -ID $InfoEventID -Type Information -Message  "Check the folder $($Target.Object.FullName) is empty."

            IF ($Target.Object.GetFileSystemInfos().Count -eq 0) {

                Write-Log -ID $InfoEventID -Type Information -Message  "The folder $($Target.Object.FullName) is empty."
                Invoke-Action -ActionType Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName

                } else {
                Write-Log -ID $InfoEventID -Type Information -Message "The folder $($Target.Object.FullName) is not empty." 
                }
            }


    #����5 NullClear
    '^NullClear$' {
            Invoke-Action -ActionType NullClear -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName          
            }

    #����6 KeepFilesCount
    '^KeepFilesCount$' {
            IF ((@($targets).Length - $InLoopDeletedFilesCount) -gt $KeepFiles) {

                Write-Log -ID $InfoEventID -Type Information -Message  ("More than [$($KeepFiles)] files exist in the folder, " +
                    "thus delete the oldest [$($Target.Object.FullName)]")

                Invoke-Action -ActionType Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName

                #$Invoke-Action���ُ�I��&-Continue $TRUE����$ContinueFlag $TRUE�ɂȂ�̂ŁA���̏ꍇ�͌㑱�����͂��Ȃ��Ŏ���Object�����ɐi��
                IF ($ContinueFlag) {
                    Break                
                    }
                $InLoopDeletedFilesCount++
            
                } else {
                Write-Log -ID $InfoEventID -Type Information -Message  ("Less [$($KeepFiles)] files exist in the folder, " +
                    "thus do not delete [$($Target.Object.FullName)]")
                }
            }

    #����7 $Action���������̂ǂꂩ�ɓK�����Ȃ��ꍇ�́A�v���O�����~�X
    Default {
            Write-Log -ID $InternalErrorEventID -Type Error -Message "Internal Error at Switch Action section. It may cause a bug in regex."
            Finalize $InternalErrorReturnCode
            }
    }


#Post Action

    Switch -Regex ($PostAction) {

    #����1 �������Ȃ�
    '^none$' {            
            }

    #����2 Rename Rename��̓��ꖼ�̃t�@�C�������݂��Ȃ����Ƃ��m�F���Ă��珈��
    '^Rename$' {
            $newFilePath = $Target.Object.DirectoryName |
                            Join-Path -ChildPath (($Target.Object.Name) -replace "$RegularExpression" , "$RenameToRegularExpression") |
                            ConvertTo-AbsolutePath -Name 'Filename renamed'
                            
            IF ($newFilePath | Test-LeafNotExists) {

                Invoke-Action -ActionType Rename -ActionFrom $Target.Object.FullName -ActionTo $newFilePath -ActionError $Target.Object.FullName
    
                } else {
                Write-Log -ID $InfoEventID -Type Information -Message  ("A file [$($newFilePath)] already exists same as attempting rename, " +
                    "thus do not rename [$($Target.Object.FullName)]")
                }
            }

    #����3 NullClear
    '^NullClear$' {
            Invoke-Action -ActionType NullClear -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName          
            }


    #����4 $Action���������̂ǂꂩ�ɓK�����Ȃ��ꍇ�́A�v���O�����~�X
    Default {
            Write-Log -ID $InternalErrorEventID -Type Error -Message "Internal error at Switch PostAction section. It may cause a bug in regex."
            Finalize $InternalErrorReturnCode
            }
    }



#�ُ�I���Ȃǂ�Break���ăt�@�C�������I�[�֔�����B
}
While($FALSE)


#�ُ�A�x�����m�F�B�ُ�>�x��>����̏��ʂŎ��s���ʐ��J�E���g�A�b�v

    IF ($ErrorFlag) {
        $ErrorCount++
        } elseIF ($WarningFlag) {
            $WarningCount++
            } elseIF ($NormalFlag) {
                $NormalCount++
                }

    IF ($ContinueFlag) {
        $ContinueCount++
        }
         
    Write-Log -ID $InfoLoopEndEventID -Type Information -Message ("--- End processing [$($FilterType)] $($Target.Object.FullName)  " + 
        "Results  Normal[$($NormalFlag)] Warning[$($WarningFlag)] Error[$($ErrorFlag)]  " +
        "Continue[$($ContinueFlag)]  OverRide[$($InLoopOverRideCount)] ---")

    IF ($ForceFinalize) {    
        Finalize $ErrorReturnCode
        }

#�ΏیQ�̏������[�v�I�[
   
}


#�I�����b�Z�[�W�o��

Finalize $NormalReturnCode
