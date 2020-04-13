#Requires -Version 5.0
#If you do not use '-PreAction compress or archive', install WMF 3.0 and place '#Requires -Version 3.0' insted of '#Requires -Version 5.0' in FileMaintenance.ps1
#If you use '-PreAction compress or archive' with 7z, install WMF 3.0 and place '#Requires -Version 3.0' insted of '#Requires -Version 5.0' in FileMaintenance.ps1

<#

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

$Script:CommonFunctionsVersion = "2.0.0-beta.13"


#ログ等の変数を一括設定したい場合は以下を利用して下さい。
#
#各プログラムのParam変数設定、コマンドの引数、CommonFunctions.ps1の変数設定
#上記の順序で、後者の設定が優先されます。
#
#$LogPath等はこちらで設定する方が楽かも
#
#入力値は極力validationしていますが、Paramセクションで明示的に指定する場合はvalidationされません
#誤った値を指定しないように留意してください


#[boolean]$Log2EventLog = $TRUE,
#[Switch]$NoLog2EventLog,
#[String]$ProviderName = "Infra",
#[String][ValidateSet("Application")]$EventLogLogName = 'Application',

#[boolean]$Log2Console = $TRUE,
#[Switch]$NoLog2Console,
#[boolean]$Log2File = $FALSE,
#[Switch]$NoLog2File,
#[String][ValidatePattern('^(\.+\\|[C-Z]:\\).*')]$LogPath ,
#[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss",
#[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default指定はShift-Jis

#[int][ValidateRange(0,2147483647)]$NormalReturnCode = 0,
#[int][ValidateRange(0,2147483647)]$WarningReturnCode = 1,
#[int][ValidateRange(0,2147483647)]$ErrorReturnCode = 8,
#[int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16,

#[int][ValidateRange(1,65535)]$InfoEventID = 1,
[int][ValidateRange(1,65535)]$StartEventID = 8
[int][ValidateRange(1,65535)]$EndEventID = 9
#[int][ValidateRange(1,65535)]$WarningEventID = 10,
#[int][ValidateRange(1,65535)]$SuccessEventID = 73,
#[int][ValidateRange(1,65535)]$InternalErrorEventID = 99,
#[int][ValidateRange(1,65535)]$ErrorEventID = 100,

#[Switch]$ErrorAsWarning,
#[Switch]$WarningAsNormal,

#[Regex]$ExecutableUser ='.*'



function Write-Log {
<#
.SYNOPSIS
 Output Log to Windows Event Log , Console and File

#>
[CmdletBinding()]
Param(
[parameter(position = 0, mandatory)][ValidateRange(1,65535)][int][Alias("ID")]$EventID ,
[parameter(position = 1, mandatory)][String][ValidateSet("Information", "Warning", "Error" ,"Success")][Alias("Type")]$EventType ,
[parameter(position = 2, mandatory)][String][Alias("Message")]$EventMessage ,

[Switch]$Log2EventLog = $Log2EventLog ,
[Switch]$ForceConsoleEventLog = $ForceConsoleEventLog ,
[Switch]$ForceConsole = $ForceConsole ,
[String]$EventLogLogName = $EventLogLogName ,
[String]$ProviderName = $ProviderName ,
[String]$ShellName = $ShellName ,
[Switch]$Log2Console = $Log2Console ,
[Switch]$Log2File = $Log2File ,
[String]$LogDateFormat = $LogDateFormat ,
[String]$LogPath = $LogPath ,
[String]$LogFileEncode = $LogFileEncode
)
begin {
}
process {
    IF (($Log2EventLog -or $ForceConsoleEventLog) -and -not($ForceConsole) ) {

        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType $EventType -EventId $EventID -Message "[$($ShellName)] $($EventMessage)"
        }


    IF ($Log2Console -or $ForceConsole -or $ForceConsoleEventLog) {

        $consoleWrite = $EventType.PadRight(14) + "EventID " + ([String]$EventID).PadLeft(6) + "  " + $EventMessage
        Write-Host $consoleWrite
        }   


    IF ($Log2File -and -not($ForceConsole -or $ForceConsoleEventLog )) {

        $logFormattedDate = (Get-Date).ToString($LogDateFormat)
        $logWrite = $logFormattedDate + " " + $ShellName + " " + $EventType.PadRight(14) + "EventID " + ([String]$EventID).PadLeft(6) + "  " + $EventMessage
        Write-Output $logWrite | Out-File -FilePath $LogPath -Append -Encoding $LogFileEncode
        }   
}
end {
}
}


function Test-ReturnCode {
<#
.SYNOPSIS
ReturnCode大小関係確認
$ErrorReturnCode = 0設定等を考慮して異常時はExit 1で抜ける
#>
    IF (-not(($InternalErrorReturnCode -ge $WarningReturnCode) -and ($ErrorReturnCode -ge $WarningReturnCode) -and ($WarningReturnCode -ge $NormalReturnCode))) {

        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID "The magnitude relation of ReturnCodes' parameters is not set correctly."
        Write-Output "The magnitude relation of ReturnCodes is not set correctly."
        Exit 1
        }
}


function Test-EventLogSource {
<#
.SYNOPSIS
イベントソース未設定時の処理
この確認が終わるまではログ出力可能か確定しないのでコンソール出力を強制
#>
    IF ($Log2EventLog) {

        $ForceConsole = $TRUE

        Try {
            IF (-not([System.Diagnostics.Eventlog]::SourceExists($ProviderName) ) ) {
            #新規イベントソースを設定
           
                New-EventLog -LogName $EventLogLogName -Source $ProviderName  -ErrorAction Stop
                $ForceConsoleEventLog = $TRUE    
                Write-Log -EventId $InfoEventID -Type Information -Message "Regist a new source event [$($ProviderName)] to [$($EventLogLogName)]"
                }
        }
        Catch [Exception] {
        Write-Log -EventId $ErrorEventID -Type Error -Message ("Failed to regist new source event because no source $($ProviderName) exists in event log, " +
            "must have administrator privilage for registing a new source. Start PowerShell with administrator privilage and start the script.")
        Write-Log -EventId $ErrorEventID -Type Error -Message "Execution Error Message : $Error[0]"
        Exit $ErrorReturnCode
        }

        $ForceConsole = $FALSE
        $ForceConsoleEventLog = $FALSE
    }
}


function Test-LogFilePath {
<#
.SYNOPSIS
ログファイル出力先確認
この確認が終わるまではログ出力可能か確定しないのでEventLogとコンソール出力を強制
#>
    IF ($Log2File) {

        $ForceConsoleEventLog = $TRUE    

        $LogPath | ConvertTo-AbsolutePath -Name '-LogPath' | Test-LogPath -ObjectName '-LogPath' > $NULL
    
        $ForceConsoleEventLog = $FALSE
        }
}


function Invoke-Action {

[CmdletBinding()]    
Param(
[String][parameter(position = 0, mandatory)]
[ValidatePattern("^(Move|Copy|Delete|AddTimeStamp|NullClear|Rename|MakeNew(FileWithValue|Folder)|(7z|7zZip|^)(Compress|Archive)(AndAddTimeStamp|$))$")]$ActionType,

[String][parameter(position = 1, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
[Alias("Path" , "FullName")]$ActionFrom ,

[String][parameter(position = 2)]$ActionTo,
[String][parameter(position = 3)]$ActionError,
[String][parameter(position = 4)]$FileValue,

$WhatIfFlag = $WhatIfFlag ,
$OverRideFlag = $OverRideFlag ,
$ForceEndLoop = $ForceEndLoop ,
$Continue = $Continue ,
$7zFolder = $7zFolder 

)
begin {
    IF (-not($ActionType -match "^(Delete|NullClear|MakeNewFolder|Rename)$" ) -and ($NULL -eq $ActionTo)) {

        Write-Log -Id $InternalErrorEventID -Type Error -Message "Internal Error at Function Invoke-Action  [$($ActionType)] requires [$($ActionTo)]"
        Finalize $InternalErrorReturnCode
        }
}
process {
    IF ($WhatIfFlag -and ($ActionType -match "(Compress|Archive)") ) {
    
        Write-Log -Id $WarningEventID -Type Warning -Message "Specified -WhatIf[$($WhatIfFlag)] option, thus do not execute [$($ActionType)] [$($ActionError)]"
        $Script:NormalFlag = $TRUE

        IF ($OverRideFlag) {
            $Script:OverRideCount++
            $Script:InLoopOverRideCount++
            $Script:OverRideFlag = $FALSE            
            }
        Return
        }
    
    Try {
  
       Switch -Regex ($ActionType) {

        '^(Copy|AddTimeStamp)$' {
            Copy-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $NULL -ErrorAction Stop
            }

        '^(Move|Rename)$' {
            Move-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $NULL -ErrorAction Stop
            }

        '^Delete$' {
            Remove-Item -LiteralPath $ActionFrom -Force > $NULL -ErrorAction Stop
            }
                       
        '^NullClear$' {
            Clear-Content -LiteralPath $ActionFrom -Force > $NULL -ErrorAction Stop
            }

        '^(Compress|CompressAndAddTimeStamp)$' {
#           $ActionTo = $ActionTo -replace "\[" , "````["
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Force > $NULL  -ErrorAction Stop
            }                  
                                       
        '^MakeNewFolder$' {
            New-Item -ItemType Directory -Path $ActionFrom > $NULL  -ErrorAction Stop
            }

        '^MakeNewFileWithValue$' {
            New-Item -ItemType File -Path $ActionFrom -Value $FileValue > $NULL -ErrorAction Stop
            }

        '^(Archive|ArchiveAndAddTimeStamp)$' {
#           $ActionTo = $ActionTo -replace "\[" , "````["
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Update > $NULL  -ErrorAction Stop
            }                  

        '^((7z|7zZip)(Archive|Compress)($|AndAddTimeStamp))$' {

            Push-Location -LiteralPath $7zFolder

            IF ($ActionType -match '7zZip') {
                
                $7zType = 'zip'
                
                } else {
                $7zType = '7z'
                }

            Switch -Regex ($ActionType){
            
                'Compress' {
                    [String]$errorDetail = .\7z.exe a $ActionTo $ActionFrom -t"$7zType" 2>&1
                    Break
                    }

                'Archive' {
                    [String]$errorDetail = .\7z.exe u $ActionTo $ActionFrom -t"$7zType" 2>&1
                    Break
                    }
            
                Default {
                    Pop-Location 
                    Throw "Internal error in 7Zip Section with Action Type"
                    }            
                }

            Pop-Location
            $processErrorFlag = $TRUE
            IF ($LASTEXITCODE -ne 0) {

                Throw "error in 7zip"            
                }
            }
                                           
        Default {
            Write-Log -Id $InternalErrorEventID -Type Error -Message "Internal Error at Function Invoke-Action. Switch ActionType exception has occurred. "
            Finalize $InternalErrorReturnCode
            }
      }       
   
   
   
    }   
    catch [Exception] {
       
        Write-Log -Id $ErrorEventID -Type Error -Message "Failed to execute [$($ActionType)] to [$($ActionError)]"
        IF (-not($processErrorFlag)) {
            $errorDetail = $Error[0] | Out-String
            }
        Write-Log -Id $ErrorEventID -Type Error -Message "Execution Error Message : $errorDetail"
        $Script:ErrorFlag = $TRUE

        IF ($Continue) {
            Write-Log -Id $WarningEventID -Type Warning -Message "Specified -Continue option, continue to process next objects."
            $Script:WarningFlag = $TRUE
            $Script:ContinueFlag = $TRUE
            Return
            }

        #Continueしない場合は終了処理へ進む
        IF ($ForceEndLoop) {
            $Script:ErrorFlag = $TRUE
            $Script:ForceFinalize = $TRUE
            Break

            } else {
            Finalize $ErrorReturnCode
            }   
    }

   IF ($ActionType -match '^(Copy|AddTimeStamp|Rename|(7z|7zZip|^)(Compress|Archive)(AndAddTimeStamp|$))$' ) {
        Write-Log -Id $InfoEventID -Type Information -Message "$($ActionTo) was created."
        }


    IF ($OverRideFlag) {
        $Script:OverRideCount ++
        $Script:InLoopOverRideCount ++
        $Script:OverRideFlag = $FALSE
        }
           
    Write-Log -Id $SuccessEventID -Type Success -Message "Successfully completed to [$($ActionType)] to [$($ActionError)]"
    $Script:NormalFlag = $TRUE
}
end {
}
}


function ConvertTo-AbsolutePath {

<#
.SYNOPSIS
 相対パスから絶対パスへ変換

.DESCRIPTION
 このfunctionは検査対象パスがNull , emptyの場合、異常終了します。確認が必要なパスのみを検査して下さい。
 * ?等のNTFSに使用できない文字がパスに含まれている場合は異常終了します
 []のPowershellでワイルドカードとして扱われる文字は、ワイルドカードとして扱いません。LiteralPathとしてそのまま処理します
 なおInvoke-Actionはワイルドカード[]を扱いません。LiteralPathとしてそのまま処理します

.PARAMETER CheckPath
 相対パスまたは絶対パスを指定してください。
 相対パスは.\ または ..\から始めて下さい。

.PARAMETER ObjectName
 ログに出力するCheckPathの説明文を指定してください。

 .INPUT
 System.String

 .OUTPUT
 System.String

#>

[OutputType([String])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("CheckPath" , "FullName")]$Path ,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("ObjectName")]$Name ,

[String]$DatumPath = $DatumPath
)
begin {
}
Process {

    $Path | Test-PathNullOrEmpty -Name $Name -IfNullOrEmptyFinalize > $NULL
    
    #Windowsではパス区切に/も使用できる。しかしながら、処理を簡単にするため\に統一する

    $Path = $Path.Replace('/','\')

    IF (Test-Path -LiteralPath $Path -IsValid) {
        Write-Log -Id $InfoEventID -Type Information -Message "$Name[$($Path)] is valid path format."
   
        } else {
        Write-Log -Id $ErrorEventID -Type Error -Message "$Name[$($Path)] is invalid path format. The path may contain a drive letter not existed or characters that can not use by NTFS."
        Finalize $ErrorReturnCode
        }


    Switch -Regex ($Path) {

        "^\.+\\.*" {
       
            Write-Log -Id $InfoEventID -Type Information -Message "$Name[$($Path)] is relative path format."

            $convertedPath = $DatumPath | Join-Path -ChildPath $Path | ForEach-Object {[System.IO.Path]::GetFullPath($_)}
         
            Write-Log -Id $InfoEventID -Type Information -Message "Convert to absolute path format [$($convertedPath)] with joining the folder path [$($DatumPath)] the script is placed and the path [$($Path)]"

            $Path = $convertedPath
            }

        "^[c-zC-Z]:\\.*" {

            Write-Log -Id $InfoEventID -Type Information -Message "$Name[$($Path)] is absolute path format."
            
            $Path = $Path | ForEach-Object {[System.IO.Path]::GetFullPath($_)}            
            
            }

        "^\\\\.*\\.*" {

            Write-Log -Id $InfoEventID -Type Information -Message "$Name[$($Path)] is UNC path format."
            
            $Path = $Path | ForEach-Object {[System.IO.Path]::GetFullPath($_)}            
            
            }

        Default {
      
            Write-Log -Id $ErrorEventID -Type Error -Message "$Name[$($Path)] is neither absolute path format nor relative path format."
            Finalize $ErrorReturnCode
            }
    }

#パスに\\が連続すると処理が複雑になるので、使わせない[System.IO.Path]::GetFullPath()で処理される

    #パスがフォルダで末尾に\が存在した場合は削除する。末尾の\有無で結果は一緒なのだが、統一しないと文字列数が異なるためパス文字列切り出しが誤動作する。

    IF ($Path.EndsWith('\')) {
    
            Write-Log -Id $InfoEventID -Type Information -Message "Windows path format allows the end of path with a path separator '\' , due to processing limitation, remove it."
            $Path = $Path.Substring(0, $Path.Length -1)
            }


    #TEST-Path -isvalidはコロン:の含まれているPathを正しく判定しないので個別に判定

    IF (($Path | Split-Path -noQualifier) -match '(\/|:|\?|`"|<|>|\||\*)') {
    
                Write-Log -Type Error -Id $ErrorEventID -Message "$Name may contain characters that can not use by NTFS  such as BackSlash/ Colon: Question? DoubleQuote`" less or greater than<> astarisk* pipe| "
                Finalize $ErrorReturnCode
                }


    #Windows予約語がパスに含まれているか判定

    IF ($Path -match '\\(AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])(\\|$|\..*$)') {

                Write-Log -Type Error -Id $ErrorEventID -Message "$Name may contain the Windows reserved words such as (AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])"
                Finalize $ErrorReturnCode
                }        

    Write-Output $Path
}
end {
}


}

 
function ConvertTo-FileNameAddTimeStamp {

[OutputType([String])]
[CmdletBinding()]

Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("TargetFileName")]$Name ,
[String][parameter(position = 1, mandatory)]$TimeStampFormat 
)

begin {
    $formattedDate = (Get-Date).ToString($TimeStampFormat)
}

process {
    $extension                = [System.IO.Path]::GetExtension($Name)
    $fileNameWithOutExtention = [System.IO.Path]::GetFileNameWithoutExtension($Name)

    Write-Output ($fileNameWithOutExtention + $formattedDate + $extension)
}

end {
}
}


function Test-ServiceExist {

<#
.SYNOPSIS
 Check existence of specified Windows Service

.PARAMETER ServiceName
 確認するWindows Serviceを指定してください。

.PARAMETER NoMessage
 ログ出力を抑止します。

 .INPUT
 System.String

 .OUTPUT
 Boolean

#>

[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("Name")]$ServiceName ,
[Switch]$NoMessage
)
begin {
}
process {
# サービス状態取得

    $service = Get-Service | Where-Object {$_.Name -eq $ServiceName}

    IF ($service.Status -Match "^$") {
        IF (-not($NoMessage)) {
            Write-Log -Id $InfoEventID -Type Information -Message "Service [$($ServiceName)] dose not exist."
            }
        Write-Output $FALSE

        } else {

        IF (-not($NoMessage)) {
            Write-Log -Id $InfoEventID -Type Information -Message "Service [$($ServiceName)] exists."
            }
        Write-Output $TRUE
        }
}
end {
}
}


function Test-ServiceStatus {
<#
#サービス状態確認
#引数$Healthで状態(Running|Stopped)を指定してください。戻り値は指定状態で$TRUEまたは非指定状態$FALSE
#サービス起動、停止しても状態推移には時間が掛かります。このfunctionは一定時間$Span、一定回数$UpTo、状態確認を繰り返します
#起動が遅いサービスは$Spanを大きくしてください
#>
[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("Name")]$ServiceName ,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][ValidateSet("Running", "Stopped")][Alias("Status")]$Health = 'Running' ,

[int][ValidateRange(0,2147483647)]$Span = 3 ,
[int][ValidateRange(0,2147483647)]$UpTo = 10
)
begin {
}
process {

$status = $FALSE

    For ( $i = 0 ; $i -le $UpTo; $i++ ) {
        # サービス存在確認
        IF (-not($ServiceName | Test-ServiceExist -NoMessage)) {
            Break
            }

        # サービス状態判定
        $service = Get-Service | Where-Object {$_.Name -eq $ServiceName}

        IF ($service.Status -eq $Health) {
            Write-Log -Id $InfoEventID -Type Information -Message "Service [$($ServiceName)] exists and status is [$($service.Status)]"
            $status = $TRUE
            Break     
            
            } elseIF (($Span -eq 0) -and ($UpTo -le 1)) {
                
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($ServiceName)] exists and status is [$($service.Status)]"
                Break
                }


        # サービスは指定状態へ遷移しなかった

        IF ($i -ge $UpTo) {
            Write-Log -Id $InfoEventID -Type Information -Message ("Service [$($ServiceName)] exists and status is [$($Service.Status)] now. " +
                "The specified waiting times has elapsed but the service has not switched to status [$($Health)]")
            Break
            }


        # 指定間隔(秒)待機

        Write-Log -Id $InfoEventID -Type Information -Message ("Service [$($ServiceName)] exists and status is [$($Service.Status)] , " +
            "is not [$($Health)] Wait for $($Span)seconds. Retry [" + ($i+1) + "/$UpTo]")
        Start-Sleep -Seconds $Span        
    }

Write-Output $status
}
end {
}
}


function Test-PathNullOrEmpty {

[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("CheckPath" , "FullName")]$Path ,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("ObjectName")]$Name,

[Switch]$IfNullOrEmptyFinalize,
[Switch]$NoMessage
)
begin {
}
process {

    IF ([String]::IsNullOrEmpty($Path)) {

        Write-Output $TRUE

        IF ($IfNullOrEmptyFinalize) {
           
           Write-Log -Id $ErrorEventID -Type Error -Message "$($Name) is required."
           Finalize $ErrorReturnCode
           }                

        } else {
        Write-Output $FALSE 
        }
}
end {
}
}


function Test-Container {

[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("CheckPath" , "FullName")]$Path,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("ObjectName")]$Name,

[Switch]$IfNoExistFinalize
)
begin {
}
process {

    IF (Test-Path -LiteralPath $Path -PathType Container) {

        Write-Log -Id $InfoEventID -Type Information -Message "$($Name)[$($Path)] exists."
        Write-Output $TRUE

        } else {
        Write-Log -Id $InfoEventID -Type Information -Message "$($Name)[$($Path)] dose not exist."
        Write-Output $FALSE
            
        IF($IfNoExistFinalize){
            Write-Log -Id $ErrorEventID -Type Error -Message "$($Name) is required."
            Finalize $ErrorReturnCode
            }
    }
}
end {
}
}


function Test-Leaf {

[OutputType([Boolean])]
[CmdletBinding()]
Param(
[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("CheckPath" , "FullName")]$Path,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("ObjectName")]$Name,

[Switch]$IfNoExistFinalize
)
begin {
}
process {

    IF (Test-Path -LiteralPath $Path -PathType Leaf) {

        Write-Log -Id $InfoEventID -Type Information -Message "$($Name)[$($Path)] exists."
        Write-Output $TRUE

        } else {

        Write-Log -Id $InfoEventID -Type Information -Message "$($Name)[$($Path)] dose not exist."
        Write-Output $FALSE
            
        IF($IfNoExistFinalize){
            Write-Log -Id $ErrorEventID -Type Error -Message "$($Name) is required."
            Finalize $ErrorReturnCode
            }
    }
}
end {
}
}


function Test-LogPath {
[OutputType([boolean])]
[CmdletBinding()]
Param(

[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("CheckPath" , "FullName")]$Path,
[String][parameter(position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("ObjectName")]$Name,
[String]$FileValue = $NULL

)
begin {
    $logFormattedDate = (Get-Date).ToString($LogDateFormat)
}
process {
 
    IF (-not($Path | Split-Path -Parent)) {
        Write-Log -Id $ErrorEventID -Type Error -Message "$($Name)[$($Path)] is invalid specification."   
        Finalize $ErrorReturnCode
        }

    #ログ出力先ファイルの親フォルダが存在しなければ異常終了

    $Path | Split-Path -Parent | Test-Container -ObjectName $Name -IfNoExistFinalize > $NULL

    #ログ出力先（予定）ファイルと同一名称のフォルダが存在していれば異常終了

    IF (Test-Path -LiteralPath $Path -PathType Container) {
        Write-Log -Id $ErrorEventID -Type Error -Message "Same name folder $($Path) exists already."        
        Finalize $ErrorReturnCode
        }


    IF (Test-Path -LiteralPath $Path -PathType Leaf) {

        Write-Log -Id $InfoEventID -Type Information -Message "Check write permission of $($Name) [$($Path)]"
        $logWrite = $logFormattedDate+" "+$ShellName+" Write Permission Check"
        

        Try {
            Write-Output $logWrite | Out-File -FilePath $Path -Append -Encoding $LogFileEncode -ErrorAction Stop
            Write-Log -Id $InfoEventID -Type Information -Message "Successfully complete to write to $($Name) [$($Path)]"
            }
        Catch [Exception]{
            Write-Log -Type Error -Id $ErrorEventID -Message  "Failed to write to $($Name) [$($Path)]"
            Write-Log -Id $ErrorEventID -Type Error -Message "Execution error message : $Error[0]"
            Finalize $ErrorReturnCode
            }
     
     } else {
            Invoke-Action -ActionType MakeNewFileWithValue -ActionFrom $Path -ActionError $Path -FileValue $FileValue
            }
}
end {
}
}


function Test-ExecUser {

Param(
[Regex]$ExecutableUser = $ExecutableUser
)

    $Script:ScriptExecUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    Write-Log -Id $InfoEventID -Type Information -Message "Executed in user [$($ScriptExecUser.Name)]"

    IF (-not($ScriptExecUser.Name -match $ExecutableUser)) {
        Write-Log -Type Error -Id $ErrorEventID -Message "Executed in an unauthorized user."
        Finalize $ErrorReturnCode
        }
}


function Invoke-PreInitialize {

$ERROR.clear()
$ForceConsole = $FALSE
$ForceConsoleEventLog = $FALSE

#ReturnCode確認

. Test-ReturnCode


#イベントソース未設定時の処理

. Test-EventLogSource


#ログファイル出力先確認

. Test-LogFilePath



#ここはfunctionなので変数はfunction内でのものとなる。スクリプト全体に反映するにはスコープを明示的に$Script:変数名とする

#ログ抑止フラグ処理

IF ($NoLog2EventLog) {[boolean]$Script:Log2EventLog = $FALSE}
IF ($NoLog2Console)  {[boolean]$Script:Log2Console  = $FALSE}
IF ($NoLog2File)     {[boolean]$Script:Log2File     = $FALSE}


Write-Log -Id $StartEventID -Type Information -Message "Start $($ShellName) Version $($Version)"

Write-Log -Id $InfoEventID -Type Information -Message "Loaded CommonFunctions.ps1 Version $($CommonFunctionsVersion)"

Write-Log -Id $InfoEventID -Type Information -Message "Start to validate parameters."

. Test-ExecUser


}


function Invoke-PostFinalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)

    IF (($ErrorCount -gt 0) -or ($ReturnCode -ge $ErrorReturnCode)) {

        IF ($ErrorAsWarning) {
            Write-Log -Id $WarningEventID -Type Warning -Message "Terminated with an Error, specified -ErrorAsWarning[$($ErrorAsWarning)] option, thus the exit code is [$($WarningReturnCode)]"  
            $returnCode = $WarningReturnCode
           
            } else {
            Write-Log -Id $ErrorEventID -Type Error -Message "Terminated with An Error, thus the exit code is [$($ErrorReturnCode)]"
            $returnCode = $ErrorReturnCode
            }

        } elseIF (($WarningCount -gt 0) -or ($ReturnCode -ge $WarningReturnCode)) {

            IF ($WarningAsNormal) {
                Write-Log -Id $InfoEventID -Type Information -Message "Terminated with a Warning, specified -WarningAsNormal[$($WarningAsNormal)] option, thus the exit code is [$($NormalReturnCode)]" 
                $returnCode = $NormalReturnCode
           
                } else {
                Write-Log -Id $WarningEventID -Type Warning -Message "Terminated with a Warning, thus the exit code is [$($WarningReturnCode)]"
                $returnCode = $WarningReturnCode
                }
        
        } else {
        Write-Log -Id $SuccessEventID -Type Success -Message "Completed successfully. The exit code is [$($NormalReturnCode)]"
        $returnCode = $NormalReturnCode               
        }

    Write-Log -Id $EndEventID -Type Information -Message "Exit $($ShellName) Version $($Version)"

Exit $returnCode

}


function Invoke-SQL {
[OutputType([PSObject])]
[CmdletBinding()]
Param(

[parameter(position = 0, mandatory)][String]$SQLCommand ,
[parameter(position = 1, mandatory)][String]$SQLName ,
[parameter(position = 2)][String]$SQLLogPath = $SQLLogPath ,

[Switch]$IfErrorFinalize ,


[Boolean]$PasswordAuthorization = $PasswordAuthorization ,
[String]$ShellName = $ShellName ,
[String]$LogFileEncode = $LogFileEncode ,
[String]$LogDateFormat = $LogDateFormat , 
[String]$ExecUser = $ExecUser ,
[String]$ExecUserPassword = $ExecUserPassword
)
begin {
    $scriptExecUser = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name
    $logFormattedDate = (Get-Date).ToString($LogDateFormat)

#Powershellではヒアドキュメントの改行はLFとして処理される
#しかしながら、他のOracleからの出力はLF&CRのため、Windowsメモ帳で開くと改行コードが混在して正しく処理されない
#よって、明示的にCRを追加してSQLLogで改行コードが混在しないようにする
#Sakura Editor等では改行コード混在も正しく処理される

$logWrite = @"
`r
`r
----------------------------`r
DATE: $logFormattedDate`r
SHELL: $ShellName`r
SQL: $SQLName`r
`r
OS User: $scriptExecUser`r
`r
SQL Exec User: $ExecUser`r
Password Authrization [$PasswordAuthorization]`r
`r
"@

    $invokeResult = New-Object PSObject -Property @{
    Status = $NULL
    Log = $NULL
    }

}
process {

Write-Output $logWrite | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode

Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization) {

        $invokeResult.Log = $SQLCommand | SQLPlus.exe $ExecUser/$ExecUserPassword@OracleSerivce as sysdba

        } else {
        $invokeResult.log = $SQLCommand | SQLPlus.exe / as sysdba
        }

Pop-Location

Write-Output $invokeResult.log | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode

    IF ($LASTEXITCODE -ne 0) {

        Write-Log -Id $ErrorEventID -Type Error -Message "Failed to execute SQL Command[$($SQLName)]"
   
            IF ($IfErrorFinalize) {
            Finalize $ErrorReturnCode
            }
   
        $invokeResult.Status = $FALSE

        } else {
        Write-Log -Id $SuccessEventID -Type Success -Message "Successfully completed to execute SQL Command[$($SQLName)]"
        $invokeResult.Status = $TRUE
        }
Write-Output $invokeResult
}
end {
}
}


function Test-OracleBackUpMode {

[OutputType([PSObject])]
[CmdletBinding()]
 Param(
 [String]$DBCheckBackUpMode = $DBCheckBackUpMode ,
 [String]$SQLLogPath = $SQLLogPath
 )

 begin {
 }
 process {
    Write-Log -Id $InfoEventID -Type Information -Message "Get the backup status of Oracle Database ,determine Oracle Database is running in which mode BackUp/Normal. A line [Active] is in BackUp Mode."
    
    $invokeResult = Invoke-SQL -SQLCommand $DBCheckBackUpMode -SQLName "DBCheckBackUpMode" -SQLLogPath $SQLLogPath

   
    #文字列配列に変換する
    $sqlLog = $invokeResult.Log -replace "`r","" |  ForEach-Object {$_ -split "`n"}

    $normalModeCount = 0
    $backUpModeCount = 0

    $dbStatus = New-Object PSObject -Property @{
    Normal = $FALSE
    BackUp = $FALSE
    }

    $i = 1

    foreach ($line in $sqlLog) {

        IF ($line -match 'NOT ACTIVE') {
            $normalModeCount ++
            Write-Log -Id $InfoEventID -Type Information -Message "[$line] line[$i] Normal Mode"
 
 
            } elseIF ($line -match 'ACTIVE') {
            $backUpModeCount ++
            Write-Log -Id $InfoEventID -Type Information -Message "[$line] line[$i] BackUp Mode"
            }
 
    $i ++
    }


    Write-Log -Id $InfoEventID -Type Information -Message "Oracle Database is running in...."

    IF (($backUpModeCount -eq 0) -and ($normalModeCount -gt 0)) {
 
        Write-Log -Id $InfoEventID -Type Information -Message "Normal Mode"
        $dbStatus.Normal = $TRUE
        $dbStatus.BackUp = $FALSE

    } elseIF (($backUpModeCount -gt 0) -and ($normalModeCount -eq 0)) {
   
        Write-Log -Id $InfoEventID -Type Information -Message "Back Up Mode"
        $dbStatus.Normal = $FALSE
        $dbStatus.BackUp = $TRUE

    } else {

        Write-Log -Id $InfoEventID -Type Information -Message "??? Mode ???"
        $dbStatus.Normal = $FALSE
        $dbStatus.BackUp = $FALSE
    }

    Write-Output $dbStatus
}
end {
}
}


function Test-UserName {

[OutputType([Boolean])]
[CmdletBinding()]

Param(
[parameter(position = 0,  mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][String][Alias("Name")]$CheckName,
[parameter(position = 1)][String]$ObjectName ,

[Switch]$IfInvalidFinalize
)
begin  {
}
process {
    Switch -Regex ($CheckUserName) {

        '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$' {
            Write-Log -Id $InfoEventID -Type Information -Message "$($ObjectName) [$($CheckUserName)] is valid user name."
            Write-Output $TRUE     
            }

        Default {
            Write-Log -Id $ErrorEventID -Type Error -Message "$($ObjectName) [$($CheckUserName)] is invalid user name."
            Write-Output $FALSE

            IF($IfInvalidFinalize){

                Finalize $ErrorReturnCode
                }
            }
    }
}
end {
}
}


function Test-DomainName {

[OutputType([Boolean])]
[CmdletBinding()]

Param(
[parameter(position = 0,  mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][String][Alias("Name")]$CheckDomainName,
[parameter(position = 1)][String]$ObjectName ,

[Switch]$IfInvalidFinalize
)
begin  {
}
process {
    Switch -Regex ($CheckDomainName) {

        '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$' {
            Write-Log -Id $InfoEventID -Type Information -Message "$($ObjectName) [$($CheckDomainName)] is valid domain name."
            Write-Output $TRUE     
            }

        Default {
            Write-Log -Id $ErrorEventID -Type Error -Message "$($ObjectName) [$($CheckDomainName)] is invalid domain name."
            Write-Output $FALSE

            IF($IfInvalidFinalize){

                Finalize $ErrorReturnCode
                }
            }
    }
}
end {
}
}


function Test-Hostname {

[OutputType([Boolean])]
[CmdletBinding()]

Param(
[parameter(position = 0,  mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][String][Alias("Name")]$CheckHostName,
[parameter(position = 1)][String]$ObjectName ,

[Switch]$IfInValidFinalize
)
begin  {
}
process {
    Switch -Regex ($CheckHostName) {

        '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$' {
            Write-Log -Id $InfoEventID -Type Information -Message "$($ObjectName) [$($CheckHostName)] is valid IP Address."
            Write-Output $TRUE     
            }

        '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$' {
            Write-Log -Id $InfoEventID -Type Information -Message "$($ObjectName) [$($CheckHostName)] is valid Hostname."
            Write-Output $TRUE                
            }

        Default {
            Write-Log -Id $ErrorEventID -Type Error -Message "$($ObjectName) [$($CheckHostName)] is invalid Hostname."
            Write-Output $FALSE

            IF($IfInvalidFinalize){

                Finalize $ErrorReturnCode
                }
            }
    }
}
end {
}
#ValidIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";

#ValidHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";

}
