#Requires -Version 1.0

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

-前処理:対象ファイルから別ファイルを生成します。可能な処理は「ファイル名にタイムスタンプ付加」「圧縮」「生成した別ファイルの移動」です。併用指定可能です。「生成した別ファイルの移動」を指定しないと対象ファイルと同一フォルダに配置します。
-主処理:対象ファイルを「移動」「複製」「削除」「内容消去（ヌルクリア）」、フォルダを「空フォルダ削除」します。
-後処理:対象ファイルを「内容消去（ヌルクリア）」します。

フィルタは「経過日数」「容量」「正規表現」で指定できます。

このプログラム単体では、1度に処理できるのは1フォルダです。複数フォルダを処理したい場合は、Wrapper.ps1を併用してください。


ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。



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

FileMaintenace.ps1 -TargetFolder C:\TEST -Action Copy -MoveToFolder C:\TEST1 -KBsize 10 -continue
C:\TEST以下のファイルで10KB以上のものを再帰的にC:\TEST1へ複製します。移動先に子フォルダが無ければ作成します
移動先に同一名称のファイルがあった場合はスキップして処理を継続します

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -Compress -Action none -AddTimeStamp -NullOriginalFile
C:\TEST以下のファイルを再帰的に 「.logで終わる」ものへファイル名に日付を付加して圧縮します。
元ファイルは残りますが、内容消去（ヌルクリア）します。

.EXAMPLE

FileMaintenace.ps1 -TargetFolder C:\TEST -RegularExpression '^.*\.log$' -Compress $True -Action Delete -MoveNewFile $True -MoveToFolder C:\TEST1 -OverRide -Days 10

C:\TEST以下のファイルを再帰的に 「.logで終わる」かつ10日以前のものを圧縮後C:\TEST1へ移動します。
移動先に同一名称のものがあった場合は上書きします。
元のファイルは削除します



.PARAMETER TargetFolder
処理対象のファイル、フォルダが格納されているフォルダを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log , ..\Script\log）
ワイルドカード* ? []は使用できません。
フォルダ名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。

.PARAMETER Action
　処理対象のファイルに対する操作を設定します。以下のパラメータを指定して下さい。

None:何も操作をしません。この設定がデフォルトです。
Move:ファイルを-MoveToFolderへ移動します。
Delete:ファイルを削除します。
Copy:ファイルを-MoveToFolderにコピーします。
DeleteEmptyFolders:空フォルダを削除します。
NullClear:ファイルの内容削除 NullClearします。

.PARAMETER MoveToFolder
　処理対象のファイルの移動、コピー先フォルダを指定します。
相対、絶対パスで指定可能です。
相対パス表記は、.から始める表記にして下さい。（例 .\Log , ..\Script\log）
ワイルドカード* ? []は使用できません。
フォルダ名に括弧 [ , ] を含む場合はエスケープせずにそのまま入力してください。

.PARAMETER Days
　処理対象のファイル、フォルダを更新経過日数でフィルタします。
デフォルトは0日で全てのファイルが対象となります。

.PARAMETER KBSize
　処理対象のファイルをKBサイズでフィルタします。
デフォルトは0KBで全てのファイルが対象となります。

.PARAMETER RegularExpression
　処理対象のファイル、フォルダを正規表現でフィルタします。
デフォルトは .* で全てが対象となります。
記述はシングルクオーテーションで括って下さい。
PowerShellの仕様上、大文字小文字の区別はしない筈ですが、実際には区別されるので注意して下さい。

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

.PARAMETER Compress
　対象ファイルを圧縮して別ファイルとして保存します。
-Action -AddTimeStamp -ClearNullOriginalと同時に指定可能です。

.PARAMETER CompressedExtString
　-Compress指定時のファイル拡張子を指定できます。
デフォルトは[.zip]です。

.PARAMETER AddTimeStamp
　対象ファイル名に日時を付加して別ファイルとして保存します。
-Action -Compres -ClearNullOriginalと併用可能です。

.PARAMETER TimeStampFormat
　-AddTimeStamp指定時の書式を指定できます。
デフォルトは[_yyyyMMdd_HHmmss]です。

.PARAMETER MoveNewFile
　-Compress -AddTimeStampを指定した際に生成される別ファイルを-MoveToFolderの指定先に保存します。
デフォルトは対象ファイルと同一ディレクトリへ保存します。

.PARAMETER NullOriginalFile
　対象ファイルの内容消去（ヌルクリア）します。
-Action NullClearと等価です。


.PARAMETER Log2EventLog
　Windows Event Logへの出力を制御します。
デフォルトは$TRUEでEvent Log出力します。

.PARAMETER NoLog2EventLog
　Event Log出力を抑止します。-Log2EventLog $Falseと等価です。
Log2EventLogより優先します。

.PARAMETER ProviderName
　Windows Event Log出力のプロバイダ名を指定します。デフォルトは[Infra]です。

.PARAMETER EventLogLogName
　Windows Event Log出力のログ名をしています。デフォルトは[Application]です。

.PARAMETER Log2Console 
　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console
　コンソールログ出力を抑止します。-Log2Console $Falseと等価です。
Log2Consoleより優先します。

.PARAMETER Log2File
　ログフィルへの出力を制御します。デフォルトは$Falseでログファイル出力しません。

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
　ログファイル出力に含まれる日時表示フォーマットを指定します。デフォルトは[yyyy-MM-dd-HH:mm:ss]形式です。

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

.PARAMETER WarningEventID
　Event Log出力でWarningに対するEvent IDを指定します。デフォルトは10です。

.PARAMETER SuccessErrorEventID
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



#>


Param(

#[parameter(mandatory=$true , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$TargetFolder,
[parameter(mandatory=$true , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$TargetFolder,
[String][ValidateSet("Move", "Copy", "Delete" , "none" , "DeleteEmptyFolders" , "NullClear")]$Action='none',
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$MoveToFolder,
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$MoveToFolder,

[int][ValidateRange(0,2147483647)]$Days = 0,
[int][ValidateRange(0,2147483647)]$KBsize = 0,
[Regex]$RegularExpression ='.*',
[Regex]$ParentRegularExpression ='.*',


[boolean]$Recurse = $TRUE,
[Switch]$NoRecurse,

[Switch]$OverRide,
[Switch]$Continue,
[Switch]$NoAction,

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

[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath = '.\SC_Logs\Infra.log',
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath = ..\Log\FileMaintenance.log ,
[String]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss',

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

    #CommonFunctions.ps1の配置先を変更した場合は、ここを変更。同一フォルダに配置前提
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "CommonFunctions.ps1 のLoadに失敗しました。CommonFunctions.ps1がこのファイルと同一フォルダに存在するか確認してください"
    Exit 1
    }


################ 設定が必要なのはここまで ##################


################# 共通部品、関数  #######################


#CheckLeafNotExists戻り値
#チェック対象のファイルが存在しない...$TRUE
#チェック対象のファイルが存在するが、-OverRideを指定...$TRUE　（この指定は-Continueに優先する）
#チェック対象のファイルが存在するが、-Continueを指定...$False
#チェック対象のファイルが存在する...$ErrorReturnCode でFinalizeへ進む

function CheckLeafNotExists {

Param(
[parameter(mandatory=$true)][String]$CheckLeaf
)

Logging -EventID $InfoEventID -EventType Information -EventMessage "$($CheckLeaf)の存在を確認します"


    If( (Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -AND (-NOT($OverRide)) ){

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "既に$($CheckLeaf)が存在します"
        $Script:WarningFlag = $TRUE
        
        If(-NOT($Continue)){
 
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "既に$($CheckLeaf)が存在するため、${SHELLNAME}を終了します"
            Finalize $ErrorReturnCode
            
            }else{
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]のため処理を継続します。"
            $Script:ContinueFlag = $true

            #既存ファイルがあるので$Falseを返してファイル処理させない
            Return $False
            }



     }elseif( (Test-Path -LiteralPath $CheckLeaf -PathType Leaf) -AND ($OverRide) ){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "既に$($CheckLeaf)が存在しますが-OverRide[$OverRide]のため上書きします"
            $Script:OverRideCount ++

            }else{
            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($CheckLeaf)は存在しません"            
            }

Return $true
}


filter ComplexFilter{

    IF ($_.LastWriteTime -lt (Get-Date).AddDays(-$Days)) {
    IF ($_.Name -match ${RegularExpression}){
    IF ($_.Length -ge (1024*$KBsize)){
    IF ((Split-Path -Parent $_.FullName) -match ${ParentRegularExpression})
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

#配列に入れたパス一式をパスが深い順に整列。空フォルダが空フォルダに入れ子になっている場合、深い階層から削除する必要がある。

$Folders = $Folders | Sort Depth -Descending

Return $Folders

}


function GetFiles{

Param(
[parameter(mandatory=$true)][String]$TargetFolder
)

    If($Recurse){

            Return ForEach-Object -Process{Get-ChildItem -LiteralPath $TargetFolder -File -Recurse -Include * | ComplexFilter | ForEach-Object {$_.FullName} }           
                           
            }else{

            Return ForEach-Object -Process{Get-ChildItem -LiteralPath $TargetFolder -File -Include * | ComplexFilter | ForEach-Object {$_.FullName}
            }
    }
}


function Initialize {



#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#Switch処理

IF($NoRecurse){[boolean]$Script:Recurse = $false}


#パラメータの確認


#指定フォルダの有無を確認
#CheckContainer functionは$True,$Falseが戻値なので$Nullへ捨てる。捨てないとコンソール出力される

    $TargetFolder = ConvertToAbsolutePath -CheckPath $TargetFolder -ObjectName  '指定フォルダ-TargetFolder'

   CheckContainer -CheckPath $TargetFolder -ObjectName '指定フォルダ-TargetFolder' -IfNoExistFinalize > $NULL



#移動先フォルダの要不要と有無を確認

    If (  ($Action -match "^(Move|Copy)$") -OR ($MoveNewFile)  ){
    

        $MoveToFolder = ConvertToAbsolutePath -CheckPath $MoveToFolder -ObjectName '移動先フォルダ-MoveToFolder'

        CheckContainer -CheckPath $MoveToFolder -ObjectName '移動先フォルダ-MoveToFolder' -IfNoExistFinalize > $NULL
 

                  
     }elseif(-NOT (CheckNullOrEmpty -CheckPath $MoveToFolder)){
                Logging -EventID $ErrorEventID -EventType Error -EventMessage "Action[$($Action)]の時、-MoveToFolder指定は不要です"
                Finalize $ErrorReturnCode
                }

#組み合わせが不正な指定を確認

    If(($TargetFolder -eq $MoveToFolder) -AND (($Action -match "move|copy") -OR  ($MoveNewFile))){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "移動先フォルダと移動先フォルダとが同一の時に、ファイルの移動、複製は出来ません"
				Finalize $ErrorReturnCode
                }


    If (($Action -match "^(Move|Delete)$") -AND  ($NullOriginalFile)){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "対象ファイルを削除または移動後、NullClearすることは出来ません"
				Finalize $ErrorReturnCode
                }


    If (($MoveNewFile) -AND  (-NOT(($Compress) -OR ($AddTimeStamp)))){

				Logging -EventType Error -EventID $ErrorEventID -EventMessage "-MoveNewFileは、-Compresまたは-AddTimeStampと併用する必要があります。元ファイルの移動には-Action Moveを指定してください"
				Finalize $ErrorReturnCode
                }


    IF ($Action -eq "DeleteEmptyFolders"){
        IF( ($Compress) -OR ($AddTimeStamp) -OR ($MoveNewFile) -OR($NullOriginalFile)){
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "空フォルダ削除-Action[$Action]を指定した時はファイル操作は行えません"
				Finalize $ErrorReturnCode

        }elseif($KBSize -ne 0){
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "空フォルダ削除-Action[$Action]を指定した時はファイル容量指定-KBsizeは行えません"
				Finalize $ErrorReturnCode
                }
    }


    IF ($TimeStampFormat -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-TimeStampFormatにNTFSで使用できない文字を指定しています"
				Finalize $ErrorReturnCode
                }



#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

    IF ($Action -eq "DeleteEmptyFolders"){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "指定フォルダ$($TargetFolder)の$($Days)日以前の正規表現 $($RegularExpression) にマッチする空フォルダを再帰的[$($Recurse)]に削除します"
        
        }else{
        Logging -EventID $InfoEventID -EventType Information -EventMessage "指定フォルダ$($TargetFolder)の$($Days)日以前の正規表現 $($RegularExpression) にマッチする$($KBSize)KB以上のファイルを移動先フォルダ$($MoveToFolder)へ再帰的[$($Recurse)]にAction[$($Action)]します。"
        }

    IF( ($Compress) -OR ($AddTimeStamp)){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "マッチしたファイルはファイル名に日付付加[${AddTimeStamp}]、圧縮[${Compress}]して、移動先フォルダ$($MoveToFolder)へ再帰的[$($Recurse)]に移動[$($MoveNewFile)]します"
        }


    IF($OverRide){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-OverRide[${OverRide}]が指定されているため生成したファイルと同名のものがあった場合は上書きします"
        }

    If($Continue){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-Continue[${Continue}]が指定されているため生成したファイルと同名のものがあった場合等の処理異常で異常終了せず次のファイル、フォルダを処理します"
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

#圧縮フラグまたはタイムスタンプ付加フラグがTrueの処理

 

#圧縮フラグTrueの時

        IF($Compress){

            IF($AddTimeStamp){
                $ArchiveFile = Join-Path $TargetFileParentFolder ($FileNameWithOutExtentionString+$FormattedDate+$ExtensionString+$CompressedExtString)
                $ActionType = "CompressAndAddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "圧縮&タイムスタンプ付加した[$(Split-Path -Leaf $ArchiveFile)]を作成します"
            }else{
                $ArchiveFile = $TargetObject+$CompressedExtString
                $ActionType = "Compress"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "圧縮した[$(Split-Path -Leaf $ArchiveFile)]を作成します" 
            }          
 
        }else{


#タイムスタンプ付加のみTrueの時

                $ArchiveFile = Join-Path $TargetFileParentFolder ($FileNameWithOutExtentionString+$FormattedDate+$ExtensionString)
                $ActionType = "AddTimeStamp"
                Logging -EventID $InfoEventID -EventType Information -EventMessage "タイムスタンプ付加した[$(Split-Path -Leaf $ArchiveFile)]を作成します"
                }


#移動フラグがTrueならば、作成した圧縮orタイムスタンプ付加したファイルを移動する

    IF($MoveNewFile){

        $ArchiveFileCheckPath = Join-Path $MoveToNewFolder (Split-Path -Leaf $ArchiveFile)
        Logging -EventID $InfoEventID -EventType Information -EventMessage "-MoveNewFile[$($MoveNewFile)]のため、作成したファイルは$($MoveToNewFolder)に配置します"

        }else{
        $ArchiveFileCheckPath = $ArchiveFile        
        }


      If(CheckLeafNotExists $ArchiveFileCheckPath){

            TryAction -ActionType $ActionType -ActionFrom $TargetObject -ActionTo $ArchiveFileCheckPath -ActionError $TargetObject
            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ArchiveFileCheckPath)を作成しました"
            }
}

function Finalize{

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

    IF(-NOT(($NormalCount -eq 0) -and ($WarningCount -eq 0) -and ($ErrorCount -eq 0))){
    

       Logging -EventID $InfoEventID -EventType Information -EventMessage "実行結果は正常終了[$($NormalCount)]、警告終了[$($WarningCount)]、異常終了[$($ErrorCount)]です"

       IF ($Action -eq "DeleteEmptyFolders"){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "指定フォルダ$($TargetFolder)の$($Days)日以前の正規表現 $($RegularExpression) にマッチする空フォルダを再帰的[$($Recurse)]に削除しました"
            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "指定フォルダ${TargetFolder}の${Days}日以前の正規表現 ${RegularExpression} にマッチする${KBSize}KB以上の全てのファイルを移動先フォルダ${MoveToFolder}へ再帰的[${Recurse}]にAction[${Action}]しました"
            }

        IF( ($Compress) -OR ($AddTimeStamp)){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "マッチしたファイルはファイル名に日付付加[${AddTimeStamp}]、圧縮[${Compress}]して、移動先フォルダ$($MoveToFolder)へ再帰的[$($Recurse)]に移動[$($MoveNewFile)]しました"

            }

        IF($OverRide -and ($OverRideCount -gt 0)){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-OverRide[${OverRide}]が指定されているため生成したファイルと同名のものを[$($OverRideCount)]回、上書きしました"
            }

        IF(($Continue) -and ($ContinueCount -gt 0)){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-Continue[${Continue}]が指定されているため生成したファイルと同名のものがあった場合等の処理異常で異常終了せず次のファイル、フォルダを[$($ContinueCount)]回処理しました"
            }
    }


EndingProcess $ReturnCode

}






#####################   ここから本体  ######################

[boolean]$ErrorFlag = $False
[boolean]$WarningFlag = $False
[boolean]$ContinueFlag = $False
[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0
[int][ValidateRange(0,2147483647)]$OverRideCount = 0
[int][ValidateRange(0,2147483647)]$ContinueCount = 0

${THIS_FILE}=$MyInvocation.MyCommand.Path       　　                    #フルパス
${THIS_PATH}=Split-Path -Parent ($MyInvocation.MyCommand.Path)          #このファイルのパス
${SHELLNAME}=[System.IO.Path]::GetFileNameWithoutExtension($THIS_FILE)  # シェル名

${Version} = '20200115_2100'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize



#対象のフォルダまたはファイルを探して配列に入れる

$TargetObjects = @()

Write-Output '処理対象は以下です'

    IF($Action -eq "DeleteEmptyFolders"){

        $TargetObjects = GetFolders $TargetFolder
        Write-Output $TargetObjects.Object.Fullname

        }else{
        $TargetObjects = GetFiles $TargetFolder
        Write-Output $TargetObjects
        }

    If ($null -eq $TargetObjects){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($TargetFolder)に処理対象となるファイル、またはフォルダはありません"
        Finalize $NormalReturnCode
        }



#対象フォルダorファイル群の処理ループ
#対象フォルダはオブジェクト、対象ファイルはファイル名変更or移動があるためパス文字列として処理

ForEach ($TargetObject in $TargetObjects)
{

[boolean]$ErrorFlag = $False
[boolean]$WarningFlag = $False
[boolean]$ContinueFlag = $False

$FormattedDate = (Get-Date).ToString($TimeStampFormat)
$ExtensionString = [System.IO.Path]::GetExtension($TargetObject)
$FileNameWithOutExtentionString = [System.IO.Path]::GetFileNameWithoutExtension($TargetObject)
$TargetFileParentFolder = Split-Path $TargetObject -Parent

$TargetObjectName = GetTargetObjectName $TargetObject

    Logging -EventID $InfoEventID -EventType Information -EventMessage "--- 対象Object $($TargetObjectName) 処理開始---"



#移動元のファイルパスから移動先のファイルパスを生成。
#再帰的でなければ、移動先パスは確実に存在するのでスキップ
#ファイル削除または何もしないときは移動先パスを確認する必要がないのでスキップ

    If( (($Action -match "^(Move|Copy)$")) -OR ($MoveNewFile)) {

        $MoveToNewFolder = Join-Path $MoveToFolder ($TargetFileParentFolder).Substring($TargetFolder.Length)
        If($Recurse){


            If (-NOT(CheckContainer -CheckPath $MoveToNewFolder -ObjectName 移動先フォルダ)){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "新規に$($MoveToNewFolder)を作成します"

            TryAction -ActionType MakeNewFolder -ActionFrom $MoveToNewFolder -ActionError $MoveToNewFolder
            }
        }
    }


#Pre Action
#圧縮フラグまたはタイムスタンプ付加フラグがTrueの処理

   IF( ($Compress) -OR ($AddTimeStamp)){

    CompressAndAddTimeStamp
    }


#Main Action


    Switch -Regex ($Action){

    #分岐1 何もしない
    '^none$'
            {
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Action[${Action}]のため対象ファイル${TargetObject}は操作しません"
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
            Logging -EventID $InfoEventID -EventType Information -EventMessage  "フォルダ$($TargetObjectName)が空かを確認します"


            If ($TargetObject.Object.GetFileSystemInfos().Count -eq 0){
     
                Logging -EventID $InfoEventID -EventType Information -EventMessage  "フォルダ$($TargetObjectName)は空です"
                TryAction -ActionType Delete -ActionFrom $TargetObjectName -ActionError $TargetObjectName


                }else{
                Logging -EventID $InfoEventID -EventType Information -EventMessage "フォルダ$($TargetObjectName)は空ではありません" 
                }
            }


    #分岐5 NullClear
    '^NullClear$'
            {
            TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject          
            }


    #分岐6 $Actionが条件式のどれかに適合しない場合は、プログラムミス
    Default 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Action判定の内部エラー。判定式にbugがあります"
            Finalize $InternalErrorReturnCode
            }
    }


#Post Action
#null clearフラグが正の場合はnull clear処理

    IF ($NullOriginalFile){

       TryAction -ActionType NullClear -ActionFrom $TargetObject -ActionError $TargetObject
    }


#異常、警告を確認。異常>警告>正常の順位で実行結果数カウントアップ

    IF($ErrorFlag){
        $ErrorCount ++
        }elseif($WarningFlag) {
            $WarningCount ++
            }else{
                $NormalCount ++
                }

    IF($ContinueFlag){
        $ContinueCount ++
        }
        
 
    Logging -EventID $InfoEventID -EventType Information -EventMessage "--- 対象Object $($TargetObjectName) 処理終了---"
  

#対象群の処理ループ終端
   
}


#終了メッセージ出力

Finalize $NormalReturnCode

