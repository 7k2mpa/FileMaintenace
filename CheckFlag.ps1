#Requires -Version 3.0

<#
.SYNOPSIS
バックアップ中等のフラグファイルを確認、作成するスクリプトです。
フラグファイルが存在すると警告終了Falseを、存在しないと正常終了Trueを返します。
-CreateFlagを指定するとフラグファイルを生成します。

<Common Parameters>はサポートしていません

.DESCRIPTION
バックアップ中等のフラグファイルを確認、作成するスクリプトです。
フラグファイルが存在すると警告終了Falseを、存在しないと正常終了Trueを返します。
-CreateFlagを指定するとフラグファイルを生成します。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。

フラグファイルの削除は同時に開発しているFileMaintenance.ps1をご利用ください。


配置例


.\CheckFlag.ps1
.\CommonFunctions.ps1
..\Lock\BackUp.Flg



.EXAMPLE
.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg

..\LockフォルダにBackUp.Flgファイルの有無を確認します。
フラグファイルが存在すると警告終了Falseを、存在しないと正常終了Trueを返します。


.EXAMPLE
.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg -CreateFlag

..\LockフォルダにBackUp.Flgファイルの有無を確認します。
ファイルが存在すると警告終了Falseを返します。
ファイルが存在しないとBackUp.Flgファイルの生成を試みます。ファイル生成に成功すると正常終了Trueを返します。生成に失敗すると異常終了Flaseを返します。



.PARAMETER FlagFolder

フラグファイルを確認、配置するフォルダを指定します。
相対パス、絶対パスでの指定が可能です。

.PARAMETER FlagFile

フラグファイル名を指定します。

.PARAMETER CreateFlag

フラグファイルが存在しない場合、フラグファイルを生成します。
フラグファイルの中身はシェル名+時刻となります。



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

.NOTES

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

[String][parameter(position=0)][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$FlagFolder = '.\',
#[parameter(mandatory=$true , HelpMessage = '処理対象のフォルダを指定(ex. D:\Logs) 全てのHelpはGet-Help FileMaintenance.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$FlagFolder,


[String][parameter(position=1)][ValidatePattern ('^(?!.*(\/|:|\?|`"|<|>|\||\*|\\).*$)')]$FlagFile ,

[Switch]$CreateFlag ,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,

[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath ,
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath = ..\Log\FileMaintenance.log ,
[String]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss',
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis

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



function Initialize {

$SHELLNAME=Split-Path $PSCommandPath -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い



#パラメータの確認


#フラグフォルダの有無を確認


    $FlagFolder = ConvertToAbsolutePath -CheckPath $FlagFolder -ObjectName  'Flagフォルダ-FlagFolder'

    CheckContainer -CheckPath $FlagFolder -ObjectName 'FLagフォルダ-FlagFolder' -IfNoExistFinalize > $NULL


#フラグファイル名のValidation


    IF ($FlagFile -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "-FlagFileにNTFSで使用できない文字を指定しています"
				Finalize $ErrorReturnCode
                }



#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

Logging -EventID $InfoEventID -EventType Information -EventMessage "フラグファイル[$($FlagFile)]の有無確認を開始します"

}


function Finalize{

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)



EndingProcess $ReturnCode

}






#####################   ここから本体  ######################

[int][ValidateRange(0,2147483647)]$ErrorCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$NormalCount = 0

$DatumPath = $PSScriptRoot

$Version = '20200207_1615'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

[String]$FlagValue = ${SHELLNAME} + (Get-Date).ToString($LogDateFormat)
[String]$FlagPath = Join-Path -Path $FlagFolder -ChildPath $FlagFile

    IF(CheckLeaf -CheckPath $FlagPath -ObjectName 'フラグファイル'){

        Logging -EventID $WarningEventID -EventType Warning -EventMessage "フラグファイル[$($FlagPath)]が存在するため警告終了扱いにします"
        Finalize $WarningReturnCode
    
        }else{
       

        Logging -EventID $InfoEventID -EventType Information -EventMessage "フラグファイル[$($FlagPath)]が存在しないため正常終了扱いにします"
                
            IF($CreateFlag){
    
                TryAction -ActionType MakeNewFileWithValue -ActionFrom $FlagPath -ActionError $FlagPath -FileValue $FlagValue
                Logging -EventID $SuccessEventID -EventType Success -EventMessage "フラグファイル[$($FlagPath)]の生成に成功しました"
    
                }
        }



#終了メッセージ出力

Finalize $NormalReturnCode

