#Requires -Version 3.0

<#
.SYNOPSIS
指定したプログラムを設定ファイルに書かれたパラメータを読み込んで、順次呼び出すプログラムです。
実行にはCommonFunctions.ps1が必要です。
セットで開発しているFileMaintenance.ps1と併用すると複数のログ処理を一括実行できます。

<Common Parameters>はサポートしていません

.DESCRIPTION
設定ファイルから1行づつパラメータを読み込み、指定したプログラムに順次実行させます。

設定ファイルは任意に設定可能です。
設定ファイルの行頭を#とすると当該行はコメントとして処理されます。
設定ファイルの空白行はスキップします。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。



設定ファイル例です。例えば以下をDailyMaintenance.txtに保存して-CommandFile .\DailyMaintenance.txtと指定して下さい。

---
#14日経過した.logで終わるファイルを削除
-TargetFolder D:\IIS\LOG -RegularExpression '^.*\.log$' -Action Delete -Days 14

#7日経過したアクセスログをOld_Logへ退避
-TargetFolder D:\AccessLog -MoveToFolder .\Old_Log -Days 7
---



.EXAMPLE

Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Command.txt
　このプログラムと同一フォルダに存在するFileMaintenance.ps1を起動します。
起動する際に渡すパラメータは設定ファイルComman.txtを1行づつ読み込み、順次実行します。


.EXAMPLE

Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Command.txt -Continue
　このプログラムと同一フォルダに存在するFileMaintenance.ps1を起動します。
起動する際に渡すパラメータは設定ファイルComman.txtを1行づつ読み込み、順次実行します。
もし、FileMaintenance.ps1を実行した結果が異常終了となった場合は、Wrapper.ps1を異常終了させず、Command.txtの次行を読み込み継続処理をします。



.PARAMETER CommandPath
　起動するプログラムパスを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
ワイルドカード*は使用できません。

.PARAMETER CommandFile
　起動するプログラムに渡すコマンドファイルを指定します。
指定は必須です。
相対、絶対パスで指定可能です。
ワイルドカード*は使用できません。

.PARAMETER CommandFileEncode
　コマンドファイルの文字コードを指定します。
デフォルトは[Default]でShif-Jisです。


.PARAMETER Continue
　起動したプログラムが異常終了しても、コマンドファイルの次行を継続処理します。
デフォルトではそのまま異常終了します。



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

[parameter(position=0, mandatory=$true , HelpMessage = '起動対象のpowershellプログラムを指定(ex. .\FileMaintenance.ps1) 全てのHelpはGet-Help Wrapper.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*\.ps1$')]$CommandPath ,
[parameter(position=1, mandatory=$true , HelpMessage = 'powershellプログラムに指定するコマンドファイルを指定(ex. .\Command.txt) 全てのHelpはGet-Help Wrapper.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommandFile,


[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default', #Default指定はShift-Jis

[Switch]$Continue,
[Switch]$Script:NoAction,

[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath ,
#[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath = ..\Log\FileMaintenance.log ,
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

$SHELLNAME=Split-Path $PSCommandPath -Leaf
$THIS_PATH = $PSScriptRoot


#イベントソース未設定時の処理
#ログファイル出力先確認
#ReturnCode確認
#実行ユーザ確認
#プログラム起動メッセージ

. PreInitialize

#ここまで完了すれば業務的なロジックのみを確認すれば良い


#パラメータの確認


#コマンドの有無を確認


    $CommandPath = ConvertToAbsolutePath -CheckPath $CommandPath -ObjectName '実行コマンド -CommandPath'

    CheckLeaf -CheckPath $CommandPath -ObjectName '実行コマンド -CommandPath' -IfNoExistFinalize > $NULL

#コマンドファイルの有無を確認
    

    $CommandFile = ConvertToAbsolutePath -CheckPath $CommandFile -ObjectName 'コマンドファイル -CommandFile'

    CheckLeaf -CheckPath $CommandFile -ObjectName 'コマンドファイル -CommandFile' -IfNoExistFinalize > $NULL


#処理開始メッセージ出力


Logging -EventID $InfoEventID -EventType Information -EventMessage "パラメータは正常です"

Logging -EventID $InfoEventID -EventType Information -EventMessage "実行コマンドは[$($CommandPath)]です"

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

    IF(-NOT(($NormalCount -eq 0) -and ($WarningCount -eq 0) -and ($ErrorCount -eq 0))){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "実行結果は正常終了[$($NormalCount)]、警告終了[$($WarningCount)]、異常終了[$($ErrorCount)]です"

        If(($Continue) -and ($ErrorCount -gt 0)){
            Logging -EventID $InfoEventID -EventType Information -EventMessage "-Continue[${Continue}]が指定されているため処理異常で異常終了せず次の定義を処理しました"
            }


    }


EndingProcess $ReturnCode

}



#####################   ここから本体  ######################

[int][ValidateRange(0,2147483647)]$NormalCount = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$ErrorCount = 0

$Version = '20200207_1615'

#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

    Try{

        $Lines = Get-Content $CommandFile -Encoding $CommandFileEncode

        }
                    catch [Exception]
                    {
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "-CommandFile読み込みに失敗しました。"
                    $ErrorDetail = $Error[0] | Out-String
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "起動時エラーメッセージ : $ErrorDetail"
                    Finalize $ErrorReturnCode
                    }


For ( $i = 0 ; $i -lt $Lines.Count; $i++ )

{

    $Line = $Lines[$i]

    Logging -EventID $InfoEventID -EventType Information -EventMessage "[$($CommandFile)]の$($i+1)行目を実行します。"



    Switch -Regex ($Line){

        #分岐1 行頭#でコメント
        '^#.*$'
                {Logging -EventID $InfoEventID -EventType Information -EventMessage "コメント[$($Line)]"}

        #分岐2 空白
        '^$'
                {Logging -EventID $InfoEventID -EventType Information -EventMessage "空白行"}

        #分岐3 コマンド実行
        default 
                {
                   Try{
        
                    Logging -EventID $InfoEventID -EventType Information -EventMessage "実行コマンドは[$($CommandPath)]、引数は[$($Line)]です"
                    Invoke-Expression "$CommandPath $Line" -ErrorAction Stop

                    }
                    catch [Exception]
                    {
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "[$($CommandPath)]の起動に失敗しました。"
                    $ErrorDetail = $Error[0] | Out-String
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "起動時エラーメッセージ : $ErrorDetail"
                    Finalize $ErrorReturnCode
                    }

                    Logging -EventID $InfoEventID -EventType Information -EventMessage "[$($CommandFile)]の$($i+1)行目の実行結果は[$($LastExitCode)]です"
                    

                    #終了コードで分岐
                    Switch ($LastExitCode){

                        #条件1 異常終了
                        {$_ -ge $ErrorReturnCode}{
 
                            $ErrorCount ++
                            Logging -EventID $WarningEventID -EventType Warning -EventMessage "[$($CommandFile)]の$($i+1)行目は異常終了しました"
       

                            IF($Continue){
                                Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]のため処理を継続します。"   
                                ;Break     
     
                                }else{
                                Finalize $ErrorReturnCode
                                }
                        }
                    
                        #条件2 警告終了
                        {$_ -ge $WarningReturnCode}{
                            
                            $WarningCount ++
                            Logging -EventID $WarningEventID -EventType Warning -EventMessage "[$($CommandFile)]の$($i+1)行目は警告終了しました。継続します" 
                            ;Break        
                        }
                        
                        #条件3 正常終了
                        Default {
                        $NormalCount ++
                        Logging -EventID $SuccessEventID -EventType Success -EventMessage "[$($CommandFile)]の$($i+1)行目は正常終了しました"
                        }
                   }
    
   
                # 分岐3 コマンド実行 default終端 
                }

    #Switch -Regex ($Line)終端
    }

#対象群の処理ループ終端
}


#終了メッセージ出力。ここではNormalReturnCodeで呼び出すが、Finalizeでエラーカウントを見て処理してくれる

Finalize $NormalReturnCode