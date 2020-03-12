#Requires -Version 5.0
#If you wolud NOT use '-PreAction compress or archive' in FileMaintenance.ps1 , you could change '-Version 5.0' to '-Version 3.0'

<#
.SYNOPSIS
ログファイル圧縮、削除を始めとした色々な処理をする万能ツールです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているWrapper.ps1と併用すると複数処理を一括実行できます。

<Common Parameters>はサポートしていません

.DESCRIPTION
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
　-TargetFolderの直下のみを処理対象とします。-Recurse $Falseと等価です。
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
　Event Log出力を抑止します。-Log2EventLog $Falseと等価です。
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
　コンソールログ出力を抑止します。-Log2Console $Falseと等価です。
Log2Consoleより優先します。

.PARAMETER Log2File
　ログフィルへの出力を制御します。
デフォルトは$Falseでログファイル出力しません。

.PARAMETER NoLog2File
　ログファイル出力を抑止します。-Log2File $Falseと等価です。
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

[parameter(position=0, mandatory=$true , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$TargetFolder,

#[parameter(position=0, mandatory=$true , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String]$TargetFolder,  #Validation debug用に用意してあります。通常は使わない
#[parameter(position=0, mandatory=$true , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$TargetFolder ,
 

[Array][parameter(position=1)][ValidateSet("AddTimeStamp", "Compress", "MoveNewFile" , "none" , "Archive" , "7z" , "7zZip")]$PreAction = 'none',

[String][parameter(position=2)][ValidateSet("Move", "Copy", "Delete" , "none" , "DeleteEmptyFolders" , "NullClear" , "KeepFilesCount")]$Action='none',

[String][parameter(position=3)][ValidateSet("none"  , "NullClear" , "Rename")]$PostAction='none',


[String][parameter(position=4)][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$MoveToFolder,


[String][ValidatePattern('^(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$ArchiveFileName = "archive.zip" ,

[int][ValidateRange(0,2147483647)]$KeepFiles = 1,
[int][ValidateRange(0,730000)]$Days = 0,
[int64][ValidateRange(0,9223372036854775807)]$Size = 0,

#[Regex]$RegularExpression ='applog([0-9][0-9])([0-9][0-9])([0-9][0-9])',
#[Regex]$RegularExpression ='\.txt$',
[Regex]$RegularExpression ='.*',
[Regex]$ParentRegularExpression ='.*',

[Regex]$RenameToRegularExpression ='.loglog',
#[Regex]$RenameToRegularExpression ='applicationlog-20$1-$2-$3',

[boolean]$Recurse = $TRUE,
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
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis

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

    #CommonFunctions.ps1の配置先を変更した場合は、ここを変更。同一フォルダに配置前提
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "CommonFunctions.ps1 のLoadに失敗しました。CommonFunctions.ps1がこのファイルと同一フォルダに存在するか確認してください"
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
    チェック対象のファイルが存在するが、-Continueを指定...$False
    チェック対象のファイルが存在する...$ErrorReturnCode でFinalizeへ進む、またはBreak
    チェック対象の同一名称のフォルダが存在するが、-OverRideを指定...上書きが出来ないので$ErrorReturnCode でFinalizeへ進む、またはBreak
    チェック対象と同一名称のフォルダが存在するが、-Continueを指定...$False
    チェック対象と同一名称のフォルダが存在する...$ErrorReturnCode でFinalizeへ進む、またはBreak
    チェック対象のファイル、フォルダが存在しない...$TRUE
#>

Param(
[parameter(mandatory=$true)][String]$CheckLeaf
)

Logging -EventID $InfoEventID -EventType Information -EventMessage "$($CheckLeaf)の存在を確認します"

    #既にファイルがあるが、OverRide指定は無い。よって、異常終了 or Continue指定ありで継続

    If( (Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -AND (-NOT($OverRide)) ){

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "既に$($CheckLeaf)が存在します"

        IF(-NOT($ContinueAsNormal)){
            $Script:WarningFlag = $TRUE
            }    
        If(-NOT($Continue)){
 
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "既に$($CheckLeaf)が存在するため、${SHELLNAME}を終了します"
            
                IF($ForceEndLoop){
                    $Script:ErrorFlag = $TRUE
                    $Script:ForceFinalize = $TRUE
                    Break
                    }else{
                    Finalize $ErrorReturnCode
                    }
            }else{
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]のため処理を継続します。"
            $Script:ContinueFlag = $true

            #既存ファイルがあるので$Falseを返してファイル処理させない
            Return $False
            }

      #既にファイルがあるが、OverRide指定がある。よって継続  

     }elseIF( (Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -AND ($OverRide) ){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "既に$($CheckLeaf)が存在しますが-OverRide[$OverRide]のため上書きします"
            $Script:OverRideFlag = $TRUE

            #ここまで来ればファイルが存在しないは確定。同一名称のフォルダが存在する可能性は残っている
            #同一名称のフォルダが存在するとOverRide出来ないので、Continue指定ありの場合は継続。指定なしで異常終了

            }elseIF(Test-Path -LiteralPath $CheckLeaf -PathType Container){

                Logging -EventID $WarningEventID -EventType Warning -EventMessage "既に同一名称フォルダ$($CheckLeaf)が存在します"
                $Script:WarningFlag = $TRUE

                IF(-NOT($Continue)){

                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "既に同一名称フォルダ$($CheckLeaf)が存在するため、${SHELLNAME}を終了します"

                    IF($ForceEndLoop){
                        $Script:ErrorFlag = $TRUE
                        $Script:ForceFinalize = $TRUE
                        Break
                        }else{
                        Finalize $ErrorReturnCode
                        }
            
                    }else{
                    Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]のため処理を継続します。"
                    $Script:ContinueFlag = $true

                    #既存フォルダがあるので$Falseを返してファイル処理させない
                    Return $False
                    }

            
            #同一名称のファイル、フォルダ共に存在しない

            }else{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($CheckLeaf)は存在しません"            
            }

Return $true
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
 
    IF (($_.PSIsContainer -eq ($FilterType -eq 'Folder')) -OR ( -NOT($_.PSIsContainer) -eq ($FilterType -eq 'File'))) {
    IF ($_.LastWriteTime -lt (Get-Date).AddDays(-$Days)) {
    IF ($_.Name -match ${RegularExpression}){
    IF ($_.Length -ge ($Size)){
    IF (($_.FullName).Substring($TargetFolder.Length , (Split-Path -Parent $_.FullName).Length - $TargetFolder.Length +1) -match ${ParentRegularExpression})
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
[parameter(mandatory=$true)][String]$TargetFolder
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

    Switch -Regex ($Action){
 
        #KeepFilesCount配列に入れたパス一式を古い順に整列
        '^KeepFilesCount$'{
            Return ($objects | Sort-Object -Property Time | ForEach-Object {$_.object.FullName})
            }

        #DeleteEmptyFolders配列に入れたパス一式をパスが深い順に整列。空フォルダが空フォルダに入れ子になっている場合、深い階層から削除する必要がある。
        '^DeleteEmptyFolders$'{
            Return ($objects | Sort-Object -Property Depth -Descending | ForEach-Object {$_.object.FullName})        
            }


        Default{
            Return ($objects | ForEach-Object {$_.object.FullName})
            }
    }
}


function Initialize {

$SHELLNAME = Split-Path $PSCommandPath -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#Switch処理

IF($NoRecurse){[boolean]$Script:Recurse = $false}
IF($NullOriginalFile){[String]$Script:PostAction = 'NullClear'}
IF($ContinueAsNormal){[Switch]$Script:Continue = $TRUE}

IF($AddTimeStamp){$Script:PreAction +='AddTimeStamp'}
IF($MoveNewFile){$Script:PreAction +='MoveNewFile'}
IF($Compress){$Script:PreAction +='Compress'}

#パラメータの確認


#指定フォルダの有無を確認
#CheckContainer functionは$True,$Falseが戻値なので$Nullへ捨てる。捨てないとコンソール出力される

    $TargetFolder = ConvertToAbsolutePath -CheckPath $TargetFolder -ObjectName  '指定フォルダ-TargetFolder'

    CheckContainer -CheckPath $TargetFolder -ObjectName '指定フォルダ-TargetFolder' -IfNoExistFinalize > $NULL


#移動先フォルダの要不要と有無を確認

    If (  ($Action -match "^(Move|Copy)$") -OR ($PreAction -contains 'MoveNewFile')  ){    

        $MoveToFolder = ConvertToAbsolutePath -CheckPath $MoveToFolder -ObjectName '移動先フォルダ-MoveToFolder'

        CheckContainer -CheckPath $MoveToFolder -ObjectName '移動先フォルダ-MoveToFolder' -IfNoExistFinalize > $NULL
 
       
     }elseIF(-NOT (CheckNullOrEmpty -CheckPath $MoveToFolder)){
                Logging -EventID $ErrorEventID -EventType Error -EventMessage "Action[$($Action)]の時、-MoveToFolder指定は不要です"
                Finalize $ErrorReturnCode
                }


#ArchiveFileNameの要不要と有無、Validation

    IF($PreAction -contains 'Archive'){
        CheckNullOrEmpty -CheckPath $ArchiveFileName -ObjectName '-ArchiveFileName' -IfNullOrEmptyFinalize > $NULL
        
        IF( $ArchiveFileName -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-ArchiveFileNameにNTFSで使用できない文字が含まれています"
				Finalize $ErrorReturnCode
                } 
        }


#7zフォルダの要不要と有無を確認

    If ( $PreAction -match "^(7z|7zZip)$"){    

        $7zFolder = ConvertToAbsolutePath -CheckPath $7zFolder -ObjectName '-7zFolder'

        CheckContainer -CheckPath $7zFolder -ObjectName '-7zFolder' -IfNoExistFinalize > $NULL
        }

#組み合わせが不正な指定を確認


    If(($TargetFolder -eq $MoveToFolder) -AND (($Action -match "move|copy") -OR  ($PreAction -contains 'MoveNewFile'))){
				Logging -EventType Error -EventID $ErrorEventID -EventMessage "移動先フォルダと移動先フォルダとが同一の時に、ファイルの移動、複製は出来ません"
				Finalize $ErrorReturnCode
                }

    If (($Action -match "^(Move|Delete|KeepFilesCount)$") -AND  ($PostAction -ne 'none')){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "対象ファイルを削除または移動後、-PostAction[$($PostAction)]することは出来ません"
				Finalize $ErrorReturnCode
                }

   If (($PreAction -contains 'MoveNewFile' ) -AND  (-NOT($PreAction -match "^(Compress|AddTimeStamp|Archive)$") )){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "-PreActionでMoveNewFileは、Compres , AddTimeStamp , Archiveと併用する必要があります。元ファイルの移動には-Action Moveを指定してください"
				Finalize $ErrorReturnCode
                }

   If (($PreAction -contains 'Compress') -AND  ($PreAction -contains 'Archive') ){

				Logging -EventType Error -EventID $ErrorEventID "-PreActionでCompressとArchiveとを同時に指定はできません"
				Finalize $ErrorReturnCode
                }

   If (($PreAction -contains '7z' ) -AND  ($PreAction -Contains '7zZip')){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "-PreActionで圧縮方式指定7zと7zZipとを同時に指定はできません"
				Finalize $ErrorReturnCode
                }

   If (($PreAction -match "^(7z|7zZip)$" ) -AND  (-NOT($PreAction -match "^(Compress|Archive)$"))){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "-PreActionで圧縮方式指定7zと7zZipは単独で指定できません。CompressまたはArchiveの指定が必要です"
				Finalize $ErrorReturnCode
                }

   IF ($Action -eq "DeleteEmptyFolders"){
        IF( ($PreAction -match '^(Compress|Archive|AddTimeStamp)$') -OR ($PostAction -ne 'none' )){
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "空フォルダ削除-Action[$Action]を指定した時、ファイル操作は行えません"
				Finalize $ErrorReturnCode

        }elseIF($Size -ne 0){
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "空フォルダ削除-Action[$Action]を指定した時、ファイル容量指定-sizeは設定できません"
				Finalize $ErrorReturnCode
                }
    }


    IF ($TimeStampFormat -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-TimeStampFormatにNTFSで使用できない文字が含まれています"
				Finalize $ErrorReturnCode
                }



#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

    IF ($Action -eq "DeleteEmptyFolders"){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "指定フォルダ$($TargetFolder)の$($Days)日以前の正規表現 $($RegularExpression) にマッチする空フォルダを再帰的[$($Recurse)]に削除します"
        
        }else{

        Logging -EventID $InfoEventID -EventType Information -EventMessage ("指定フォルダ[$($TargetFolder)]の[$($Days)日以前][正規表現 $($RegularExpression) にマッチ][指定フォルダ以後のパスが正規表現 $($ParentRegularExpression) にマッチ]["+($Size / 1KB)+"KB以上]にマッチしたファイルを抽出します")

        IF( $PreAction -notcontains 'none'){

            $Message = "マッチしたファイルを"
            IF ($PreAction -contains 'MoveNewFile'){ $Message += "移動先フォルダ[$($MoveToFolder)]へ"}

            IF ($PreAction -match "^(Compress|Archive)$"){
                
                #$PreActionは配列なのでSwitchで処理すると複数回実行されるので、IFで処理
                IF($PreAction -ccontains '7z'){
                        $Message += "圧縮方式[7z]で"            
                        }elseIF($PreAction -contains '7zZIP'){
                            $Message += "圧縮方式[7zZip]で"
                            }else{
                            $Message += "圧縮方式[Powershell cmdlet Compress-Archive]で"
                            }
                               
            }
            
            $Message += "再帰的[$($Recurse)]にPreAction( ファイル名に日付付加["+[Boolean]($PreAction -contains 'AddTimeStamp')+"] | 圧縮["+[Boolean]($PreAction -contains 'Compress')+"] | 1ファイルにアーカイヴ["+[Boolean]($PreAction -contains 'Archive')+"] )します"

            Logging -EventID $InfoEventID -EventType Information -EventMessage $Message
            }



        IF ($Action -ne 'none'){

            $Message = "マッチしたファイルを"
            IF ($Action -eq 'KeepFilesCount') { $Message += "[世代数($($KeepFiles))]まで"}
            IF ($Action -match '^(Copy|Move)$'){ $Message += "移動先フォルダ[$($MoveToFolder)]へ"}
            $Message += "再帰的[$($Recurse)]にAction[$($Action)]します。"

            Logging -EventID $InfoEventID -EventType Information -EventMessage $Message
            }

        IF ($PostAction -ne 'none'){

            $Message = "マッチしたファイルを"
            IF ($PostAction -eq 'Rename') { $Message += "リネーム規則[($($RenameToRegularExpression))]を用いて"}
            $Message += "再帰的[$($Recurse)]にPostAction[$($PostAction)]します。"

            Logging -EventID $InfoEventID -EventType Information -EventMessage $Message
            }
    }

    IF($NoAction){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-NoAction[${NoAction}]が指定されているため実際にはファイル/フォルダを処理をしません"
        }

    IF($OverRide){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-OverRide[${OverRide}]が指定されているため生成したファイルと同名のものがあった場合は上書きします"
        }

    If($ContinueAsNormal){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-ContinueAsNormal[$($ContinueAsNormal)]が指定されているため生成したファイルと同名のものがあった場合は正常扱いで次のファイルを処理します。ファイル名同一以外の処理異常は警告しますが、次のファイル、フォルダを処理します"
        
        }elseIF($Continue){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-Continue[${Continue}]が指定されているため生成したファイル、フォルダと同名のものがあった場合等の処理異常で異常終了せず警告後、次のファイル、フォルダを処理します"
            }

}


#圧縮フラグまたはタイムスタンプ付加フラグがTrueの処理

function CompressAndAddTimeStamp{

Param(
[parameter(mandatory=$true)][String]$TargetObject
) 

        [String]$TargetFileParentFolder = Split-Path $TargetObject -Parent

#圧縮フラグTrueの時

    IF($PreAction -match '^(Compress)$'){

        #$PreActionは配列である。それをSwitch処理すると1要素づつループする。
        #'Compress'等は一旦Defaultに落ちるが、'7z' or '7zZip'があれば$ActionTypeは上書きされる

        Switch -Regex ($PreAction){    
        
          '^7z$'{
                $Script:ActionType = "7z"
                $ExtString = '.7z'
                Break                
                }
                
           '^7zZip$'{
                $Script:ActionType = "7zZip"
                $ExtString = '.zip'
                Break
                }
                    
             Default{
                $Script:ActionType = ""
                $ExtString = $CompressedExtString
                }    
        }
                        
        IF($PreAction -contains 'AddTimeStamp'){

                $ArchiveFile = Join-Path $TargetFileParentFolder -ChildPath ((AddTimeStampToFileName -TargetFileName (Split-Path $TargetObject -Leaf )  -TimeStampFormat $TimeStampFormat )+$ExtString )
                $Script:ActionType += "CompressAndAddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "圧縮&タイムスタンプ付加した[$(Split-Path -Leaf $ArchiveFile)]を作成します"

                }else{
                $ArchiveFile = $TargetObject+$ExtString
                $Script:ActionType += "Compress"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "圧縮した[$(Split-Path -Leaf $ArchiveFile)]を作成します" 
                }          
 
    }else{

#タイムスタンプ付加のみTrueの時

                $ArchiveFile = Join-Path $TargetFileParentFolder -ChildPath (AddTimeStampToFileName -TargetFileName (Split-Path $TargetObject -Leaf )  -TimeStampFormat $TimeStampFormat )
                $Script:ActionType = "AddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "タイムスタンプ付加した[$(Split-Path -Leaf $ArchiveFile)]を作成します"
                }


#移動フラグがTrueならば、作成した圧縮orタイムスタンプ付加したファイルを移動する

    IF($PreAction -contains 'MoveNewFile'){

        Logging -EventID $InfoEventID -EventType Information -EventMessage ("-PreAction MoveNewFile["+[Boolean]($PreAction -contains 'MoveNewFile')+"]のため、作成したファイルは$($MoveToNewFolder)に配置します")
        Return ( Join-Path $MoveToNewFolder (Split-Path -Leaf $ArchiveFile) )

        }else{
        Return $ArchiveFile
        }

}


function Finalize{

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)
    $ForceFinalize = $False

    IF(-NOT(($NormalCount -eq 0) -and ($WarningCount -eq 0) -and ($ErrorCount -eq 0))){    

       Logging -EventID $InfoEventID -EventType Information -EventMessage "実行結果は正常終了[$($NormalCount)]、警告終了[$($WarningCount)]、異常終了[$($ErrorCount)]です"


        IF($OverRide -and ($OverRideCount -gt 0)){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-OverRide[${OverRide}]が指定されているため生成したファイルと同名のものを[$($OverRideCount)]回、上書きしました"
            }

        IF(($Continue) -and ($ContinueCount -gt 0)){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-Continue[${Continue}]が指定されているため生成したファイルと同名のものがあった場合等の処理異常で異常終了せず次のファイル、フォルダを[$($ContinueCount)]回処理しました"
            }
    }

    $Countinue = $Continue[0..($Continue.Length-2)]

EndingProcess $ReturnCode

}






#####################   ここから本体  ######################

[boolean]$ErrorFlag = $false
[boolean]$WarningFlag = $False
[boolean]$NormalFlag = $False
[boolean]$OverRideFlag = $False
[boolean]$ContinueFlag = $False
[Boolean]$ForceFinalize = $False          ;#$TRUEでオブジェクト処理ループを強制終了。
[Boolean]$ForceEndloop = $False           ;#$FalseではFinalize , $TRUEではループ内でBreak
[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0
[int][ValidateRange(0,2147483647)]$OverRideCount = 0
[int][ValidateRange(0,2147483647)]$ContinueCount = 0
[int][ValidateRange(0,2147483647)]$InLoopDeletedFilesCount = 0

$DatumPath = $PSScriptRoot

$Version = '20200305_1030'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize


#対象のフォルダまたはファイルを探して配列に入れる


    IF($Action -eq "DeleteEmptyFolders"){

        $FilterType = "Folder"

        }else{
        $FilterType = "File"
        }

$TargetObjects = @()

$TargetObjects = GetObjects -TargetFolder $TargetFolder

    If ($null -eq $TargetObjects){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($TargetFolder)に処理対象となる[$($FilterType)]はありません"

        IF($NoneTargetAsWarning){
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-NoneTargetAsWarningが指定されているため、警告終了扱いにします"
            Finalize $WarningReturnCode
            }
            else{
            Finalize $NormalReturnCode
            }
    }

Logging -EventID $InfoEventID -EventType Information -EventMessage "処理対象となる[$($FilterType)]は[$($TargetObjects.Length)]個存在します"

Write-Output "処理対象は以下の[$($FilterType)]です"

Write-Output $TargetObjects
    　
#-PreAction Archiveは複数ファイルを1ファイルに圧縮する。よって、ループ前に圧縮先の1ファイルのフルパスを確定しておく

IF( ($PreAction -contains 'Archive') ){

    IF($PreAction -contains 'MoveNewFile'){
        
        $ArchiveToFolder = $MoveToFolder
        }else{
        $ArchiveToFolder = $TargetFolder
        }

    IF($PreAction -contains 'AddTimeStamp'){  

        $ArchivePath = Join-Path -Path $ArchiveToFolder -ChildPath ( AddTimeStampToFileName -TimeStampFormat $TimeStampFormat -TargetFileName $ArchiveFileName )
        }else{
        $ArchivePath = Join-Path -Path $ArchiveToFolder -ChildPath $ArchiveFileName
        }

    $ArchivePath = ConvertToAbsolutePath -CheckPath $ArchivePath -ObjectName "ArchiveFile出力先"

    IF(-NOT(CheckLeafNotExists -CheckLeaf $ArchivePath)){
        
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "既に同一名称ファイルまたはフォルダ$($ArchivePath)が存在するため、${SHELLNAME}を終了します"
        Finalize $ErrorReturnCode        
        }

}


#対象フォルダorファイル群の処理ループ

ForEach ($TargetObject in $TargetObjects)
{

#PowershellはGOTO文が存在せず処理分岐ができない。
#そのためDo/Whileを用いて処理途中でエラーが発生した場合の分岐を実装している

#Do/While()は最後に評価が行われるループ。最後の評価がFalseとなるとループを終了する。ここでWhile($false)としてあるので、
#Do/Whileの間は1回だけ実行される。
#Do/Whileはループのため、処理途中でBreakすると、Whileへjumpする。

#ファイル群処理ループ中のエラー（例えば、ファイルをDelete試行したが、権限が無くて削除できない等）で想定される処理、指定方法は以下である。

#1.While以降の処理終了メッセージ出力へJumpして、次のファイルを処理継続
# Break , $ForceEndloog = $TRUE , $ForceFinalize = $False 
#2.While以降の処理終了メッセージ出力へJumpして、次のファイルは処理せずにFinalizeへ進む（処理打ち切り）
# Break , $ForceEndloog = $TRUE , $ForceFinalize = $TRUE
#3.処理終了メッセージ出力しない。Finalizeへ進む（処理打ち切り）
#Finalize $ErrorReturnCode

Do
{
    [boolean]$ErrorFlag = $False
    [boolean]$WarningFlag = $False
    [boolean]$NormalFlag = $False
    [boolean]$OverRideFlag = $False
    [boolean]$ContinueFlag = $False
    [Boolean]$ForceEndloop = $TRUE   ;#このループ内で異常終了する時はループ終端へBreakして、処理結果を表示する。直ぐにFinalizeしない
    [int]$InLoopOverRideCount = 0    ;#$OverRideCountは処理全体のOverRide回数。$InLoopOverRideCountは1処理ループ内でのOverRide回数。1オブジェクトで複数回OverRideがあり得るため

    [String]$TargetFileParentFolder = Split-Path $TargetObject -Parent

    Logging -EventID $InfoLoopStartEventID -EventType Information -EventMessage "--- 対象[$($FilterType)] $($TargetObject) 処理開始---"


#移動元のファイルパスから移動先のファイルパスを生成。
#再帰的でなければ、移動先パスは確実に存在するのでスキップ

#Action[(Move|Copy)]以外はファイル移動が無い。移動先パスを確認する必要がないのでスキップ
#PreAction[Archive]はMoveNewFile[TRUE]でも出力ファイルは1個で階層構造を取らない。よってスキップ

    If( (($Action -match "^(Move|Copy)$")) -OR (($PreAction -contains 'MoveNewFile') -AND ($PreAction -notcontains 'Archive') )) {

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

        $MoveToNewFolder = Join-Path $MoveToFolder -ChildPath ($TargetFileParentFolder).Substring($TargetFolder.Length)
        If($Recurse){

            If (-NOT(CheckContainer -CheckPath $MoveToNewFolder -ObjectName '移動先フォルダ')){

                Logging -EventID $InfoEventID -EventType Information -EventMessage "新規に$($MoveToNewFolder)を作成します"

                TryAction -ActionType MakeNewFolder -ActionFrom $MoveToNewFolder -ActionError $MoveToNewFolder

                #$TryActionが異常終了&-Continue $TRUEだと$Continue $TRUEになるので、その場合は後続処理はしないで次のObject処理に進む
                IF($ContinueFlag){
                    Break                
                    }
            }
        }
    }


#Pre Action

   IF(( $PreAction -match '^(Compress|AddTimeStamp)$') -AND ($PreAction -notcontains 'Archive')){

      $ArchivePath = CompressAndAddTimeStamp -TargetObject $TargetObject

      If(CheckLeafNotExists $ArchivePath){

            TryAction -ActionType $ActionType -ActionFrom $TargetObject -ActionTo $ArchivePath -ActionError $TargetObject
            }

        
    }elseIF($PreAction -contains 'Archive'){

        Switch -Regex ($PreAction){        
        
          '^7z$'{
                $ActionType = "7zArchive"
                Break
                }
                
           '^7zZip$'{
                $ActionType = "7zZipArchive"
                Break
                }
                    
             Default{
                $ActionType = "Archive"
                }       
        }        
       
        TryAction -ActionType $ActionType -ActionFrom $TargetObject -ActionTo $ArchivePath -ActionError $TargetObject
        }


#Main Action

    Switch -Regex ($Action){

    #分岐1 何もしない
    '^none$'
            {
            IF ( ($PostAction -eq 'none') -AND ($PreAction -contains 'none') ){
                Logging -EventID $InfoEventID -EventType Information -EventMessage "Action[${Action}]のため対象ファイル${TargetObject}は操作しません"
                }
            }

    #分岐2 削除
    '^Delete$'
            {
            TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject
            } 

    #分岐3 移動 or 複製 　同一のファイルが（移動|複製先）に存在しないことを確認してから処理
    '^(Move|Copy)$'
            {
            $TargetFileMoveToPath = Join-Path $MoveToNewFolder (Split-Path -Leaf $TargetObject)

            If(CheckLeafNotExists $TargetFileMoveToPath){

                TryAction -ActionType $Action -ActionFrom $TargetObject -ActionTo $TargetFileMoveToPath -ActionError $TargetObject
                }           
            }

    #分岐4 空フォルダを判定して削除
    '^DeleteEmptyFolders$'
            {
            Logging -EventID $InfoEventID -EventType Information -EventMessage  "フォルダ$($TargetObject)が空かを確認します"

            If ((Get-Item -LiteralPath $TargetObject).GetFileSystemInfos().Count -eq 0){ 

                Logging -EventID $InfoEventID -EventType Information -EventMessage  "フォルダ$($TargetObject)は空です"
                TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject

                }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage "フォルダ$($TargetObject)は空ではありません" 
                }
            }


    #分岐5 NullClear
    '^NullClear$'
            {
            TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject          
            }

    #分岐6 KeepFilesCount
    '^KeepFilesCount$'
            {
            IF (($TargetObjects.Length -$InLoopDeletedFilesCount) -gt $KeepFiles  ){
                Logging -EventID $InfoEventID -EventType Information -EventMessage  "指定世代数[$($KeepFiles)]以上のマッチしたファイルがあるため、最も古い[$($TargetObject)]を削除します"
                TryAction -ActionType Delete -ActionFrom $TargetObject -ActionError $TargetObject

                #$TryActionが異常終了&-Continue $TRUEだと$Continue $TRUEになるので、その場合は後続処理はしないで次のObject処理に進む
                IF($ContinueFlag){
                    Break                
                    }
                $InLoopDeletedFilesCount ++
            
                }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage  "指定世代数[$($KeepFiles)]以上のマッチしたファイルは無いため[$($TargetObject)]は操作しません"
                }
            }

    #分岐7 $Actionが条件式のどれかに適合しない場合は、プログラムミス
    Default 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Action判定の内部エラー。判定式にbugがあります"
            Finalize $InternalErrorReturnCode
            }
    }


#Post Action

    Switch -Regex ($PostAction){

    #分岐1 何もしない
    '^none$'
            {
            
            }

    #分岐2 Rename Rename後の同一名称ファイルがに存在しないことを確認してから処理
    '^Rename$'
            {
            $NewFilePath = Join-Path $TargetFileParentFolder -ChildPath  ((Split-Path -Leaf $TargetObject) -replace "$RegularExpression" , "$RenameToRegularExpression")

            $NewFilePath = ConvertToAbsolutePath -CheckPath $NewFilePath -ObjectName 'Rename後のファイル名'

                    If(CheckLeafNotExists $NewFilePath){

                        TryAction -ActionType Rename -ActionFrom $TargetObject -ActionTo $NewFilePath -ActionError $TargetObject
                        }else{
                        Logging -EventID $InfoEventID -EventType Information -EventMessage  "Rename後のファイル名[$($NewFilePath)]が存在するため[$($TargetObject)]のRenameはしません。"
                        }
            }

    #分岐3 NullClear
    '^NullClear$'
            {
            TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject          
            }


    #分岐4 $Actionが条件式のどれかに適合しない場合は、プログラムミス
    Default 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "PostAction判定の内部エラー。判定式にbugがあります"
            Finalize $InternalErrorReturnCode
            }
    }



#異常終了などはBreakしてファイル処理終端へ抜ける。
}
While($False)


#異常、警告を確認。異常>警告>正常の順位で実行結果数カウントアップ

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
         
    Logging -EventID $InfoLoopEndEventID -EventType Information -EventMessage "--- 対象[$($FilterType)] $($TargetObject) 処理終了 Normal[$($NormalFlag)] Warning[$($WarningFlag)] Error[$($ErrorFlag)]  Continue[$($ContinueFlag)]  OverRide[$($InLoopOverRideCount)]---"

    IF($ForceFinalize){    
        Finalize $ErrorReturnCode
        }

#対象群の処理ループ終端
   
}


#終了メッセージ出力

Finalize $NormalReturnCode

