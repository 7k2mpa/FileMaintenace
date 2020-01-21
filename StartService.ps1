#Requires -Version 3.0


<#
.SYNOPSIS
指定したサービスを起動するプログラムです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているFileMaintenance.ps1と併用すると複数のサービスを一括起動できます。

<Common Parameters>はサポートしていません

.DESCRIPTION

指定したサービスを起動するプログラムです。
起動済サービスを起動指定すると警告終了します。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。


.EXAMPLE
StartService.ps1 -Service Spooler -RetrySpanSec 5 -RetryTimes 5

サービス名:Spooler（表示名はPrint Spooler）を起動します。
直ぐに起動しない場合は、5秒間隔で最大5回試行します。

起動済サービスを起動しようとした場合は、警告終了します。



.EXAMPLE
StartService.ps1 -Service Spooler -RetrySpanSec 5 -RetryTimes 5 -WarningAsNormal

サービス名:Spooler（表示名はPrint Spooler）を起動します。
直ぐに起動しない場合は、5秒間隔で最大5回試行します。

起動済サービスを起動しようとした場合は、正常終了します。



.PARAMETER Service
　起動するサービス名を指定します。
「サービス名」と（サービスの）「表示名」は異なりますので留意して下さい。。
例えば「表示名:Print Spooler」は「サービス名:Spooler」となっています。
指定必須です。

.PARAMETER RetrySpanSec
　サービス起動再確認の間隔秒数を指定します。
サービスによっては数秒必要なものもあるので適切な秒数に設定して下さい。
デフォルトは3秒です。

.PARAMETER RetryTimes
　サービス起動再確認の回数を指定します。
サービスによっては数秒必要なものもあるので適切な回数に設定して下さい。
デフォルトは5回です。




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

[parameter(mandatory=$true , HelpMessage = '開始対象のWindowsサービス名を指定(ex. spooler) 全てのHelpはGet-Help StartService.ps1')][String]$Service  ,
#[String]$Service = "ScDevice" ,

[int][ValidateRange(1,65535)]$RetrySpanSec = 3,
[int][ValidateRange(1,65535)]$RetryTimes = 5,



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



#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い



#パラメータの確認

    $ServiceExist = CheckServiceExist -ServiceName $Service -NoMessage

    IF(-NOT($ServiceExist)){
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "サービス[$($Service)]が存在しません"
        Finalize $ErrorReturnCode
        }
        
       

    $ServiceStatus = CheckServiceStatus -ServiceName $Service -Health Running -Span 0 -UpTo 1


    IF ($ServiceStatus){
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "サービス[$($Service)]は既に起動しています"
        Finalize $WarningReturnCode
        }
        


#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($Service)]の起動処理を開始します"

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

[String]$Computer = "localhost" 
[String]$Class = "win32_service" 
[Object]$WmiService = Get-Wmiobject -Class $Class -computer $Computer -filter "name = '$Service'" 


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

#以下のコードはMSのサンプルを参考
#https://gallery.technet.microsoft.com/scriptcenter/aa73bb75-38a6-4bd4-b72e-a6aede76d6ad



# カウント用変数初期化
$Counter = 0


    # 無限ループ
    While ($true) {

      # チェック回数カウントアップ
      $Counter++

      # サービス存在確認
      IF(-NOT(CheckServiceExist $Service)){
      Finalize $ErrorReturnCode
      }


        Logging -EventID $InfoEventID -EventType Information -EventMessage "WMIService.startServiceでサービス[$($Service)]の起動を開始します..."
        
        $Return = $WMIService.startService() 


           Switch ($Return.returnvalue)  {
        
                0{
                $ServiceStatus = CheckServiceStatus -ServiceName $Service -Health Running -Span $RetrySpanSec -UpTo $RetryTimes

                    
                    IF ($ServiceStatus){
                    Logging -EventID $SuccessEventID -EventType Success -EventMessage "サービス[$($Service)]は正常に起動しました"
                    Finalize $NormalReturnCode
                    }else{
                    Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($Service)]は未だ正常に起動していません。再試行します"
                    }

                }


                2 {
                Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($Service)]から「アクセスが許可されていない」とレポートが出力されました"
                }

                5 { 
                Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($Service)]は現在制御を受付しません"
                } 
            
                10 {
                Logging -EventID $WarningEventID -EventType Warning -EventMessage "サービス[$($Service)]は既に起動しています"
                Finalize $WarningErrorCode
                }
              
                DEFAULT {
                Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($Service)]から以下のレポートが出力されました。ERROR $($Return.returnValue)"
                } 
            }  
    
    





        IF ($Counter -eq $RetryTimes){
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "指定期間、回数が経過しましたがサービス[$($Service)]が起動出来ませんでした"
        Finalize $ErrorReturnCode
        }

      #チェック回数の上限に達していない場合は、指定秒待機

      Logging -EventID $InfoEventID -EventType Information -EventMessage "サービス[$($Service)]は存在しますが起動できませんでした。$($RetrySpanSec)秒待機します。"
      sleep $RetrySpanSec

      # 無限ループに戻る

    }

