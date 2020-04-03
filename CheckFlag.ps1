#Requires -Version 3.0

<#
.SYNOPSIS
This script checkes existence(or non-existence)  of a flag file, and create(or delete) the flag file.

CommonFunctions.ps1 is required.

<Common Parameters> is not supported.

バックアップ中等のフラグファイルを確認、作成するスクリプトです。
フラグファイルが存在すると警告終了Falseを、存在しないと正常終了Trueを返します。
-CreateFlagを指定するとフラグファイルを生成します。

<Common Parameters>はサポートしていません

.DESCRIPTION

This script checkes existence(or non-existence)  of a flag file, and create(or delete) the flag file.
If status of existence(or non-existence) is true, exit with normal return code.
If status of existence(or non-existence) is false, exit with warning return code.

If specify -PostAction option, the script create(or delete) the flag file.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


バックアップ中等のフラグファイルを確認、作成するスクリプトです。
フラグファイルが存在すると警告終了Falseを、存在しないと正常終了Trueを返します。
-CreateFlagを指定するとフラグファイルを生成します。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。

Sample Path

.\CheckFlag.ps1
.\CommonFunctions.ps1
..\Lock\BackUp.Flg



.EXAMPLE
.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg

Check BackUp.Flg file in the ..\Lock folder.
If the file exists, the script exit with warning return code.
If the file dose not exist, the script exit with normal return code.

For backward compatibility, run without specification -Status option, -Status will be 'NoExist' by default.

..\LockフォルダにBackUp.Flgファイルの有無を確認します。
フラグファイルが存在すると警告終了Falseを、存在しないと正常終了Trueを返します。


.EXAMPLE
.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg -Status Exist -PostAction Delete

Check BackUp.Flg file in the ..\Lock folder.
If the file dose not exists, the script exit with warning return code.
If the file exists, the script delete the flag file.

If success to delete, the script exit with normal return code.
If fail to delte, the script exit with error return code.


..\LockフォルダにBackUp.Flgファイルの有無を確認します。
ファイルが存在しないと警告終了Falseを返します。
ファイルが存在するとBackUp.Flgファイルの削除を試みます。
ファイル削除に成功すると正常終了Trueを返します。失敗すると異常終了Flaseを返します。



.PARAMETER FlagFolder
Specify the folder to check existence of flag file.
Can specify relative or absolute path format.

フラグファイルを確認、配置するフォルダを指定します。
相対パス、絶対パスでの指定が可能です。

.PARAMETER FlagFile
Specify the name of the flag file.

フラグファイル名を指定します。

.PARAMETER Status
Specify 'Exist' or 'NoExist' the flag file.
'NoExist' is by default.

確認する状態を指定します。

.PARAMETER PostAction
Specify action to the flag file after checking.

ファイル確認後、削除、生成を指定します。


.PARAMETER Log2EventLog
　Windows Event Logへの出力を制御します。
デフォルトは$TRUEでEvent Log出力します。

.PARAMETER NoLog2EventLog
　Event Log出力を抑止します。-Log2EventLog $FALSEと等価です。
Log2EventLogより優先します。

.PARAMETER ProviderName
　Windows Event Log出力のプロバイダ名を指定します。デフォルトは[Infra]です。

.PARAMETER EventLogLogName
　Windows Event Log出力のログ名をしています。デフォルトは[Application]です。

.PARAMETER Log2Console 
　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console
　コンソールログ出力を抑止します。-Log2Console $FALSEと等価です。
Log2Consoleより優先します。

.PARAMETER Log2File
　ログフィルへの出力を制御します。デフォルトは$FALSEでログファイル出力しません。

.PARAMETER NoLog2File
　ログファイル出力を抑止します。-Log2File $FALSEと等価です。
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

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
Param(

[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Specify the folder of a flag file placed.(ex. D:\Logs)or Get-Help CheckFlag.ps1')]
[ValidateNotNullOrEmpty()][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')][ValidateScript({ Test-Path $_  -PathType container })][Alias("Path","LiteralPath")]$FlagFolder ,

[String][parameter(position = 1, mandatory)][ValidateNotNullOrEmpty()][ValidatePattern ('^(?!.*(\/|:|\?|`"|<|>|\||\*|\\).*$)')]$FlagFile ,
[String][parameter(position = 2)][ValidateNotNullOrEmpty()][ValidateSet("Exist","NoExist")]$Status = 'NoExist' ,
[String][parameter(position = 3)][ValidateNotNullOrEmpty()][ValidateSet("Create","Delete")]$PostAction ,

#Planned to obsolute
[Switch]$CreateFlag ,
#Planned to obsolute

[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = 'Infra',
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,

[boolean]$Log2File = $FALSE,
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



function Initialize {

$ShellName = $PSCommandPath | Split-Path -Leaf

#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. Invoke-PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い

#For Backward compatibility

    IF ($CreateFlag) {
            $PostAction = 'Create'
            } 


#パラメータの確認


#フラグフォルダの有無を確認


    $FlagFolder = $FlagFolder | ConvertTo-AbsolutePath -ObjectName  '-FlagFolder'

    $FlagFolder | Test-Container -Name '-FlagFolder' -IfNoExistFinalize > $NULL


#フラグファイル名のValidation


    IF ($FlagFile -match '(\\|\/|:|\?|`"|<|>|\||\*)') {
    
        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "The path -FlagFile contains some characters that can not be used by NTFS"
        Finalize $ErrorReturnCode
        }

#Check invalid combination -Status and -PostAction

    IF (($Status -eq 'Exist' -and $PostAction -eq 'Create') -or ($Status -eq 'NoExist' -and $PostAction -eq 'Delete')) {

        Write-Log -EventType Error -EventID $ErrorEventID -EventMessage "Must not specify -Status [$($Status)] and -PostAction [$($PostAction)] in the same time."
        Finalize $ErrorReturnCode        
        }



#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid"

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Starting to check existence of the flag file [$($FlagFile)]"

}


function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)

 Invoke-PostFinalize $ReturnCode

}



#####################   ここから本体  ######################

$DatumPath = $PSScriptRoot

$Version = '20200330_1000'


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

[String]$flagValue = $ShellName +" "+ (Get-Date).ToString($LogDateFormat)
[String]$flagPath = $FlagFolder | Join-Path -ChildPath $FlagFile


Switch -Regex ($Status) {


    '^NoExist$' {

        IF (-not($flagPath | Test-Leaf -Name 'Flag file') -and -not($flagPath | Test-Container -Name 'Same Name file')) {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Flag file [$($flagPath)] dose not exists and terminate as NORMAL." 

            } else {
            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Flag file [$($flagPath)] exists already and terminate as WARNING."
            Finalize $WarningReturnCode    
            }
        }


    '^Exist$' {
    
        IF ($flagPath | Test-Leaf -Name 'Flag file') {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Flag file [$($flagPath)] exists and terminate as NORMAL."    

            } else {
            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Flag file [$($flagPath)] is deleted already and terminate as WARNING."
            Finalize $WarningReturnCode
            }        
        }


    Default {
            Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error. Switch Status exception has occurred. "
            Finalize $InternalErrorReturnCode    
            }
}


Switch -Regex ($PostAction) {

    '^$' {
            Break
            }


    'Create' {
    
            Invoke-Action -ActionType MakeNewFileWithValue -ActionFrom $flagPath -ActionError $flagPath -FileValue $flagValue
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to create the flag file [$($flagPath)]"
            }


    'Delete' {
    
            Invoke-Action -ActionType Delete -ActionFrom $flagPath -ActionError $flagPath
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to delete the flag file [$($flagPath)]"
            }

    Default {

            Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error. Switch PostAction exception has occurred. "
            Finalize $InternalErrorReturnCode    
            }
}

#終了メッセージ出力

Finalize $NormalReturnCode