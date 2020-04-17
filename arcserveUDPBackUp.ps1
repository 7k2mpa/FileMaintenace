#Requires -Version 3.0

<#
.SYNOPSIS
This script start arcserve UDP backup job with arcserve UDP CLI.
CommonFunctions.ps1 is required.

arcserveUDP ver.6以降で実装されたCLI経由でバックアップジョブを起動するプログラムです。
実行にはCommonFunctions.ps1が必要です。

<Common Parameters>はサポートしていません

.DESCRIPTION
This script start arcserve UDP backup job with arcserve UDP CLI.
CommonFunctions.ps1 is required.
Can specify full or incremental backup.
Can specify authorization style plain password or password file.
If you want to specify password authorization, execution user must be same with user of password file.
It is a future of Windows.

If you specify -ExecUser arcserve and start script with another user, can not authorization with password file of 'arcserve' user.

This script support the location of arcserve backup console server both in the same host or in the other.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually.  

Path sample

D:\script\infra\arcserveUDPBackUp.ps1
D:\script\infra\Log\backup.flg
D:\script\infra\UDP.psw


arcserveUDP CLI経由でバックアップジョブを起動するプログラムです。
バックアップはフルバックアップ、差分バックアップを選択できます。
認証はパスワード平文、パスワードファイル、両方をサポートしています。
パスワードファイルを用いる場合、実行ユーザはパスワードを作成したユーザと同一にする必要があります。これはWindowsOSの仕様です。
例えば設定ファイルで$ExecUserを'arcserve'とし、プログラムを実行しているユーザが異なる場合はパスワードファイルを'arcserve'ユーザで作成しても認証する事は出来ません。
ジョブスケジューラ等で実行する時のユーザを'arcserve'として実行して下さい。

このプログラムとバックアップコンソールサーバとは同一または異なるホスト、両方をサポートしています。
バックアップコンソールをCPUコア数の多いバックアップサーバに搭載した場合、大量のジョブスケジューラライセンスが必要ですが、異なるホストに当プログラムを配置する事でライセンスを節約可能です。

ログ出力先は[Windows EventLog][コンソール][ログファイル]が選択可能です。それぞれ出力、抑止が指定できます。

ファイル配置例

D:\script\infra\arcserveUDPBackUp.ps1
D:\script\infra\Log\backup.flg
D:\script\infra\UDP.psw




---



.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -Server SVDB01 -BackUpJobType Incr

Start incremental backup targeting server [SVDB] in the plan [SSDB] 

arcserveUDPのバックアッププラン[SSDB]に含まれる、サーバ[SVDB01]を差分バックアップ起動します。

.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -AllServers -BackUpJobType Full -UDPConsoleServerName BKUPSV01.corp.local

Start full backup targeting all servers in the plan [SSDB]
and specify arcserve UDP console BKUPSV01.corp.local 

arcserveUDPのバックアッププラン[SSDB]に含まれる、全てのサーバをフルバックアップ起動します。
arcserveUDPのコンソールサーバはBKUPSV01.corp.localを指定します。

.EXAMPLE



arcserveUDPBackUp.ps1 -Plan SSDB -Server SVDB02 -BackUpJobType Incr -AuthorizationType PlainText -ExecUser = 'arcserve' -ExecUserDomain = 'INTRA' -ExecUserPassword = 'hogehoge'

Start incremental backup targeting server[SVDB02] in the plan [SSDB] 
with plain password.
Specify execution backup domain user [INTRA\arcserve] password [hogehoge]
You can specify other user from running the script, but you shoud not use plain pssword for security reason.

arcserveUDPのバックアッププラン[SSDB]に含まれる、サーバ[SVDB02]を差分バックアップ起動します。
認証方式は平文パスワードとします。
バックアップコンソールサーバの管理ユーザはドメインユーザINTRA\arcserve、パスワードはhogehogeを指定します。
認証方式を平文パスワードとした場合、このプログラムを実行しているユーザと異なるユーザを指定する事が出来ます。


.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -AllServers -BackUpJobType Full -AuthorizationType JobExecUserAndPasswordFile -ExecUserPasswordFilePath '.\UDP.psw'

Start full backup targeting all servers in the plan [SSDB] 
Autorization style is execution user of the script and password file.
You need to make password file in the same user of executing the script.
Password file name is set with the user name automatically.
'_[username]' is added to the filename to load.
If you specify '.\UDP.psw' and execution user is 'Domain\arcserve' , this script load the password file '.\UDP_arcserve.psw'

arcserveUDPのバックアッププラン[SSDB]に含まれる、全てのサーバをフルバックアップ起動します。
認証方式はジョブ実行ユーザとパスワードファイルとします。ジョブ実行ユーザでバックアップコンソールサーバにログオンします。
この時のパスワードは予めジョブ実行ユーザのパスワードファイルを作成しておく必要があります。
パスワードファイルは指定したファイル名UDP.pswを自動変換します。
このプログラムを実行するユーザがDomain\arcserveの時には、ファイル名本体にアンダースコア'_'に続いてユーザ名[arcserve]を自動的に付加したファイル名UDP_arcserve.pswを読み込み、パスワードファイルとして使用します。


.PARAMETER Plan
Specify the plan in arcserve UDP.
Specification is required.
Wild card dose not be accepted.

arcserveUDPに登録してあるプラン名を指定します。
指定は必須です。

ワイルドカード*は使用できません。

.PARAMETER Server
Specify one server name in the -Plan option.
Can not specify a server name not in the plan.
Wild card dose not be accepted.

arcserveUDPに登録してあるプランに含まれるサーバ名を1台分指定します。
プランに含まれないサーバは指定できません。
ワイルドカード*は使用できません。

.PARAMETER AllServers
If you want specify all servers in the plan.

arcserveUDPに登録してあるプランに含まれるサーバ全てをバックアップ対象にします。

.PARAMETER BackUpJobType
Specify back up type.
Full:Full BackUp
Incr:Incremental BackUp

対象のバックアップ方式をしています。

Full:フルバックアップ
Incr:増分バックアップ




.PARAMETER BackupFlagFilePath
Specify lock file path of back up status.
This script generete and save flag file with plan name and server name added.
If specify -AllServers option, file name be with 'All'

バックアップ中を示すバックアップファイルの保存先パスを指定します。
ファイル名.拡張子で指定しますが、ファイル名に自動的に_Plan名_バックアップ対象サーバ名を付加したファイル名で保存します。
AllServersを指定した場合、バックアップサーバ名はAllとなります。


.PARAMETER PROTOCOL

Specify protocol to logon to arcserve UDP console server.
http or https are allowed.
[http] is default.

arcserveUDPコンソールサーバにログオンする時のプロトコルを指定します。
http / httpsを指定してください。
デフォルトはhttpです。

.PARAMETER UDPConsolePort

Specify port number to logon to arcserve UDP console server.
[8015] is default.

arcserveUDPコンソールサーバにログオンする時の通信ポート番号を指定します。
デフォルトは8015です。


.PARAMETER UDPCLIPath

Specify arcserve UDP CLI folder path.
Relative or absolute path format is allowed.

arcserveUDP CLIが配置されたパスを指定します。
相対、絶対パスで指定可能です。


.PARAMETER AuthorizationType

Specify authorization type to logon to the arcserve UDP console server.

JobExecUserAndPasswordFile:script execution user / password file(user name is added to the file name )
FixedPasswordFile:fixed user / password file
PlanText:fixed user / plain password string

arcserveUDPコンソールサーバにログオンする認証方式を指定します。

JobExecUserAndPasswordFile:本プログラムを実行しているユーザ / 本プログラムを実行しているユーザ名を含むパスワードファイル
FixedPasswordFile:指定したユーザ / 指定したパスワードファイル
PlanText:指定したユーザ / 平文パスワード

.PARAMETER ExecUser

Specify OS user to logon to the arcserve UDP console in authorization type PlainText or FixedPasswordFile.
If domain user runs the script, you specify user name without domain name.

Sample:FooDOMAIN\BarUSER , specify -ExecUser BarUSER

認証方式をPlainText , FixedPasswordFileとした時のarcserveUDPコンソールサーバログオンのOSユーザ名を指定します。
ドメインユーザの場合、ドメイン部分を除去したものを指定してください。

例:FooDOMAIN\BarUSERであれば、BarUSER


.PARAMETER ExecUserDomain

Specify OS user's domain to logon to the arcserve UDP console in authorization type PlainText or FixedPasswordFile.

Sample:FooDOMAIN\BarUSER , specify -ExecDomain FooDOMAIN


認証方式をPlainText , FixedPasswordFileとした時のarcserveUDPコンソールサーバログオンOSユーザのドメイン名を指定します。

例:FooDOMAIN\BarUSERであれば、FooDOMAIN

.PARAMETER ExecUserPassword
認証方式をPlainTextとした時のarcserveUDPコンソールサーバログオンOSユーザのパスワードを平文で指定します。


.PARAMETER FixedPasswordFilePath
Specify password file path in authorization style [FixedPasswordFile] to logon to the arcserve UDP console.

認証方式をFixedPasswordFileとした時のarcserveUDPコンソールサーバログオンOSユーザのパスワードファイルを指定します。



.PARAMETER ExecUserPasswordFilePath

Specify password file path in authorization style [JobExecUserAndPasswordFile] to logon to the arcserve UDP console.

Sample:'.\UDP.psw' , script running user FooDOMAIN\BarUSER
password file '.UDP_BarUSER.psw' will be loaded automatically.

_ and script running user name is inserted to the path specificated.

認証方式をJobExecUserAndPasswordFileとした時のarcserveUDPコンソールサーバログオンOSユーザのパスワードファイルパスを指定します。

例:'.\UDP.psw' , 本プログラムを実行しているユーザがFooDOMAIN\BarUSER
'.UDP_BarUSER.psw'がパスワードファイルとして指定されます。
アンダースコア_以降の部分は実行しているユーザ名が自動的に挿入されます。


.PARAMETER UDPConsoleServerName

Specify arcserve UDP console server's host name or IP address.

arcserveUDPコンソールサーバのホスト名、IPアドレスを指定します。



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

[String][parameter(mandatory=$true)]$Plan ,
[String][ValidateNotNullOrEmpty()]$Server = 'hoge-hoge',
[Switch]$AllServers,
[String][ValidateSet("Full", "Incr")]$BackUpJobType = 'Incr',

[String]$BackupFlagFilePath = '.\Lock\BackUp.flg' ,


[String][ValidateSet("http", "https")]$PROTOCOL = 'http' ,
[int]$UDPConsolePort = 8015 ,

[String]$UDPCLIPath = 'D:\arcserve\Management\PowerCLI\UDPPowerCLI.ps1',

[String]$ExecUser = 'arcserve',
[String]$ExecUserDomain = 'Domain',
[String]$ExecUserPassword = 'hogehoge',
[String]$ExecUserPasswordFilePath = '.\UDP.psw' ,
[String]$FixedPasswordFilePath = '.\UDP_arcserve.psw' ,

[String][ValidateSet("JobExecUserAndPasswordFile","FixedPasswordFile" , "PlainText")]$AuthorizationType = 'PlainText' ,

[String]$UDPConsoleServerName = 'localhost' ,



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


#パラメータの確認

    IF (-not($AllServers)) {

        $Server | Test-Hostname -ObjectName 'BackUp target -Server' -IfInvalidFinalize > $NULL
        }

    $UDPConsoleServerName | Test-Hostname -ObjectName 'arcserveUDP Console Server -UDPConsoleServerName' -IfInvalidFinalize > $NULL

#[String][ValidateSet("JobExecUserAndPasswordFile","FixedPasswordFile" , "PlanText")]$AuthorizationType = 'JobExecUserAndPasswordFile' ,


    IF ($AuthorizationType -match '^(FixedPasswordFile|PlainText)$' ) {

        $ExecUserDomain | Test-DomainName -ObjectName 'The domain of execution user -ExecUserDomain' -IfInvalidFinalize > $NULL    
        $ExecUser | Test-UserName -ObjectName 'Execution user -ExecUser ' -IfInvalidFinalize > $NULL

        }

#UDPConsoleの存在を確認

    IF (Test-Connection -ComputerName $UDPConsoleServerName -Quiet) {
    
        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "UDP Console Server [$($UDPConsoleServerName)] responsed."

        } else {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "UDP Console Server [$($UDPConsoleServerName)] did not response. Check -UDPConsoleServerName"
        Finalize $ErrorReturnCode
        }


#Password Fileの有無を確認

    IF ($AuthorizationType -match '^FixedPasswordFile$' ) {

        $FixedPasswordFilePath  = $FixedPasswordFilePath | ConvertTo-AbsolutePath -Name '-FixedPasswordFilePath'

        $FixedPasswordFilePath | Test-Leaf -Name '-FixedPasswordFilePath' -IfNoExistFinalize > $NULL
        }

    IF ($AuthorizationType -match '^JobExecUserAndPasswordFile$' ) {

        $ExecUserPasswordFilePath  = $ExecUserPasswordFilePath | ConvertTo-AbsolutePath -Name '-ExecUserPasswordFilePath'
    
        $ExecUserPasswordFilePath | Split-Path -Parent | Test-Container -Name 'Parent Folder of -ExecUserPasswordFilePath' -IfNoExistFinalize > $NULL

        }

    $BackupFlagFilePath  = $BackupFlagFilePath | ConvertTo-AbsolutePath -Name '-BackupFlagFilePath'
    
    $BackupFlagFilePath | Split-Path -Parent | Test-Container -Name 'Parent Folder of -BackupFlagFilePath' -IfNoExistFinalize > $NULL


#arcserveUDP CLIの有無を確認
    

    $UDPCLIPath = $UDPCLIPath | ConvertTo-AbsolutePath -Name 'arcserveUDP CLI -UDPCLIPath'

    $UDPCLIPath | Test-Leaf -Name 'arcserveUDP CLI -UDPCLIPath' -IfNoExistFinalize > $NULL



#処理開始メッセージ出力


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to execute arcserve UDP back up method [$($BackUpJobType)]"

}


function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

    Pop-Location

    IF ($BackupFlagFilePath | Test-Leaf -Name 'BackUp Flag') {
        Invoke-Action -ActionType Delete -ActionFrom  $BackupFlagFilePath -ActionError "BackUp Flag [$($BackupFlagFilePath)]"
        }


 Invoke-PostFinalize $ReturnCode

}



#####################   ここから本体  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.2"
 
 
#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

    [Array]$userInfo = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -split '\\'

    $DoDomain = $userInfo[0]
    $DoUser   = $userInfo[1]

#Create Invoke Command Strings

    $command = '.\"' + (Split-Path $UDPCLIPath -Leaf ) + '"'

    $command += " -UDPConsoleServerName $UDPConsoleServerName -Command Backup -BackupJobType $BackUpJobType -UDPConsoleProtocol $PROTOCOL -UDPConsolePort $UDPConsolePort -AgentBasedJob False"



    IF ($AllServers) {

       Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Back up targets are all servers in the Plan [$($Plan)]"
       $command +=  " -PlanName $Plan "
       $Server = 'All'
       
       } else {
       Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Back up target is [$($Server)] in the Plan [$($Plan)]"
       $command += " -NodeName $Server "

       }



    Switch -Regex ($AuthorizationType){

    '^JobExecUser$' {
        #今のところ、この認証方式はarcserve UDPでは出来ない。実行ユーザが権限を持っていても(パスワードファイル|パスワード)を与える必要がある
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Authorization type is [$($AuthorizationType)] Authorize with user name executing and permission."
        }

    '^JobExecUserAndPasswordFile$' {
    
        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Authorization type is [$($AuthorizationType)] Authorize with user name executing and the password file specified."

        $extension                = [System.IO.Path]::GetExtension((Split-Path -Path $ExecUserPasswordFilePath -Leaf))
        $fileNameWithOutExtention = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path -Path $ExecUserPasswordFilePath -Leaf))

        $ExecUserPasswordFileName = $fileNameWithOutExtention + "_"+$DoUser+$extension
        
        $ExecUserPasswordFilePath = $ExecUserPasswordFilePath | Split-Path -Parent | Join-Path -ChildPath $ExecUserPasswordFileName

        $ExecUserPasswordFilePath | Test-Leaf -Name '-ExecUserPasswordFilePath' -IfNoExistFinalize > $NULL

        $command += " -UDPConsoleUserName `'$DoUser`' -UDPConsoleDomainName `'$DoDomain`' -UDPConsolePasswordFile `'$ExecUserPasswordFilePath`' "
        }

    '^FixedPasswordFile$' {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Authorization type is [$($AuthorizationType)] Authorize with user specified and the password file specified."
        $Command += "-UDPConsoleDomainName `'$ExecUserDomain`' -UDPConsoleUserName `'$ExecUser`' -UDPConsolePasswordFile `'$FixedPasswordFilePath`' "
        }

    '^PlainText$' {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Authorization type is [$($AuthorizationType)] Authorize with user specified and plain password text."
        $Command += "-UDPConsoleDomainName `'$ExecUserDomain`' -UDPConsoleUserName `'$ExecUser`' -UDPConsolePassword `'$ExecUserPassword`' "
        }

    Default {

        Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error -AuthorizationType is invalid."
        Finalize $ErrorReturnCode
        }
    }

#BackUp Flag Check and Create

     $extension                = [System.IO.Path]::GetExtension((Split-Path -Path $BackupFlagFilePath -Leaf))
     $fileNameWithOutExtention = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path -Path $BackupFlagFilePath -Leaf))

     $BackupFlagFileName = $fileNameWithOutExtention + "_" + $Plan + "_" + $Server+$extension
        
     $BackupFlagFilePath = $BackupFlagFilePath | Split-Path -Parent | Join-Path -ChildPath $BackupFlagFileName



    IF ($BackupFlagFilePath | Test-Leaf -Name 'Back up flag') {

        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Back Up is running. Stop for avoiding overlap."
        Finalize $ErrorReturnCode
        }

    Test-LogPath -CheckPath $BackupFlagFilePath -ObjectName 'Folder of backup flag'

#Invoke PowerCLI command

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute arcserveUDP CLI [$($UDPCLIPath)]"

    Push-Location (Split-Path $UDPCLIPath -Parent)

    Try {
        $Return = Invoke-Expression $command 2>$errorMessage -ErrorAction Stop 
        }

        catch [Exception]{

            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute arcserveUDP CLI [$($UDPCLIPath)]"
            $errorDetail = $ERROR[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
        }


        IF ($Return -ne 0) {
                   
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Falied to start backup Server [$($Server)] in the Plan [$($Plan)] Method [$($BackUpJobType)]"
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Error Message [$($errorMessage)]"
            Finalize $ErrorReturnCode         
            }

Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully complete to start backup Server [$($Server)] in the Plan [$($Plan)] Method [$($BackUpJobType)]"

Finalize $NormalReturnCode
