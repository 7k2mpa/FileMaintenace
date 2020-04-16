#Requires -Version 5.0
#If you do not use '-PreAction compress or archive', install WMF 3.0 and place '#Requires -Version 3.0' insted of '#Requires -Version 5.0'
#If you use '-PreAction compress or archive' with 7z, install WMF 3.0 and place '#Requires -Version 3.0' insted of '#Requires -Version 5.0'

<#
.SYNOPSIS
This script processes log files or temp files to delete, move, archive, etc.... with multiple methods.
CommonFunctions.ps1 is required.
You can process files in multiple folders with Wrapper.ps1


ログファイル圧縮、削除を始めとした色々な処理をする万能ツールです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているWrapper.ps1と併用すると複数処理を一括実行できます。


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



対象のフォルダに含まれる、ファイル、フォルダを各種条件でフィルタして選択します。
フィルタ結果をパラメータに基づき、前処理、主処理、後処理します。

フィルタ結果に対して可能な処理は以下です。

-前処理:対象ファイルから別ファイルを生成します。可能な処理は「ファイル名にタイムスタンプ付加」「圧縮」「生成した別ファイルの移動」「複数のファイルを1ファイルにアーカイブ」です。
併用指定可能です。「生成した別ファイルの移動」を指定しないと対象ファイルと同一フォルダに配置します。
-主処理:対象ファイルを「移動」「複製」「削除」「内容消去（ヌルクリア）」、フォルダを「空フォルダ削除」します。
-後処理:対象ファイルを「内容消去（ヌルクリア）」「名称変更」します。

フィルタは「経過日数」「容量」「正規表現」「対象ファイル、フォルダの親パスに含まれる文字の正規表現」で指定できます。

このプログラム単体では、1度に処理できるのは1フォルダです。複数フォルダを処理したい場合は、Wrapper.ps1を併用してください。


ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。

このプログラムはPowerShell 5.0以降が必要です。
Windows Server 2008,2008R2はWMF(Windows Management Framework)5.0以降を追加インストールしてください。それ以前のOSでは稼働しません。

https://docs.microsoft.com/ja-jp/powershell/scripting/install/installing-windows-powershell?view=powershell-7#upgrading-existing-windows-powershell


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -noLog2Console -verbose

Find files in C:\TEST and child folders recuresively.
All logs are not output at console.
You would confirm getting files to process. 

C:\TEST以下のファイルを再帰的に検索だけします（子フォルダも対象）
作業の細かい内容をコンソールに表示しません。
先ずはメンテナンス対象のものが表示されるか確認してみて下さい。


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete

Delete files in C:\TEST and child folders recuresively.

C:\TEST以下のファイルを再帰的に削除します（子フォルダも対象）

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action DeleteEmptyFolders

Delete empty folders in C:\TEST and child folders recuresively.

C:\TEST以下の空フォルダを再帰的に削除します（子フォルダも対象）

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete -noRecurse

Delete files only in C:\TEST non-recuresively.

C:\TEST以下のファイルを非再帰的に削除します（子フォルダは対象外）

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Copy -MoveToFolder C:\TEST1 -Size 10KB -continue

Copy files over than 10KByte to C:\TEST1 recuresively.
If no child foler in the desitination, make the new folder.
If same name file be in the destination, skip copying and continue process a next object.

C:\TEST以下のファイルで10KB以上のものを再帰的にC:\TEST1へ複製します。移動先に子フォルダが無ければ作成します
移動先に同一名称のファイルがあった場合はスキップして処理を継続します

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,AddTimeStamp -Action NullClear

Filter files ending with '.log' and older 10days in C:\TEST recuresively.
Create new files compressed and added time stamp to file name from files filtered.
New files place in the same folder.
The filtered files dose not be deleted, but are null cleared.

C:\TEST以下のファイルを再帰的に 「.logで終わる」ものへファイル名に日付を付加して圧縮します。
元ファイルは残りますが、内容消去（ヌルクリア）します。

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,MoveNewFile -Action Delete -MoveToFolder C:\TEST1 -OverRide -Days 10

Filter files ending with '.log' and older 10days in C:\TEST recuresively.
Create new files compressed and move to C:\TEST1
If same name file exists in the destination, override old one.
The original files are deleted. 

C:\TEST以下のファイルを再帰的に 「.logで終わる」かつ10日以前のものを圧縮後C:\TEST1へ移動します。
移動先に同一名称のものがあった場合は上書きします。
元のファイルは削除します


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


C:\OLD\Log以下のファイルで再帰的に「.logで終わる」ものを削除します。
但し、ファイルのフルパスからC:\OLD\Logを削除したパスに「\OLD\」が含まれるファイルだけが対象になります。正規表現のため、パスに含まれる\（バックスラッシュ）が\（バックスラッシュ）でエスケープされています。
例えば以下のファイル配置ではC:\OLD\Logまではマッチ対象外となりC:\OLD\Log\IIS\Current\Infra.log , C:\OLD\Log\Java\Current\Infra.log , C:\OLD\Log\Infra.logは削除されません。

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


処理対象のファイル、フォルダが格納されているフォルダを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log , ..\Script\log）
ワイルドカード* ? []は使用できません。
フォルダ名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。

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

処理対象のファイルに対する操作を設定します。以下のパラメータを指定して下さい。
PreActionは(Action|PostAction)と異なり複数パラメータを指定できます。
パラメータはカンマ,で区切って下さい。

None:何も操作をしません。この設定がデフォルトです。これは誤操作防止のためにあります。動作検証には-WhatIfスイッチを利用して下さい。
Compress:対象ファイルから圧縮したファイルを新規生成します。
AddTimeStamp:対象ファイルからファイル名に-TimeStampFormatで定められた書式でタイムスタンプ付加したファイルを新規生成します。
Archive:対象ファイル群をまとめた1アーカイブファイルを新規生成します。-OverRideを指定すると、既存アーカイブファイルへ対象ファイル群を追加します。アーカイブファイルは-ArchiveFileNameで指定したファイル名です。
MoveNewFile:-PreActionの新規生成ファイルを-TargetFolderと同一ではなく、-MoveToFolderへ配置します。
7z:Compress,Archiveに使用する圧縮に7z.exeを用います。圧縮方法は7z.exeの標準LZMA2を用います。
7zZip:Compress,Archiveに使用する圧縮に7z.exeを用います。圧縮方法はZip(Deflate)を用います。

.PARAMETER Action

Specify method to process files.

None:Do nothing, and is default. If you want to test the action, specify -WhatIf or -Confirm option.
Move:Move the files to -MoveNewFolder path.
Delete:Delete the files.
Copy:Copy the files and place in -MoveNewFolder path.
DeleteEmptyFolders:Delete empty folders.
KeepFilesCount:Delete old generation files.
NullClear:Clear the files with null.

処理対象のファイルに対する操作を設定します。以下のパラメータを指定して下さい。

None:何も操作をしません。この設定がデフォルトです。これは誤操作防止のためにあります。動作検証には-WhatIfスイッチを利用して下さい。
Move:ファイルを-MoveToFolderへ移動します。
Delete:ファイルを削除します。
Copy:ファイルを-MoveToFolderにコピーします。
DeleteEmptyFolders:空フォルダを削除します。
KeepFilesCount:指定世代数になるまで、マッチしたファイル群を古い順に削除します。
NullClear:ファイルの内容削除 NullClearします。

.PARAMETER PostAction

Specify method to process files.

None:Do nothing, and is default. If you want to test the action, specify -WhatIf or -Confirm option.
Rename:Rename the files with -RenameToRegularExpression
NullClear:Clear the files with null.


処理対象のファイルに対する操作を設定します。以下のパラメータを指定して下さい。

None:何も操作をしません。この設定がデフォルトです。これは誤操作防止のためにあります。動作検証には-WhatIfスイッチを利用して下さい。
Rename:ファイル名を正規表現-RenameToRegularExpressionで置換します。
NullClear:ファイルの内容削除 NullClearします。PostActionのため、Actionと併用可能です。例えばファイル複製後、元ファイルを削除する、といった用途に使用して下さい。


.PARAMETER MoveToFolder

Specify a desitination folder of the target files moved to.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


　処理対象のファイルの移動、コピー先フォルダを指定します。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log , ..\Script\log）
ワイルドカード* ? []は使用できません。
フォルダ名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。

.PARAMETER ArchiveFileName

Specify the file name of the archive file with -PreAction Archive option.
Specify it without extension.
Extension strings will be added automatically with archive method.

-PreAction Archive指定時のアーカイブファイル名を指定します。


.PARAMETER 7zFolder 

Specify a folder of 7-Zip installed.
[C:\Program Files\7-Zip] is default.

Compress,Archiveに外部プログラム7z.exeを使用する際に、7-Zipがインストールされているフォルダを指定します。
デフォルトは[C:\Program Files\7-Zip]です。

.PARAMETER Days
Specify how many days older than today to process files.
0 day is default and, process all files.

　処理対象のファイル、フォルダを更新経過日数でフィルタします。
デフォルトは0日で全てのファイルが対象となります。

.PARAMETER Size

Specify size of files to process.
0 byte is default, and process all files.
Units of KB,MB,GB are accepted.

　処理対象のファイルを容量でフィルタします。
デフォルトは0KBで全てのファイルが対象となります。
整数表記に加えて、KB,MB,GBの接尾辞が利用可能です。
例えば-Size 10MBは、自動的に10*1024^6に換算してくれます。

.PARAMETER RegularExpression

Specify regular expression to match processing files.
'.*' is default, and process all files.

　処理対象のファイル、フォルダを正規表現でフィルタします。
デフォルトは .* で全てが対象となります。
記述はシングルクオーテーションで括って下さい。
PowerShellの仕様上、大文字小文字の区別はしない筈ですが、実際には区別されるので注意して下さい。

.PARAMETER ParentRegularExpression

Specify regular expression to match processing path of the files excluding -TargetFolder.
'.*' is default, and process all files.

　処理対象のファイル、フォルダの上位パスから-TargetFolderのパスまでを正規表現でフィルタします。-TargetFolderに含まれるパスはフィルタ対象外です。
デフォルトは .* で全てが対象となります。
記述はシングルクオーテーションで括って下さい。
PowerShellの仕様上、大文字小文字の区別はしない筈ですが、実際には区別されるので注意して下さい。

.PARAMETER RenameToRegularExpression

Specify regular expression for rename rule.

https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/substitutions-in-regular-expressions

-PostAction Renameを指定した場合のファイル名正規表現置換規則を指定します。
-RegularExpressionに対する置換パターンを指定します。
https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/substitutions-in-regular-expressions


.PARAMETER Recurse
Specify to process the files or folders in the path recursively or non-recuresively.
[$TRUE(recuresively)] is default.

　-TargetFolderの直下の再帰的または非再帰に処理の指定が可能です。
デフォルトは$TRUEで再帰的処理です。

.PARAMETER NoRecurse
Specify if you want to filter files non-recursively.
The option override -Recurse option.

　-TargetFolderの直下のみを処理対象とします。-Recurse $FALSEと等価です。
Recurseパラメータより優先します。

.PARAMETER OverRide
Specify if you want to override old same name files moved or copied.
[terminate with an Error and do not override] is default.

　移動、コピー先に既に同名のファイルが存在しても強制的に上書きします。
デフォルトでは上書きせずに異常終了します。

.PARAMETER Continue
Specify if you want to skip the process when old files existed and to process remains.
If skip the process, process remains and terminate with a Warning.
[terminate with an Error immediately and do not skip] is default. 

　移動、コピー先に既に同名のファイルが存在した場合当該ファイルの処理をスキップします。
スキップすると警告終了します。
デフォルトではスキップせずに異常終了します。

.PARAMETER ContinueAsNormal
Specify if you want to skip old files do not want to override.
If has skip to process, exit successfully.
[terminate with an Error immediately and do not skip] is default. 

　移動、コピー先に既に同名のファイルが存在した場合当該ファイルの処理をスキップします。
-Continueと異なりスキップしても正常終了します。ファイルの差分コピー等で利用してください。
-Continueに優先します。
デフォルトではスキップせずに異常終了します。


.PARAMETER NoneTargetAsWarning
Specify if you want to terminate with a Warning when no file exists in the folder.
[exit with Normal when no file exists in the folder] is default.

操作対象のファイル、フォルダが存在しない場合に警告終了します。
このスイッチを設定しないと存在しない場合は通常終了します。


.PARAMETER CompressedExtString
Specify file extention strings in specifing -PreAction Compress option.
[.zip] is default.

　-PreAction Compress指定時のファイル拡張子を指定できます。
デフォルトは[.zip]です。

.PARAMETER TimeStampFormat
Specify time stamp format in specifing -PreAction AddTimeStamp option
[_yyyyMMdd_HHmmss] is default.
It is deffernt from time stamp format of script log.


　-PreAction AddTimeStamp指定時の書式を指定できます。
デフォルトは[_yyyyMMdd_HHmmss]です。

.PARAMETER KeepFiles
Specify how many newer files in the folder to keep with -Action KeepFileCount option.
[1] is default.

-Action KeepFilesCount指定時の世代数を指定します。
デフォルトは1です。

.PARAMETER Compress
Planed to obsolute.
use -PreAction Compress

このパラメータは廃止予定です。後方互換性のために残していますが、-PreAction Compressを使用してください。
対象ファイルを圧縮して別ファイルとして保存します。

.PARAMETER AddTimeStamp
Planed to obsolute.
use -PreAction AddTimeStamp


このパラメータは廃止予定です。後方互換性のために残していますが、-PreAction AddTimeStampを使用してください。
対象ファイル名に日時を付加して別ファイルとして保存します。

.PARAMETER MoveNewFile
Planed to obsolute.
use -PreAction MoveNewFile

このパラメータは廃止予定です。後方互換性のために残していますが、-PreAction MoveNewFileを使用してください。
-PreAction Compress , AddTimeStampを指定した際に生成される別ファイルを-MoveToFolderの指定先に保存します。
デフォルトは対象ファイルと同一ディレクトリへ保存します。

.PARAMETER NullOriginalFile
Planed to obsolute.
use -PostAction NullClear or -Action NullClear

このパラメータは廃止予定です。後方互換性のために残していますが、-PostAction NullClearまたは-Action NullClearを使用してください。
対象ファイルの内容消去（ヌルクリア）します。
-PostAction NullClearと等価です。



.PARAMETER Log2EventLog

Specify if you want to output log to Windows Event Log.
[$TRUE] is default.

　Windows Event Logへの出力を制御します。
デフォルトは$TRUEでEvent Log出力します。

.PARAMETER NoLog2EventLog
Specify if you want to suppress log to Windows Event Log.
Specification override -Log2EventLog

　Event Log出力を抑止します。-Log2EventLog $FALSEと等価です。
Log2EventLogより優先します。

.PARAMETER ProviderName

Specify provider name of Windows Event Log.
[Infra] is default.


　Windows Event Log出力のプロバイダ名を指定します。
デフォルトは[Infra]です。

.PARAMETER EventLogLogName

Specify log name of Windows Event Log.
[Application] is default.

　Windows Event Log出力のログ名を指定します。
デフォルトは[Application]です。

.PARAMETER Log2Console

Specify if you want to output log to PowerShell console.
[$TRUE] is default.

　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2Console

　コンソールログ出力を抑止します。-Log2Console $FALSEと等価です。
Log2Consoleより優先します。

.PARAMETER Log2File

Specify if you want to output log to text log.
[$FALSE] is default.

　ログフィルへの出力を制御します。
デフォルトは$FALSEでログファイル出力しません。

.PARAMETER NoLog2File

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2File

　ログファイル出力を抑止します。-Log2File $FALSEと等価です。
Log2Fileより優先します。

.PARAMETER LogPath

Specify the path of text log file.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.
[$NULL] is default.

If the log file dose not exist, make new file.
If the log file exists, write log additionally.

　ログファイル出力パスを指定します。デフォルトは$NULLです。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log\Log.txt , ..\Script\log\log.txt）
ワイルドカード* ? []は使用できません。
フォルダ、ファイル名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。
ファイルが存在しない場合は新規作成します。
ファイルが既存の場合は追記します。

.PARAMETER LogDateFormat

Specicy time stamp format in the text log.
[yyyy-MM-dd-HH:mm:ss] is default.

　ログファイル出力に含まれる日時表示フォーマットを指定します。
デフォルトは[yyyy-MM-dd-HH:mm:ss]形式です。

.PARAMETER LogFileEncode

Specify the character encode in the log file.
[Default] is default and it works as ShiftJIS.


ログファイルの文字コードを指定します。
デフォルトはShift-JISです。

.PARAMETER NormalReturnCode

Specify Normal Return code.
[0] is default.
Must specify NormarReturnCode =< WarningReturnCode =< ErrorReturnCode(InternalErrorReturnCode)


　正常終了時のリターンコードを指定します。デフォルトは0です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER WarningReturnCode

Specify Warning Return code.
[1] is default.
Must specify NormarReturnCode =< WarningReturnCode =< ErrorReturnCode(InternalErrorReturnCode)

　警告終了時のリターンコードを指定します。デフォルトは1です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER ErrorReturnCode

Specify Error Return code.
[8] is default.
Must specify NormarReturnCode =< WarningReturnCode =< ErrorReturnCode(InternalErrorReturnCode)

　異常終了時のリターンコードを指定します。デフォルトは8です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER InternalErrorReturnCode

Specify Internal Error Return code.
[16] is default.
Must specify NormarReturnCode =< WarningReturnCode =< ErrorReturnCode(InternalErrorReturnCode)

　プログラム内部異常終了時のリターンコードを指定します。デフォルトは16です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER InfoEventID

Specify information event id in the log.
[1] is default.


.PARAMETER InfoLoopStartEventID

Specify start loop event id in the log.
[2] is default.


　Event Log出力でファイル/フォルダ処理開始のInformationに対するEvent IDを指定します。デフォルトは2です。

.PARAMETER InfoLoopEndEventID

Specify end loop event id in the log.
[3] is default.

　Event Log出力でファイル/フォルダ処理終了のInformationに対するEvent IDを指定します。デフォルトは3です。

.PARAMETER WarningEventID


Specify Warning event id in the log.
[10] is default.


　Event Log出力でWarningに対するEvent IDを指定します。デフォルトは10です。

.PARAMETER SuccessEventID

Specify Successfully complete event id in the log.
[73] is default.

　Event Log出力でSuccessに対するEvent IDを指定します。デフォルトは73です。

.PARAMETER InternalErrorEventID

Specify Internal Error event id in the log.
[99] is default.

　Event Log出力でInternal Errorに対するEvent IDを指定します。デフォルトは99です。

.PARAMETER ErrorEventID

Specify Error event id in the log.
[100] is default.

　Event Log出力でErrorに対するEvent IDを指定します。デフォルトは100です。

.PARAMETER ErrorAsWarning

Specfy if you want to return WARNING exit code when the script terminate with an Error.

　異常終了しても警告終了のReturnCodeを返します。

.PARAMETER WarningAsNormalaaaaaaa

Specify if you want to return NORMAL exit code when the script terminate with a Warning.

　警告終了しても正常終了のReturnCodeを返します。

.PARAMETER ExecutableUser

Specify the user who is allowed to execute the script in regular expression.
[.*] is default and all users are allowed to execute.
Parameter must be quoted with single quote'
Escape the back slash in the separeter of a domain name.
example [domain\\.*]

　このプログラムを実行可能なユーザを正規表現で指定します。
デフォルトは[.*]で全てのユーザが実行可能です。　
記述はシングルクオーテーションで括って下さい。
正規表現のため、ドメインのバックスラッシュは[domain\\.*]の様にバックスラッシュでエスケープして下さい。　

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

    #CommonFunctions.ps1の配置先を変更した場合は、ここを変更。同一フォルダに配置前提
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
　指定したパスにファイルが存在しない事を確認する

.INPUT
　Strings of File Path

.OUTPUT
　Boolean
1    チェック対象のファイルが存在するが、-OverRideを指定...$TRUE, $OverRideFlag = $TRUE（この指定は-Continueに優先する）なおInvoke-Actionは既にファイルが存在する場合は強制上書き
2    チェック対象のファイルが存在するが、-Continueを指定...$FALSE, $ContinueFlag = $TRUE 
3    チェック対象のファイルが存在する...$ErrorReturnCode でFinalize, $FroceEndLoop=$TRUE ならば$FALSE, $ForceFinalize=$TRUE
4    チェック対象の同一名称のフォルダが存在するが、-OverRideを指定...上書きが出来ないので$ErrorReturnCode でFinalize, $FroceEndLoop=$TRUE ならば$FALSE, $ForceFinalize=$TRUE
5    チェック対象と同一名称のフォルダが存在するが、-Continueを指定...$FALSE
6    チェック対象と同一名称のフォルダが存在する...$ErrorReturnCode でFinalize, $FroceEndLoop=$TRUE ならば$FALSE, $ForceFinalize=$TRUE
7    チェック対象のファイル、フォルダが存在しない...$TRUE
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
　オブジェクトを複数条件でフィルタ、適合するものだけをOUTPUT

.DESCRIPTION
最終変更日時が$Daysより古い
(ファイル|フォルダ)名が正規表現$RegularExpressionにマッチ
ファイル容量が $Sizeより大きい
C:\TargetFolder                    :TargetFolder
C:\TargetFolder\A\B\C\target.txt   :TargetObject
上記の時\A\B\C\部分が正規表現$ParentRegularExpressionにマッチ

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
　指定フォルダからオブジェクト群（ファイル|フォルダ）を抽出

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

#一部のActionはObjectを特定の順序で処理するため、必要に応じてソートする

    Switch -Regex ($Action) {
 
        #KeepFilesCount配列に入れたパス一式を古い順に整列
        '^KeepFilesCount$' {
            Write-Output $objects | Sort-Object -Property Time
            }

        #DeleteEmptyFolders配列に入れたパス一式をパスが深い順に整列。空フォルダが空フォルダに入れ子になっている場合、深い階層から削除する必要がある。
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

        #$PreActionは配列である。それをSwitch処理すると1要素づつループする。
        #'Compress'等は一旦Defaultに落ちるが、'7z' or '7zZip'があれば$ActionTypeは上書きされる

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

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. Invoke-PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い

#Switch処理

IF ($NoRecurse)        {[Boolean]$Script:Recurse = $FALSE}
IF ($ContinueAsNormal) {[Switch]$Script:Continue = $TRUE}

#For Backward Compatibility

IF ($NullOriginalFile) {[String]$Script:PostAction = 'NullClear'}
IF ($AddTimeStamp) {$Script:PreAction +='AddTimeStamp'}
IF ($MoveNewFile)  {$Script:PreAction +='MoveNewFile'}
IF ($Compress)     {$Script:PreAction +='Compress'}

#パラメータの確認


#指定フォルダの有無を確認
#Test-Container functionは$TRUE,$FALSEが戻値なので$NULLへ捨てる。捨てないとコンソール出力される

    $TargetFolder = $TargetFolder | ConvertTo-AbsolutePath -Name '-TargetFolder'

    $TargetFolder | Test-Container -Name '-TargetFolder' -IfNoExistFinalize > $NULL


#移動先フォルダの要不要と有無を確認

    IF (($Action -match "^(Move|Copy)$") -or ($PreAction -contains 'MoveNewFile')) {    

        $MoveToFolder = $MoveToFolder | ConvertTo-AbsolutePath -Name '-MoveToFolder'
    
        $MoveToFolder | Test-Container -Name '-MoveToFolder' -IfNoExistFinalize > $NULL
       
    } elseIF (-not($MoveToFolder | Test-PathNullOrEmpty)) {
    
        Write-Log -ID $ErrorEventID -Type Error -Message "Specified -Action [$($Action)] option, must not specifiy -MoveToFolder option."
        Finalize $ErrorReturnCode
        }


#ArchiveFileNameの要不要と有無、Validation

    IF ($PreAction -contains 'Archive') {

        $ArchiveFileName | Test-PathNullOrEmpty -Name '-ArchiveFileName' -IfNullOrEmptyFinalize > $NULL
        
        IF ($ArchiveFileName -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Write-Log -Type Error -ID $ErrorEventID -Message "-ArchiveFileName may contain characters that can not use by NTFS."
                Finalize $ErrorReturnCode
                } 
        }


#7zフォルダの要不要と有無を確認

    IF ($PreAction -match "^(7z|7zZip)$") {    

        $7zFolder = $7zFolder | ConvertTo-AbsolutePath -Name '-7zFolder'

        $7zFolder | Test-Container -Name '-7zFolder' -IfNoExistFinalize > $NULL
        }

#組み合わせが不正な指定を確認


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



#処理開始メッセージ出力


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
                
                #$PreActionは配列なのでSwitchで処理すると複数回実行されるので、IFで処理
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

[Boolean]$ForceEndloop  = $FALSE          ;#$FALSEではFinalize , $TRUEではループ内でBreak

#$VerbosePreference = 'Continue'
#初期設定、パラメータ確認、起動メッセージ出力

. Initialize


#対象のフォルダまたはファイルを探して配列に入れる

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

#-PreAction Archiveは複数ファイルを1ファイルに圧縮する。よって、ループ前に圧縮先の1ファイルのフルパスを確定しておく

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


#対象フォルダorファイル群の処理ループ

ForEach ($Target in $targets) {
<#
PowershellはGOTO文が存在せず処理分岐ができない。
そのためDo/Whileを用いて処理途中でエラーが発生した場合の分岐を実装している

Do/While()は最後に評価が行われるループ。最後の評価がFalseとなるとループを終了する。ここでWhile($FALSE)としてあるので、
Do/Whileの間は1回だけ実行される。
Do/Whileはループのため、処理途中でBreakすると、Whileへjumpする。

ファイル群処理ループ中のエラー（例えば、ファイルをDelete試行したが、権限が無くて削除できない等）で想定される処理、指定方法は以下である。

1.While以降の処理終了メッセージ出力へJumpして、次のファイルを処理継続
 Break , $ForceEndloog = $TRUE , $ForceFinalize = $FALSE 
2.While以降の処理終了メッセージ出力へJumpして、次のファイルは処理せずにFinalizeへ進む（処理打ち切り）
 Break , $ForceEndloog = $TRUE , $ForceFinalize = $TRUE
3.処理終了メッセージ出力しない。Finalizeへ進む（処理打ち切り）
 Finalize $ErrorReturnCode
#>

Do {

[Boolean]$ErrorFlag     = $FALSE
[Boolean]$WarningFlag   = $FALSE
[Boolean]$NormalFlag    = $FALSE
[Boolean]$OverRideFlag  = $FALSE
[Boolean]$ContinueFlag  = $FALSE
[Boolean]$ForceFinalize = $FALSE          ;#$TRUEが戻ったらオブジェクト処理ループを強制終了
[Int]$InLoopOverRideCount = 0    ;#$OverRideCountは処理全体のOverRide回数。$InLoopOverRideCountは1処理ループ内でのOverRide回数。1オブジェクトで複数回OverRideがあり得るため

[Boolean]$ForceEndloop  = $TRUE   ;#このループ内で異常終了する時はループ終端へBreakして、処理結果を表示する。直ぐにFinalizeしない

Write-Log -ID $InfoLoopStartEventID -Type Information -Message "--- Start processing [$($FilterType)] $($Target.Object.FullName) ---"


#移動元のファイルパスから移動先のファイルパスを生成。
#再帰的でなければ、移動先パスは確実に存在するのでスキップ

#Action[(Move|Copy)]以外はファイル移動が無い。移動先パスを確認する必要がないのでスキップ
#PreAction[Archive]はMoveNewFile[TRUE]でも出力ファイルは1個で階層構造を取らない。よってスキップ

    IF ( ($Action -match "^(Move|Copy)$") -or (($PreAction -contains 'MoveNewFile') -and ($PreAction -notcontains 'Archive')) ) {

        #ファイルが移動するAction用にファイル移動先の親フォルダパス$MoveToNewFolderを生成する
        
        #C:\TargetFolder                    :TargetFolder
        #C:\TargetFolder\A\B\C              :TargetFileParentFolder
        #C:\TargetFolder\A\B\C\target.txt   :TargetFile
        #D:\MoveToFolder                    :MoveToFolder
        #D:\MoveToFolder\A\B\C              :MoveToNewFolder

        #D:\MoveToFolder\A\B\C\target.txt   :ファイルの移動先パス

        #destinationFolderを作るには \A\B\C\　の部分を取り出して、移動先フォルダMoveToFolderとJoin-Pathする
        #String.Substringメソッドは文字列から、引数位置から最後までを取り出す
        #destinationFolderはNoRecurseでもMove|Copyで一律使用するので作成

        $destinationFolder = $MoveToFolder | Join-Path -ChildPath ($Target.Object.DirectoryName).Substring($TargetFolder.Length)
        IF ($Recurse) {

            IF (-not($destinationFolder | Test-Container -Name 'Desitination folder of the file ')) {

                Write-Log -ID $InfoEventID -Type Information -Message "Create a new folder $($destinationFolder)"

                Invoke-Action -ActionType MakeNewFolder -ActionFrom $destinationFolder -ActionError $destinationFolder

                #$Invoke-Actionが異常終了&-Continue $TRUEだと$ContinueFlag $TRUEになるので、その場合は後続処理はしないで次のObject処理に進む
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

    #分岐1 何もしない
    '^none$' {
            IF ( ($PostAction -eq 'none') -and ($PreAction -contains 'none') ) {

                Write-Log -ID $InfoEventID -Type Information -Message ("Specified -Action [$($Action)] option, " +
                    "thus do not process $($Target.Object.FullName)")
                }
            }

    #分岐2 削除
    '^Delete$' {
            Invoke-Action -ActionType Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName
            } 

    #分岐3 移動 or 複製 　同一のファイルが（移動|複製先）に存在しないことを確認してから処理
    '^(Move|Copy)$' {
            $destinationPath = $destinationFolder | Join-Path -ChildPath ($Target.Object.Name)

            IF ($destinationPath | Test-LeafNotExists) {

                Invoke-Action -ActionType $Action -ActionFrom $Target.Object.FullName -ActionTo $destinationPath -ActionError $Target.Object.FullName 
                }
            }

    #分岐4 空フォルダを判定して削除
    '^DeleteEmptyFolders$' {
            Write-Log -ID $InfoEventID -Type Information -Message  "Check the folder $($Target.Object.FullName) is empty."

            IF ($Target.Object.GetFileSystemInfos().Count -eq 0) {

                Write-Log -ID $InfoEventID -Type Information -Message  "The folder $($Target.Object.FullName) is empty."
                Invoke-Action -ActionType Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName

                } else {
                Write-Log -ID $InfoEventID -Type Information -Message "The folder $($Target.Object.FullName) is not empty." 
                }
            }


    #分岐5 NullClear
    '^NullClear$' {
            Invoke-Action -ActionType NullClear -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName          
            }

    #分岐6 KeepFilesCount
    '^KeepFilesCount$' {
            IF ((@($targets).Length - $InLoopDeletedFilesCount) -gt $KeepFiles) {

                Write-Log -ID $InfoEventID -Type Information -Message  ("More than [$($KeepFiles)] files exist in the folder, " +
                    "thus delete the oldest [$($Target.Object.FullName)]")

                Invoke-Action -ActionType Delete -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName

                #$Invoke-Actionが異常終了&-Continue $TRUEだと$ContinueFlag $TRUEになるので、その場合は後続処理はしないで次のObject処理に進む
                IF ($ContinueFlag) {
                    Break                
                    }
                $InLoopDeletedFilesCount++
            
                } else {
                Write-Log -ID $InfoEventID -Type Information -Message  ("Less [$($KeepFiles)] files exist in the folder, " +
                    "thus do not delete [$($Target.Object.FullName)]")
                }
            }

    #分岐7 $Actionが条件式のどれかに適合しない場合は、プログラムミス
    Default {
            Write-Log -ID $InternalErrorEventID -Type Error -Message "Internal Error at Switch Action section. It may cause a bug in regex."
            Finalize $InternalErrorReturnCode
            }
    }


#Post Action

    Switch -Regex ($PostAction) {

    #分岐1 何もしない
    '^none$' {            
            }

    #分岐2 Rename Rename後の同一名称ファイルが存在しないことを確認してから処理
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

    #分岐3 NullClear
    '^NullClear$' {
            Invoke-Action -ActionType NullClear -ActionFrom $Target.Object.FullName -ActionError $Target.Object.FullName          
            }


    #分岐4 $Actionが条件式のどれかに適合しない場合は、プログラムミス
    Default {
            Write-Log -ID $InternalErrorEventID -Type Error -Message "Internal error at Switch PostAction section. It may cause a bug in regex."
            Finalize $InternalErrorReturnCode
            }
    }



#異常終了などはBreakしてファイル処理終端へ抜ける。
}
While($FALSE)


#異常、警告を確認。異常>警告>正常の順位で実行結果数カウントアップ

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

#対象群の処理ループ終端
   
}


#終了メッセージ出力

Finalize $NormalReturnCode
