#Requires -Version 3.0

<#
.SYNOPSIS
ネットワークドライブをアンマウントするプログラムです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているWrapper.ps1と併用すると複数のサービスを一括起動できます。

<Common Parameters>はサポートしていません

.DESCRIPTION

マウント済ネットワークドライブをアンマウントするプログラムです。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。


.EXAMPLE
StopService.ps1 -MountedDrive F:

マウント済ネットワークドライブのF:をアンマウントします。




.PARAMETER MountedDrive

アンマウント対象のマウント済ドライブのF:を指定します。
指定必須です。




.PARAMETER Log2EventLog
　Windows Event Logへの出力を制御します。
デフォルトは$TRUEでEvent Log出力します。

.PARAMETER NoLog2EventLog
　Event Log出力を抑止します。-Log2EventLog $Falseと等価です。

.PARAMETER ProviderName
　Windows Event Log出力のプロバイダ名を指定します。デフォルトは[Infra]です。

.PARAMETER EventLogLogName
　Windows Event Log出力のログ名をしています。デフォルトは[Application]です。

.PARAMETER Log2Console 
　コンソールへのログ出力を制御します。
デフォルトは$TRUEでコンソール出力します。

.PARAMETER NoLog2Console
　コンソールログ出力を抑止します。-Log2Console $Falseと等価です。

.PARAMETER Log2File
　ログフィルへの出力を制御します。デフォルトは$Falseでログファイル出力しません。

.PARAMETER NoLog2File
　ログファイル出力を抑止します。-Log2File $Falseと等価です。

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


#>


Param(

[parameter(mandatory=$true , HelpMessage = 'ドライブレターを指定(ex. F:) 全てのHelpはGet-Help UnMountDrive.ps1')][String][ValidatePattern('^[d-zD-Z]:$')]$MountedDrive ,
#[String][ValidatePattern('^[d-z]:$')]$MountedDrive="F:",


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[C-Z]:\\).*')]$LogPath ,
[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss",

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


#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い



#パラメータの確認


#ドライブが既にマウントされているか

    $DriveLetters = (Get-WmiObject Win32_LogicalDisk).DeviceID

    IF($DriveLetters.Contains($MountedDrive)){

        Logging -EventID $InfoEventID -EventType Information -EventMessage  "ドライブ$($MountedDrive)が既に存在します"


        [Object]$Drive = Get-WMIObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $MountedDrive }
        IF($Drive.DriveType -ne 4){
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "ドライブ$($MountedDrive)はネットワークドライブではありません"
                    Finalize $ErrorReturnCode
                    }

    }else{

        Logging -EventID $ErrorEventID -EventType Error -EventMessage "ドライブ$($MountedDrive)は存在しません"
        Finalize $ErrorReturnCode
        }






#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

Logging -EventID $InfoEventID -EventType Information -EventMessage "ドライブ${MountedDrive}をアンマウントします"


}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)


EndingProcess $ReturnCode


}


#####################   ここから本体  ######################


${THIS_FILE}=$MyInvocation.MyCommand.Path       　　                    #フルパス
${THIS_PATH}=Split-Path -Parent ($MyInvocation.MyCommand.Path)          #このファイルのパス
${SHELLNAME}=[System.IO.Path]::GetFileNameWithoutExtension($THIS_FILE)  # シェル名


${Version} = '0.9.13'

$psDrive = $MountedDrive -replace ":" 


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

Try{

    Remove-SmbMapping -LocalPath $MountedDrive -Force -UpdateProfile  -ErrorAction Stop
    If ( (Get-PSDrive -Name $psDrive) 2>$Null ) {
        Remove-PSDrive -Name $psDrive -Force  -ErrorAction Stop
        }

    }

        catch [Exception]
    {
    $ErrorDetail = $Error[0] | Out-String
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "起動時エラーメッセージ : $ErrorDetail"
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "ドライブ${MountedDrive}のアンマウントに失敗しました"
	Finalize $ErrorReturnCode
    }




Logging -EventID $SuccessEventID -EventType Success -EventMessage "ドライブ${MountedDrive}のアンマウントに成功しました"
Finalize $NormalReturnCode

         