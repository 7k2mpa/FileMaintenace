#Requires -Version 3.0

<#
.SYNOPSIS

This script checkes existence(or non-existence)  of a flag file, and create(or delete) the flag file.
CommonFunctions.ps1 is required.



.DESCRIPTION

This script checkes existence(or non-existence)  of a flag file, and create(or delete) the flag file.
If status of existence(or non-existence) is true, exit with normal return code.
If status of existence(or non-existence) is false, exit with warning return code.

If specify -PostAction option, the script create(or delete) the flag file.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


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


.EXAMPLE

.\CheckFlag -FlagFolder ..\Lock -FlagFile BackUp.Flg -Status Exist -PostAction Delete

Check BackUp.Flg file in the ..\Lock folder.
If the file dose not exist, the script exit with warning return code.
If the file exists, the script delete the flag file.

If success to delete, the script exit with normal return code.
If fail to delte, the script exit with error return code.



.PARAMETER FlagFolder

Specify the folder to check existence of flag file.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.


.PARAMETER FlagFile

Specify name of the flag file.


.PARAMETER Status

Specify [Exist]ence or [NoExist]ence of the flag file.
[NoExist] is by default.


.PARAMETER PostAction

Specify action to [Delete] or [Create] a flag file after checking.



.PARAMETER Log2EventLog

Specify if you want to output log to Windows Event Log.
[$TRUE] is default.


.PARAMETER NoLog2EventLog

Specify if you want to suppress log to Windows Event Log.
Specification overrides -Log2EventLog


.PARAMETER ProviderName

Specify provider name of Windows Event Log.
[Infra] is default.


.PARAMETER EventLogLogName

Specify log name of Windows Event Log.
[Application] is default.


.PARAMETER Log2Console

Specify if you want to output log to PowerShell console.
[$TRUE] is default.


.PARAMETER NoLog2Console

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2Console


.PARAMETER Log2File

Specify if you want to output log to text log.
[$FALSE] is default.


.PARAMETER NoLog2File

Specify if you want to suppress log to PowerShell console.
Specification overrides -Log2File


.PARAMETER LogPath

Specify the path of text log file.
Can specify relative, absolute or UNC path format.
Relative path format must be starting with 'dot.'
Wild cards are not accepted shch as asterisk* question? bracket[]
If the path contains bracket[] , specify path literally and do not escape.
[$NULL] is default.

If the log file dose not exist, the script makes a new file.
If the log file exists, the script writes log additionally.


.PARAMETER LogDateFormat

Specicy time stamp format in the text log.
[yyyy-MM-dd-HH:mm:ss] is default.


.PARAMETER LogFileEncode

Specify the character encode in the log file.
[Default] is default and it works as ShiftJIS.


.PARAMETER NormalReturnCode

Specify Normal Return code.
[0] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER WarningReturnCode

Specify Warning Return code.
[1] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER ErrorReturnCode

Specify Error Return code.
[8] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER InternalErrorReturnCode

Specify Internal Error Return code.
[16] is default.
Must specify NormalReturnCode < WarningReturnCode < ErrorReturnCode < InternalErrorReturnCode


.PARAMETER InfoEventID

Specify information event id in the log.
[1] is default.


.PARAMETER InfoLoopStartEventID

Specify start loop event id in the log.
[2] is default.


.PARAMETER InfoLoopEndEventID

Specify end loop event id in the log.
[3] is default.


.PARAMETER StartEventID

Specify start script id in the log.
[8] is default.


.PARAMETER EndEventID

Specify end script event id in the log.
[9] is default.


.PARAMETER WarningEventID

Specify Warning event id in the log.
[10] is default.


.PARAMETER SuccessEventID

Specify Successfully complete event id in the log.
[73] is default.


.PARAMETER InternalErrorEventID

Specify Internal Error event id in the log.
[99] is default.


.PARAMETER ErrorEventID

Specify Error event id in the log.
[100] is default.


.PARAMETER ErrorAsWarning

Specfy if you want to return WARNING exit code when the script terminate with an Error.


.PARAMETER WarningAsNormal

Specify if you want to return NORMAL exit code when the script terminate with a Warning.


.PARAMETER ExecutableUser

Specify the users who are allowed to execute the script in regular expression.
[.*] is default and all users are allowed to execute.
Parameter must be quoted with single quote'
Escape the back slash in the separeter of a domain name.
example [domain\\.*]



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



.OUTPUTS

System.Int. Return Code.

#>

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
Param(

[String][parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Specify the folder of a flag file placed.(ex. D:\lock)or Get-Help CheckFlag.ps1')]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("Path","LiteralPath","FullName")]$FlagFolder ,

[String][parameter(position = 1, mandatory)][ValidateNotNullOrEmpty()][ValidatePattern ('^(?!.*(\/|:|\?|`"|<|>|\||\*|\\).*$)')][Alias("FlagFileName")]$FlagFile ,
[String][parameter(position = 2)][ValidateSet("Exist","NoExist")]$Status = 'NoExist' ,
[String][parameter(position = 3)][ValidateSet("Create","Delete")]$PostAction ,

#Planned to obsolute
[Switch]$CreateFlag ,
#Planned to obsolute


[Boolean]$Log2EventLog = $TRUE ,
[Switch]$NoLog2EventLog ,
[String][ValidateNotNullOrEmpty()]$ProviderName = 'Infra' ,
[String][ValidateSet("Application")]$EventLogLogName = 'Application' ,

[Boolean]$Log2Console = $TRUE ,
[Switch]$NoLog2Console ,

[Boolean]$Log2File = $FALSE ,
[Switch]$NoLog2File ,

[String][ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$LogPath ,

[String][ValidateNotNullOrEmpty()]$LogDateFormat = 'yyyy-MM-dd-HH:mm:ss' ,
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default' , #Default ShiftJIS


[Int][ValidateRange(0,2147483647)]$NormalReturnCode        =  0 ,
[Int][ValidateRange(0,2147483647)]$WarningReturnCode       =  1 ,
[Int][ValidateRange(0,2147483647)]$ErrorReturnCode         =  8 ,
[Int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16 ,

[Int][ValidateRange(1,65535)]$InfoEventID          =   1 ,
[Int][ValidateRange(1,65535)]$InfoLoopStartEventID =   2 ,
[Int][ValidateRange(1,65535)]$InfoLoopEndEventID   =   3 ,
[int][ValidateRange(1,65535)]$StartEventID         =   8 ,
[int][ValidateRange(1,65535)]$EndEventID           =   9 ,
[Int][ValidateRange(1,65535)]$WarningEventID       =  10 ,
[Int][ValidateRange(1,65535)]$SuccessEventID       =  73 ,
[Int][ValidateRange(1,65535)]$InternalErrorEventID =  99 ,
[Int][ValidateRange(1,65535)]$ErrorEventID         = 100 ,

[Switch]$ErrorAsWarning ,
[Switch]$WarningAsNormal ,

[Regex]$ExecutableUser = '.*'

)

################# CommonFunctions.ps1 Load  #######################

Try{

    #CommonFunctions.ps1の配置先を変更した場合は、ここを変更。同一フォルダに配置前提
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "Fail to load CommonFunctions.ps1 Please verify existence of CommonFunctions.ps1 in the same folder."
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

$Version = "2.0.0-RC.9"


#初期設定、パラメータ確認、起動メッセージ出力

. Initialize

[String]$flagValue = $ShellName + " " + (Get-Date).ToString($LogDateFormat)
[String]$flagPath = $FlagFolder | Join-Path -ChildPath $FlagFile


Switch -Regex ($Status) {

    '^NoExist$' {

        IF (-not($flagPath | Test-Leaf -Name 'Flag file') -and -not($flagPath | Test-Container -Name 'Same name folder')) {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Flag file [$($flagPath)] dose not exist and terminates as NORMAL." 

            } else {
            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Flag file [$($flagPath)] exists already and terminates as WARNING."
            Finalize $WarningReturnCode    
            }
        }

    '^Exist$' {
    
        IF ($flagPath | Test-Leaf -Name 'Flag file') {

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Flag file [$($flagPath)] exists and terminates as NORMAL."    

            } else {
            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Flag file [$($flagPath)] is deleted already and terminates as WARNING."
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

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Specified -PostAction [$($PostAction)] option, thus $PostAction a flag file."        
            Invoke-Action -ActionType MakeNewFileWithValue -ActionFrom $flagPath -ActionError $flagPath -FileValue $flagValue
            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to create the flag file [$($flagPath)]"
            }


    'Delete' {
 
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Specified -PostAction [$($PostAction)] option, thus $PostAction a flag file."             
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
