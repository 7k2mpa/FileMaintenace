#Requires -Version 5.0
#If you do not use '-PreAction compress or archive' without 7z in FileMaintenance.ps1, you will be able to use '-Version 3.0' insted of  '-Version 5.0'

<#
.SYNOPSIS
This script processes log files to delete, move, archive, etc.... with multi functions.
CommonFunctions.ps1 is required.
You can process log files in multiple folders with Wrapper.ps1
<Common Parameters> is not supported.


ログファイル圧縮、削除を始めとした色々な処理をする万能ツールです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているWrapper.ps1と併用すると複数処理を一括実行できます。

<Common Parameters>はサポートしていません

.DESCRIPTION
This script filters files and folders with multiple criterias.
Process the files and filders filtered.


対象のフォルダに含まれる、ファイル、フォルダを各種条件でフィルタして選択します。
フィルタ結果をパラメータに基づき、前処理、主処理、後処理します。

フィルタ結果に対して可能な処理は以下です。

-前処理:対象ファイルから別ファイルを生成します。可能な処理は「ファイル名にタイムスタンプ付加」「圧縮」「生成した別ファイルの移動」「複数のファイルを1ファイルにアーカイブ」です。併用指定可能です。「生成した別ファイルの移動」を指定しないと対象ファイルと同一フォルダに配置します。
-主処理:対象ファイルを「移動」「複製」「削除」「内容消去（ヌルクリア）」、フォルダを「空フォルダ削除」します。
-後処理:対象ファイルを「内容消去（ヌルクリア）」「名称変更」します。

フィルタは「経過日数」「容量」「正規表現」「対象ファイル、フォルダの親パスに含まれる文字の正規表現」で指定できます。

このプログラム単体では、1度に処理できるのは1フォルダです。複数フォルダを処理したい場合は、Wrapper.ps1を併用してください。


ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。

このプログラムはPowerShell 5.0以降が必要です。
Windows Server 2008,2008R2はWMF(Windows Management Framework)5.0以降を追加インストールしてください。それ以前のOSでは稼働しません。

https://docs.microsoft.com/ja-jp/powershell/scripting/install/installing-windows-powershell?view=powershell-7#upgrading-existing-windows-powershell


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -noLog2Console
C:\TEST以下のファイルを再帰的に検索だけします（子フォルダも対象）
作業の細かい内容をコンソールに表示しません。
先ずはメンテナンス対象のものが表示されるか確認してみて下さい。


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete
C:\TEST以下のファイルを再帰的に削除します（子フォルダも対象）

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action DeleteEmptyFolders
C:\TEST以下の空フォルダを再帰的に削除します（子フォルダも対象）

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Delete -noRecurse
C:\TEST以下のファイルを非再帰的に削除します（子フォルダは対象外）

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Copy -MoveToFolder C:\TEST1 -Size 10KB -continue
C:\TEST以下のファイルで10KB以上のものを再帰的にC:\TEST1へ複製します。移動先に子フォルダが無ければ作成します
移動先に同一名称のファイルがあった場合はスキップして処理を継続します

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,AddTimeStamp -Action NullClear
C:\TEST以下のファイルを再帰的に 「.logで終わる」ものへファイル名に日付を付加して圧縮します。
元ファイルは残りますが、内容消去（ヌルクリア）します。

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -PreAction Compress,MoveNewFile -Action Delete -MoveToFolder C:\TEST1 -OverRide -Days 10

C:\TEST以下のファイルを再帰的に 「.logで終わる」かつ10日以前のものを圧縮後C:\TEST1へ移動します。
移動先に同一名称のものがあった場合は上書きします。
元のファイルは削除します


.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\OLD\Log -RegularExpression '^.*\.log$' -Action Delete -ParentRegularExpression '\\OLD\\'

C:\OLD\Log以下のファイルで再帰的に「.logで終わる」ものを削除します。
但し、ファイルのフルパスからC:\OLD\Logを削除したパスに「\OLD\」が含まれるファイルだけが対象になります。正規表現のため、パスに含まれる\（バックスラッシュ）が\（バックスラッシュ）でエスケープされています。
例えば以下のファイル配置ではC:\OLD\Logまではマッチ対象外となりC:\OLD\Log\IIS\Current\Infra.log , C:\OLD\Log\Java\Current\Infra.log , C:\OLD\Log\Infra.logは削除されません。

C:\OLD\Log\IIS\Current\Infra.log
C:\OLD\Log\IIS\OLD\Infra.log
C:\OLD\Log\Java\Current\Infra.log
C:\OLD\Log\Java\OLD\Infra.log
C:\OLD\Log\Infra.log

 
.PARAMETER TargetFolder
処理対象のファイル、フォルダが格納されているフォルダを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log , ..\Script\log）
ワイルドカード* ? []は使用できません。
フォルダ名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。

.PARAMETER PreAction
処理対象のファイルに対する操作を設定します。以下のパラメータを指定して下さい。
PreActionは(Action|PostAction)と異なり複数パラメータを指定できます。
パラメータはカンマ,で区切って下さい。

None:何も操作をしません。この設定がデフォルトです。これは誤操作防止のためにあります。動作検証には-NoActionスイッチを利用して下さい。
Compress:対象ファイルから圧縮したファイルを新規生成します。
AddTimeStamp:対象ファイルからファイル名に-TimeStampFormatで定められた書式でタイムスタンプ付加したファイルを新規生成します。
Archive:対象ファイル群をまとめた1アーカイブファイルを新規生成します。-OverRideを指定すると、既存アーカイブファイルへ対象ファイル群を追加します。アーカイブファイルは-ArchiveFileNameで指定したファイル名です。
MoveNewFile:-PreActionの新規生成ファイルを-TargetFolderと同一ではなく、-MoveToFolderへ配置します。
7z:Compress,Archiveに使用する圧縮に7z.exeを用います。圧縮方法は7z.exeの標準LZMA2を用います。
7zZip:Compress,Archiveに使用する圧縮に7z.exeを用います。圧縮方法はZip(Deflate)を用います。

.PARAMETER Action
処理対象のファイルに対する操作を設定します。以下のパラメータを指定して下さい。

None:何も操作をしません。この設定がデフォルトです。これは誤操作防止のためにあります。動作検証には-NoActionスイッチを利用して下さい。
Move:ファイルを-MoveToFolderへ移動します。
Delete:ファイルを削除します。
Copy:ファイルを-MoveToFolderにコピーします。
DeleteEmptyFolders:空フォルダを削除します。
KeepFilesCount:指定世代数になるまで、マッチしたファイル群を古い順に削除します。
NullClear:ファイルの内容削除 NullClearします。

.PARAMETER PostAction
処理対象のファイルに対する操作を設定します。以下のパラメータを指定して下さい。

None:何も操作をしません。この設定がデフォルトです。これは誤操作防止のためにあります。動作検証には-NoActionスイッチを利用して下さい。
Rename:ファイル名を正規表現-RenameToRegularExpressionで置換します。
NullClear:ファイルの内容削除 NullClearします。PostActionのため、Actionと併用可能です。例えばファイル複製後、元ファイルを削除する、といった用途に使用して下さい。


.PARAMETER MoveToFolder
　処理対象のファイルの移動、コピー先フォルダを指定します。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log , ..\Script\log）
ワイルドカード* ? []は使用できません。
フォルダ名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。

.PARAMETER ArchiveFileName
-PreAction Archive指定時のアーカイブファイル名を指定します。


.PARAMETER 7zFolder 
Compress,Archiveに外部プログラム7z.exeを使用する際に、7-Zipがインストールされているフォルダを指定します。
デフォルトは[C:\Program Files\7-Zip]です。

.PARAMETER Days
　処理対象のファイル、フォルダを更新経過日数でフィルタします。
デフォルトは0日で全てのファイルが対象となります。

.PARAMETER Size
　処理対象のファイルを容量でフィルタします。
デフォルトは0KBで全てのファイルが対象となります。
整数表記に加えて、KB,MB,GBの接尾辞が利用可能です。
例えば-Size 10MBは、自動的に10*1024^6に換算してくれます。

.PARAMETER RegularExpression
　処理対象のファイル、フォルダを正規表現でフィルタします。
デフォルトは .* で全てが対象となります。
記述はシングルクオーテーションで括って下さい。
PowerShellの仕様上、大文字小文字の区別はしない筈ですが、実際には区別されるので注意して下さい。

.PARAMETER ParentRegularExpression
　処理対象のファイル、フォルダの上位パスから-TargetFolderのパスまでを正規表現でフィルタします。-TargetFolderに含まれるパスはフィルタ対象外です。
デフォルトは .* で全てが対象となります。
記述はシングルクオーテーションで括って下さい。
PowerShellの仕様上、大文字小文字の区別はしない筈ですが、実際には区別されるので注意して下さい。

.PARAMETER RenameToRegularExpression
-PostAction Renameを指定した場合のファイル名正規表現置換規則を指定します。
-RegularExpressionに対する置換パターンを指定します。
https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/substitutions-in-regular-expressions


.PARAMETER Recurse
　-TargetFolderの直下の再帰的または非再帰に処理の指定が可能です。
デフォルトは$TRUEで再帰的処理です。

.PARAMETER NoRecurse
　-TargetFolderの直下のみを処理対象とします。-Recurse $FALSEと等価です。
Recurseパラメータより優先します。

.PARAMETER OverRide
　移動、コピー先に既に同名のファイルが存在しても強制的に上書きします。
デフォルトでは上書きせずに異常終了します。

.PARAMETER Continue
　移動、コピー先に既に同名のファイルが存在した場合当該ファイルの処理をスキップします。
スキップすると警告終了します。
デフォルトではスキップせずに異常終了します。

.PARAMETER ContinueAsNormal
　移動、コピー先に既に同名のファイルが存在した場合当該ファイルの処理をスキップします。
-Continueと異なりスキップしても正常終了します。ファイルの差分コピー等で利用してください。
-Continueに優先します。
デフォルトではスキップせずに異常終了します。

.PARAMETER NoAction
ファイル、フォルダを実際に削除等の操作をせずに実行します。全ての処理は成功扱いになります。
動作確認するときに当該スイッチを指定してください。
ログ上は警告が出力されますが、実行結果ではこの警告は無視されます。

.PARAMETER NoneTargetAsWarning
操作対象のファイル、フォルダが存在しない場合に警告終了します。
このスイッチを設定しないと存在しない場合は通常終了します。


.PARAMETER CompressedExtString
　-PreAction Compress指定時のファイル拡張子を指定できます。
デフォルトは[.zip]です。

.PARAMETER TimeStampFormat
　-PreAction AddTimeStamp指定時の書式を指定できます。
デフォルトは[_yyyyMMdd_HHmmss]です。

.PARAMETER KeepFiles
-Action KeepFilesCount指定時の世代数を指定します。
デフォルトは1です。

.PARAMETER Compress
このパラメータは廃止予定です。後方互換性のために残していますが、-PreAction Compressを使用してください。
対象ファイルを圧縮して別ファイルとして保存します。

.PARAMETER AddTimeStamp
このパラメータは廃止予定です。後方互換性のために残していますが、-PreAction AddTimeStampを使用してください。
対象ファイル名に日時を付加して別ファイルとして保存します。

.PARAMETER MoveNewFile
このパラメータは廃止予定です。後方互換性のために残していますが、-PreAction MoveNewFileを使用してください。
-PreAction Compress , AddTimeStampを指定した際に生成される別ファイルを-MoveToFolderの指定先に保存します。
デフォルトは対象ファイルと同一ディレクトリへ保存します。

.PARAMETER NullOriginalFile
このパラメータは廃止予定です。後方互換性のために残していますが、-PostAction NullClearまたは-Action NullClearを使用してください。
対象ファイルの内容消去（ヌルクリア）します。
-PostAction NullClearと等価です。



.PARAMETER Log2EventLog
　Windows Event Logへの出力を制御します。
デフォルトは$TRUEでEvent Log出力します。

.PARAMETER NoLog2EventLog
　Event Log出力を抑止します。-Log2EventLog $FALSEと等価です。
Log2EventLogより優先します。

.PARAMETER ProviderName
　Windows Event Log出力のプロバイダ名を指定します。
デフォルトは[Infra]です。

.PARAMETER EventLogLogName
　Windows Event Log出力のログ名を指定します。
デフォルトは[Application]です。

.PARAMETER Log2Console 
　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console
　コンソールログ出力を抑止します。-Log2Console $FALSEと等価です。
Log2Consoleより優先します。

.PARAMETER Log2File
　ログフィルへの出力を制御します。
デフォルトは$FALSEでログファイル出力しません。

.PARAMETER NoLog2File
　ログファイル出力を抑止します。-Log2File $FALSEと等価です。
Log2Fileより優先します。

.PARAMETER LogPath
　ログファイル出力パスを指定します。デフォルトは$NULLです。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log\Log.txt , ..\Script\log\log.txt）
ワイルドカード* ? []は使用できません。
フォルダ、ファイル名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。
ファイルが存在しない場合は新規作成します。
ファイルが既存の場合は追記します。

.PARAMETER LogDateFormat
　ログファイル出力に含まれる日時表示フォーマットを指定します。
デフォルトは[yyyy-MM-dd-HH:mm:ss]形式です。

.PARAMETER LogFileEncode
ログファイルの文字コードを指定します。
デフォルトはShift-JISです。

.PARAMETER NormalReturnCode
　正常終了時のリターンコードを指定します。デフォルトは0です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER WarningReturnCode
　警告終了時のリターンコードを指定します。デフォルトは1です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER ErrorReturnCode
　異常終了時のリターンコードを指定します。デフォルトは8です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER InternalErrorReturnCode
　プログラム内部異常終了時のリターンコードを指定します。デフォルトは16です。正常終了=<警告終了=<（内部）異常終了として下さい。

.PARAMETER InfoEventID
　Event Log出力でInformationに対するEvent IDを指定します。デフォルトは1です。

.PARAMETER InfoLoopStartEventID
　Event Log出力でファイル/フォルダ処理開始のInformationに対するEvent IDを指定します。デフォルトは2です。

.PARAMETER InfoLoopEndEventID
　Event Log出力でファイル/フォルダ処理終了のInformationに対するEvent IDを指定します。デフォルトは3です。

.PARAMETER WarningEventID
　Event Log出力でWarningに対するEvent IDを指定します。デフォルトは10です。

.PARAMETER SuccessEventID
　Event Log出力でSuccessに対するEvent IDを指定します。デフォルトは73です。

.PARAMETER InternalErrorEventID
　Event Log出力でInternal Errorに対するEvent IDを指定します。デフォルトは99です。

.PARAMETER ErrorEventID
　Event Log出力でErrorに対するEvent IDを指定します。デフォルトは100です。

.PARAMETER ErrorAsWarning
　異常終了しても警告終了のReturnCodeを返します。

.PARAMETER WarningAsNormal
　警告終了しても正常終了のReturnCodeを返します。

.PARAMETER ExecutableUser
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


Param(

[parameter(position=0, mandatory=$TRUE , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$TargetFolder,

#[parameter(position=0, mandatory=$TRUE , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String]$TargetFolder,  #Validation debug用に用意してあります。通常は使わない
#[parameter(position=0, mandatory=$TRUE , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$TargetFolder ,
 

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

#以下スイッチ群は廃止予定
[Switch]$Compress,
[Switch]$AddTimeStamp,
[Switch]$MoveNewFile,
[Switch]$NullOriginalFile,
#以上スイッチ群は廃止予定


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
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis

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

    #CommonFunctions.ps1の配置先を変更した場合は、ここを変更。同一フォルダに配置前提
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "Fail to load CommonFunctions.ps1 Please verfy existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }


################ 設定が必要なのはここまで ##################


################# 共通部品、関数  #######################

function CheckLeafNotExists {

<#
.SYNOPSIS
　指定したパスにファイルが存在しない事を確認する

.INPUT
　Strings of File Path

.OUTPUT
　Boolean
    チェック対象のファイルが存在するが、-OverRideを指定...$TRUE　（この指定は-Continueに優先する）なおTryActionは既にファイルが存在する場合は強制上書き
    チェック対象のファイルが存在するが、-Continueを指定...$FALSE
    チェック対象のファイルが存在する...$ErrorReturnCode でFinalizeへ進む、またはBreak
    チェック対象の同一名称のフォルダが存在するが、-OverRideを指定...上書きが出来ないので$ErrorReturnCode でFinalizeへ進む、またはBreak
    チェック対象と同一名称のフォルダが存在するが、-Continueを指定...$FALSE
    チェック対象と同一名称のフォルダが存在する...$ErrorReturnCode でFinalizeへ進む、またはBreak
    チェック対象のファイル、フォルダが存在しない...$TRUE
#>

Param(
[parameter(mandatory=$TRUE)][String]$CheckLeaf
)

Logging -EventID $InfoEventID -EventType Information -EventMessage "Check existence of $($CheckLeaf)"

    #既にファイルがあるが、OverRide指定は無い。よって、異常終了 or Continue指定ありで継続

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

            #既存ファイルがあるので$FALSEを返してファイル処理させない
            Return $FALSE
            }

      #既にファイルがあるが、OverRide指定がある。よって継続  

     }elseIF ((Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -and ($OverRide)) {

            Logging -EventID $InfoEventID -EventType Information -EventMessage "File $($CheckLeaf) exists already, but specified -OverRide[$OverRide] option,thus override the file."
            $Script:OverRideFlag = $TRUE

            #ここまで来ればファイルが存在しないは確定。同一名称のフォルダが存在する可能性は残っている
            #同一名称のフォルダが存在するとOverRide出来ないので、Continue指定ありの場合は継続。指定なしで異常終了

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

                    #既存フォルダがあるので$FALSEを返してファイル処理させない
                    Return $FALSE
                    }

            
            #同一名称のファイル、フォルダ共に存在しない

            }else{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "File $($CheckLeaf) dose not exist."            
            }

Return $TRUE
}


filter ComplexFilter{

<#
.SYNOPSIS
　オブジェクトを複数条件でフィルタ、適合するものだけをOUTPUT

.DESCRIPTION
$FileTypeの指定に基づき、フォルダ、ファイルを抽出
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
　指定フォルダからオブジェクト群（ファイル|フォルダ）を抽出

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

#フィルタ後のオブジェクト群を配列に入れる
#ソートに備えて必要な情報も配列に追加
 
    ForEach ($object in ($candidateObjects | ComplexFilter))
          
        {
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
            Return ($objects | Sort-Object -Property Time | ForEach-Object {$_.Object.FullName})
            }

        #DeleteEmptyFolders配列に入れたパス一式をパスが深い順に整列。空フォルダが空フォルダに入れ子になっている場合、深い階層から削除する必要がある。
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

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#Switch処理

IF ($NoRecurse) {[Boolean]$Script:Recurse = $FALSE}
IF ($NullOriginalFile) {[String]$Script:PostAction = 'NullClear'}
IF ($ContinueAsNormal) {[Switch]$Script:Continue = $TRUE}

IF ($AddTimeStamp) {$Script:PreAction +='AddTimeStamp'}
IF ($MoveNewFile) {$Script:PreAction +='MoveNewFile'}
IF ($Compress) {$Script:PreAction +='Compress'}

#パラメータの確認


#指定フォルダの有無を確認
#CheckContainer functionは$TRUE,$FALSEが戻値なので$NULLへ捨てる。捨てないとコンソール出力される

    $TargetFolder = ConvertToAbsolutePath -CheckPath $TargetFolder -ObjectName  '-TargetFolder'

    CheckContainer -CheckPath $TargetFolder -ObjectName '-TargetFolder' -IfNoExistFinalize > $NULL


#移動先フォルダの要不要と有無を確認

    If ( ($Action -match "^(Move|Copy)$") -or ($PreAction -contains 'MoveNewFile') ) {    

        $MoveToFolder = ConvertToAbsolutePath -CheckPath $MoveToFolder -ObjectName '-MoveToFolder'

        CheckContainer -CheckPath $MoveToFolder -ObjectName '-MoveToFolder' -IfNoExistFinalize > $NULL
 
       
     }elseIF (-not (CheckNullOrEmpty -CheckPath $MoveToFolder)) {
                Logging -EventID $ErrorEventID -EventType Error -EventMessage "Specified -Action [$($Action)] option, must not specifiy -MoveToFolder option."
                Finalize $ErrorReturnCode
                }


#ArchiveFileNameの要不要と有無、Validation

    IF ($PreAction -contains 'Archive') {
        CheckNullOrEmpty -CheckPath $ArchiveFileName -ObjectName '-ArchiveFileName' -IfNullOrEmptyFinalize > $NULL
        
        IF ($ArchiveFileName -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-ArchiveFileName may contain characters that can not use by NTFS."
				Finalize $ErrorReturnCode
                } 
        }


#7zフォルダの要不要と有無を確認

    If ( $PreAction -match "^(7z|7zZip)$") {    

        $7zFolder = ConvertToAbsolutePath -CheckPath $7zFolder -ObjectName '-7zFolder'

        CheckContainer -CheckPath $7zFolder -ObjectName '-7zFolder' -IfNoExistFinalize > $NULL
        }

#組み合わせが不正な指定を確認


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



#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

    IF ($Action -eq "DeleteEmptyFolders") {

        Logging -EventID $InfoEventID -EventType Information -EventMessage "Delete empty folders [in target folder $($TargetFolder)][older than $($Days)days][match to regular expression [$($RegularExpression)]][recursively[$($Recurse)]]"
        
        }else{

        Logging -EventID $InfoEventID -EventType Information -EventMessage ("Files [in the folder $($TargetFolder)][older than $($Days)days][match to regular expression [$($RegularExpression)]][parent path match to regular expression [$($ParentRegularExpression)]][size is over"+($Size / 1KB)+"KB]")

        IF ($PreAction -notcontains 'none') {

            $message = "Process files matched "
            IF ($PreAction -contains 'MoveNewFile') { $message += "to move to [$($MoveToFolder)] "}

            IF ($PreAction -match "^(Compress|Archive)$") {
                
                #$PreActionは配列なのでSwitchで処理すると複数回実行されるので、IFで処理
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


#圧縮フラグまたはタイムスタンプ付加フラグがTrueの処理

function CompressAndAddTimeStamp {

Param(
[parameter(mandatory=$TRUE)][String]$TargetObject
) 

    [String]$targetFileParentFolder = Split-Path -Path $TargetObject -Parent

#圧縮フラグTrueの時

    IF ($PreAction -match '^(Compress)$') {

        #$PreActionは配列である。それをSwitch処理すると1要素づつループする。
        #'Compress'等は一旦Defaultに落ちるが、'7z' or '7zZip'があれば$ActionTypeは上書きされる

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

#タイムスタンプ付加のみTrueの時

                $archiveFile = Join-Path -Path $targetFileParentFolder -ChildPath (AddTimeStampToFileName -TargetFileName (Split-Path -Path $TargetObject -Leaf )  -TimeStampFormat $TimeStampFormat )
                $Script:ActionType = "AddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "Create new file [$(Split-Path -Path $archiveFile -Leaf)] added time stamp."
                }


#移動フラグがTrueならば、作成した圧縮orタイムスタンプ付加したファイルを移動する

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






#####################   ここから本体  ######################

[Boolean]$ErrorFlag = $FALSE
[Boolean]$WarningFlag = $FALSE
[Boolean]$NormalFlag = $FALSE
[Boolean]$OverRideFlag = $FALSE
[Boolean]$ContinueFlag = $FALSE
[Boolean]$ForceFinalize = $FALSE          ;#$TRUEでオブジェクト処理ループを強制終了。
[Boolean]$ForceEndloop = $FALSE           ;#$FALSEではFinalize , $TRUEではループ内でBreak
[Int][ValidateRange(0,2147483647)]$ErrorCount = 0
[Int][ValidateRange(0,2147483647)]$WarningCount = 0
[Int][ValidateRange(0,2147483647)]$NormalCount = 0
[Int][ValidateRange(0,2147483647)]$OverRideCount = 0
[Int][ValidateRange(0,2147483647)]$ContinueCount = 0
[Int][ValidateRange(0,2147483647)]$InLoopDeletedFilesCount = 0

$DatumPath = $PSScriptRoot

$Version = '20200305_1030'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize


#対象のフォルダまたはファイルを探して配列に入れる


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
    　
#-PreAction Archiveは複数ファイルを1ファイルに圧縮する。よって、ループ前に圧縮先の1ファイルのフルパスを確定しておく

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


#対象フォルダorファイル群の処理ループ

ForEach ($TargetObject in $TargetObjects)
{
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
Do
{
    [Boolean]$ErrorFlag = $FALSE
    [Boolean]$WarningFlag = $FALSE
    [Boolean]$NormalFlag = $FALSE
    [Boolean]$OverRideFlag = $FALSE
    [Boolean]$ContinueFlag = $FALSE
    [Boolean]$ForceEndloop = $TRUE   ;#このループ内で異常終了する時はループ終端へBreakして、処理結果を表示する。直ぐにFinalizeしない
    [Int]$InLoopOverRideCount = 0    ;#$OverRideCountは処理全体のOverRide回数。$InLoopOverRideCountは1処理ループ内でのOverRide回数。1オブジェクトで複数回OverRideがあり得るため

    [String]$TargetFileParentFolder = Split-Path -Path $TargetObject -Parent

    Logging -EventID $InfoLoopStartEventID -EventType Information -EventMessage "--- Start processing [$($FilterType)] $($TargetObject) ---"


#移動元のファイルパスから移動先のファイルパスを生成。
#再帰的でなければ、移動先パスは確実に存在するのでスキップ

#Action[(Move|Copy)]以外はファイル移動が無い。移動先パスを確認する必要がないのでスキップ
#PreAction[Archive]はMoveNewFile[TRUE]でも出力ファイルは1個で階層構造を取らない。よってスキップ

    If ( (($Action -match "^(Move|Copy)$")) -or (($PreAction -contains 'MoveNewFile') -and ($PreAction -notcontains 'Archive')) ) {

        #ファイルが移動するAction用にファイル移動先の親フォルダパス$MoveToNewFolderを生成する
        
        #C:\TargetFolder                    :TargetFolder
        #C:\TargetFolder\A\B\C              :TargetFileParentFolder
        #C:\TargetFolder\A\B\C\target.txt   :TargetFile
        #D:\MoveToFolder                    :MoveToFolder
        #D:\MoveToFolder\A\B\C              :MoveToNewFolder

        #D:\MoveToFolder\A\B\C\target.txt   :ファイルの移動先パス

        #MoveToNewFolderを作るには \A\B\C\　の部分を取り出して、移動先フォルダMoveToFolderとJoin-Pathする
        #String.Substringメソッドは文字列から、引数位置から最後までを取り出す
        #MoveToNewFolderはNoRecurseでもMove|Copyで一律使用するので作成

        $MoveToNewFolder = Join-Path -Path $MoveToFolder -ChildPath ($TargetFileParentFolder).Substring($TargetFolder.Length)
        If ($Recurse) {

            If (-not(CheckContainer -CheckPath $MoveToNewFolder -ObjectName 'Moving the file to, Folder ')) {

                Logging -EventID $InfoEventID -EventType Information -EventMessage "Create a new folder $($MoveToNewFolder)"

                TryAction -ActionType MakeNewFolder -ActionFrom $MoveToNewFolder -ActionError $MoveToNewFolder

                #$TryActionが異常終了&-Continue $TRUEだと$ContinueFlag $TRUEになるので、その場合は後続処理はしないで次のObject処理に進む
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

    #分岐1 何もしない
    '^none$' {
            IF ( ($PostAction -eq 'none') -and ($PreAction -contains 'none') ) {

                Logging -EventID $InfoEventID -EventType Information -EventMessage "Specified -Action [$($Action)] option, thus do not process $($TargetObject)"
                }
            }

    #分岐2 削除
    '^Delete$' {
            TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject
            } 

    #分岐3 移動 or 複製 　同一のファイルが（移動|複製先）に存在しないことを確認してから処理
    '^(Move|Copy)$' {
            $targetFileMoveToPath = Join-Path -Path $MoveToNewFolder -ChildPath (Split-Path -Path $TargetObject -Leaf)

            IF (CheckLeafNotExists $targetFileMoveToPath) {

                TryAction -ActionType $Action -ActionFrom $TargetObject -ActionTo $targetFileMoveToPath -ActionError $TargetObject
                }           
            }

    #分岐4 空フォルダを判定して削除
    '^DeleteEmptyFolders$' {
            Logging -EventID $InfoEventID -EventType Information -EventMessage  "Check the folder $($TargetObject) is empty."

            IF ((Get-Item -LiteralPath $TargetObject).GetFileSystemInfos().Count -eq 0) {

                Logging -EventID $InfoEventID -EventType Information -EventMessage  "The folder $($TargetObject) is empty."
                TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject

                }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage "The folder $($TargetObject) is not empty." 
                }
            }


    #分岐5 NullClear
    '^NullClear$' {
            TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject          
            }

    #分岐6 KeepFilesCount
    '^KeepFilesCount$' {
            IF (($TargetObjects.Length - $InLoopDeletedFilesCount) -gt $KeepFiles) {
                Logging -EventID $InfoEventID -EventType Information -EventMessage  "In the folder more than [$($KeepFiles)] files exist, thus delete the oldest [$($TargetObject)]"
                TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject

                #$TryActionが異常終了&-Continue $TRUEだと$ContinueFlag $TRUEになるので、その場合は後続処理はしないで次のObject処理に進む
                IF ($ContinueFlag) {
                    Break                
                    }
                $InLoopDeletedFilesCount++
            
            }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage  "Tn the foler less [$($KeepFiles)] files exist, thus do not delete [$($TargetObject)]"
                }
            }

    #分岐7 $Actionが条件式のどれかに適合しない場合は、プログラムミス
    Default {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error at Switch Action section. It may cause a bug in regex."
            Finalize $InternalErrorReturnCode
            }
    }


#Post Action

    Switch -Regex ($PostAction) {

    #分岐1 何もしない
    '^none$' {            
            }

    #分岐2 Rename Rename後の同一名称ファイルがに存在しないことを確認してから処理
    '^Rename$' {
            $newFilePath = Join-Path -Path $TargetFileParentFolder -ChildPath  ((Split-Path -Path $TargetObject -Leaf) -replace "$RegularExpression" , "$RenameToRegularExpression")

            $newFilePath = ConvertToAbsolutePath -CheckPath $newFilePath -ObjectName 'Filename renamed'

                    IF (CheckLeafNotExists $newFilePath) {

                        TryAction -ActionType Rename -ActionFrom $TargetObject -ActionTo $newFilePath -ActionError $TargetObject
                        }else{
                        Logging -EventID $InfoEventID -EventType Information -EventMessage  "A file [$($newFilePath)] already exists same as attempting rename, thus do not rename [$($TargetObject)]"
                        }
            }

    #分岐3 NullClear
    '^NullClear$' {
            TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject          
            }


    #分岐4 $Actionが条件式のどれかに適合しない場合は、プログラムミス
    Default {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal error at Switch PostAction section. It may cause a bug in regex."
            Finalize $InternalErrorReturnCode
            }
    }



#異常終了などはBreakしてファイル処理終端へ抜ける。
}
While($FALSE)


#異常、警告を確認。異常>警告>正常の順位で実行結果数カウントアップ

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

#対象群の処理ループ終端
   
}


#終了メッセージ出力

Finalize $NormalReturnCode

