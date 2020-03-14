#Requires -Version 5.0
#If you wolud NOT use '-PreAction compress or archive' in FileMaintenance.ps1 , you could change '-Version 5.0' to '-Version 3.0'

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

$Script:CommonFunctionsVersion = '20200221_2145'


#���O���̕ϐ����ꊇ�ݒ肵�����ꍇ�͈ȉ��𗘗p���ĉ������B
#
#�e�v���O������Param�ϐ��ݒ�A�R�}���h�̈����ACommonFunctions.ps1�̕ϐ��ݒ�
#��L�̏����ŁA��҂̐ݒ肪�D�悳��܂��B
#
#$LogPath���͂�����Őݒ肷������y����
#
#���͒l�͋ɗ�validation���Ă��܂����AParam�Z�N�V�����Ŗ����I�Ɏw�肷��ꍇ��validation����܂���
#������l���w�肵�Ȃ��悤�ɗ��ӂ��Ă�������


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
#[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default�w���Shift-Jis

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




#���O�o��

function Logging {

Param(
[parameter(mandatory=$TRUE)][ValidateRange(1,65535)][int]$EventID,
[parameter(mandatory=$TRUE)][String][ValidateSet("Information", "Warning", "Error" ,"Success")]$EventType,
[parameter(mandatory=$TRUE)][String]$EventMessage
)


    IF (($Log2EventLog -OR $ForceConsoleEventLog) -and -not($ForceConsole) ) {

        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType $EventType -EventId $EventID -Message "[$($ShellName)] $($EventMessage)"
        }


    IF ($Log2Console -or $ForceConsole -or $ForceConsoleEventLog) {

        $ConsoleWrite = $EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
        Write-Host $ConsoleWrite
        }   


    IF ($Log2File -and -not($ForceConsole -or $ForceConsoleEventLog )) {

        $logFormattedDate = (Get-Date).ToString($LogDateFormat)
        $logWrite = $LogFormattedDate+" "+$SHELLNAME+" "+$EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
        Write-Output $logWrite | Out-File -FilePath $LogPath -Append -Encoding $LogFileEncode
        }   

}


#ReturnCode�召�֌W�m�F
#$ErrorReturnCode = 0�ݒ蓙���l�����Ĉُ펞��Exit 1�Ŕ�����

function CheckReturnCode {

    IF (-not(($InternalErrorReturnCode -ge $WarningReturnCode) -and ($ErrorReturnCode -ge $WarningReturnCode) -and ($WarningReturnCode -ge $NormalReturnCode))) {

    Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID "The magnitude relation of ReturnCodes' parameters is not set correctly."
    Write-Output "The magnitude relation of ReturnCodes is not set correctly."
    Exit 1
    }
}



#�C�x���g�\�[�X���ݒ莞�̏���
#���̊m�F���I���܂ł̓��O�o�͉\���m�肵�Ȃ��̂ŃR���\�[���o�͂�����

function CheckEventLogSource {

    IF (-not($Log2EventLog)) {
        Return
        }


$ForceConsole = $TRUE

    Try {

        If (-not([System.Diagnostics.Eventlog]::SourceExists($ProviderName) ) ) {
        #�V�K�C�x���g�\�[�X��ݒ�
           
            New-EventLog -LogName $EventLogLogName -Source $ProviderName  -ErrorAction Stop
            $ForceConsoleEventLog = $TRUE    
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Regist new source event [$($ProviderName)] to [$($EventLogLogName)]"
            }
       
    }
    Catch [Exception] {
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "Failed to regist new source event because no source $($ProviderName) exists in event log, must have administrator privilage for registing new source. Start Powershell with administrator privilage and start the script."
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $Error[0]"
    Exit $ErrorReturnCode
    }

$ForceConsole = $FALSE
$ForceConsoleEventLog = $FALSE

}


#���O�t�@�C���o�͐�m�F
#���̊m�F���I���܂ł̓��O�o�͉\���m�肵�Ȃ��̂�EventLog�ƃR���\�[���o�͂�����

function CheckLogFilePath {

    IF (-not($Log2File)) {
        Return
        }

$ForceConsoleEventLog = $TRUE    

    $logPath = ConvertToAbsolutePath -CheckPath $LogPath -ObjectName '-LogPath'

    CheckLogPath -CheckPath $logPath -ObjectName '-LogPath' > $NULL
    
$ForceConsoleEventLog = $FALSE

}






function TryAction {
    
    Param(

    [parameter(mandatory=$TRUE)][String]
    [ValidatePattern("^(Move|Copy|Delete|AddTimeStamp|NullClear|Rename|MakeNew(FileWithValue|Folder)|(7z|7zZip|^)(Compress|Archive)(AndAddTimeStamp|$))$")]$ActionType,

    [parameter(mandatory=$TRUE)][String]$ActionFrom,
    [String]$ActionTo,
    [parameter(mandatory=$TRUE)][String]$ActionError,
    [String]$FileValue,
    [Switch]$NoContinueOverRide

    )

    IF (-not($ActionType -match "^(Delete|NullClear|MakeNewFolder|Rename)$" ) -and ($NULL -eq $ActionTo)) {

        Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error at Function TryAction  [$($ActionType)] requires [$($ActionTo)]"
        Finalize $InternalErrorReturnCode
        }


    IF ($NoAction) {
    
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "Specified -NoAction option, thus do not execute [$($ActionType)] to [ $($ActionError)]"
        $Script:NormalFlag = $TRUE

        IF ($OverRideFlag) {
            $Script:OverRideCount++
            $Script:InLoopOverRideCount++
            $Script:OverRideFlag = $FALSE            }

        Return
        }

      
    Try {
  

       Switch -Regex ($ActionType) {



        '^(Copy|AddTimeStamp)$'
            {
            Copy-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $NULL -ErrorAction Stop
            }

        '^(Move|Rename)$'
            {
            Move-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $NULL -ErrorAction Stop
            }

        '^Delete$'
            {
            Remove-Item -LiteralPath $ActionFrom -Force > $NULL -ErrorAction Stop
            }
                       
        '^NullClear$'
            {
            Clear-Content -LiteralPath $ActionFrom -Force > $NULL -ErrorAction Stop
            }

        '^(Compress|CompressAndAddTimeStamp)$'
            {

           $ActionTo = $ActionTo -replace "\[" , "````["

#            $ActionTo = "``"+$ActionTo

#          echo $ActionTo
#           exit
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Force > $NULL  -ErrorAction Stop
            }                  
                                       
        '^MakeNewFolder$'
            {
            New-Item -ItemType Directory -Path $ActionFrom > $NULL  -ErrorAction Stop
            }

        '^MakeNewFileWithValue$'
            {
            New-Item -ItemType File -Path $ActionFrom -Value $FileValue > $NULL -ErrorAction Stop
            }

        '^(Archive|ArchiveAndAddTimeStamp)$'
            {
            $ActionTo = $ActionTo -replace "\[" , "````["

#                        echo $ActionTo
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Update > $NULL  -ErrorAction Stop
            }                  


        '^((7z|7zZip)(Archive|Compress)($|AndAddTimeStamp))$'
            {

            Push-Location -LiteralPath $7zFolder

            IF($ActionType -match '7zZip'){
                
                $7zType = 'zip'
                
                }else{
                $7zType = '7z'
                }

            Switch -Regex ($ActionType){
            
                'Compress'{
                    [String]$errorDetail = .\7z a $ActionTo $ActionFrom -t"$7zType" 2>&1
                    Break
                    }

                'Archive'{
                    [String]$errorDetail = .\7z u $ActionTo $ActionFrom -t"$7zType" 2>&1
                    Break
                    }
            
                Default{
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
                                           
        Default                                 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Internal Error at Function TryAction. Switch ActionType exception has occurred. "
            Finalize $InternalErrorReturnCode
            }
      }       
   
   
   
    }   
    catch [Exception]{
       
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute [$($ActionType)] to [$($ActionError)]"
        IF (-not($processErrorFlag)) {
            $errorDetail = $Error[0] | Out-String
            }
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
        $Script:ErrorFlag = $TRUE

        If (($Continue) -and (-not($NoContinueOverRide))) {
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "Specified -Continue option, continue to process next objects."
            $Script:WarningFlag = $TRUE
            $Script:ContinueFlag = $TRUE
            Return
            }

        #Continue���Ȃ��ꍇ�͏I�������֐i��
        IF ($ForceEndLoop) {
            $Script:ErrorFlag = $TRUE
            $Script:ForceFinalize = $TRUE
            Break
            }else{
            Finalize $ErrorReturnCode
            }
   
    }

   IF ($ActionType -match '^(Copy|AddTimeStamp|Rename|(7z|7zZip|^)(Compress|Archive)(AndAddTimeStamp|$))$' ) {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ActionTo) was created."
        }


    IF ($OverRideFlag) {
        $Script:OverRideCount ++
        $Script:InLoopOverRideCount ++
        $Script:OverRideFlag = $FALSE
        }
           
    Logging -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to [$($ActionType)] to [$($ActionError)]"
    $Script:NormalFlag = $TRUE

}


Function ConvertToAbsolutePath {

<#
.SYNOPSIS
 ���΃p�X�����΃p�X�֕ϊ�

.DESCRIPTION
 ����function�͌����Ώۃp�X��Null , empty�̏ꍇ�A�ُ�I�����܂��B�m�F���K�v�ȃp�X�݂̂��������ĉ������B
 * ?����NTFS�Ɏg�p�ł��Ȃ��������p�X�Ɋ܂܂�Ă���ꍇ�ُ͈�I�����܂�
 []��Powershell�Ń��C���h�J�[�h�Ƃ��Ĉ����镶���́A���C���h�J�[�h�Ƃ��Ĉ����܂���BLiteralPath�Ƃ��Ă��̂܂܏������܂�
 �Ȃ�TryAction�̓��C���h�J�[�h[]�������܂���BLiteralPath�Ƃ��Ă��̂܂܏������܂�

.PARAMETER CheckPath
 ���΃p�X�܂��͐�΃p�X���w�肵�Ă��������B
 ���΃p�X��.\ �܂��� ..\����n�߂ĉ������B

.PARAMETER ObjectName
 ���O�ɏo�͂���CheckPath�̐��������w�肵�Ă��������B

 .INPUT
 System.String

 .OUTPUT
 System.String

#>


Param(
[String]$CheckPath,
[parameter(mandatory=$TRUE)][String]$ObjectName
)


    IF ([String]::IsNullOrEmpty($CheckPath)) {
           
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) is required."
        Finalize $ErrorReturnCode
        }

    #Windows�ł̓p�X��؂�/���g�p�ł���B�������Ȃ���A�������ȒP�ɂ��邽��\�ɓ��ꂷ��

    $CheckPath = $CheckPath.Replace('/','\')

    IF (Test-Path -LiteralPath $CheckPath -IsValid) {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)] is valid path format."
   
        }else{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)] is invalid path format. The path may contain a drive letter not existed or characters that can not use by NTFS."
        Finalize $ErrorReturnCode
        }



    Switch -Regex ($CheckPath) {

        "^\.+\\.*" {
       
            Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)] is relative path format."

            $convertedCheckPath = Join-Path -Path $DatumPath -ChildPath $CheckPath | ForEach-Object {[System.IO.Path]::GetFullPath($_)}
         
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Convert to absolute path format [$($convertedCheckPath)] with joining the folder path [$($DatumPath)] the script is placed and the path [$($CheckPath)]"

            $CheckPath = $convertedCheckPath
            }

        "^[c-zC-Z]:\\.*" {

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)] is absolute path format."
            }

        Default {
      
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)] is neither absolute path format nor relative path format."
            Finalize $ErrorReturnCode
            }
    }

    #�p�X������\\���A������Ə��������G�ɂȂ�̂ŁA�g�킹�Ȃ�

    IF ($CheckPath -match '\\\\') {
 
        Logging -EventID $InfoEventID -EventType Information -EventMessage "NTFS allows multiple path separators such as '\\' , due to processing limitation, convert multiple path separators to a single."

            For ( $i = 0 ; $i -lt $CheckPath.Length-1 ; $i++ )        
            {
            $CheckPath = $CheckPath.Replace('\\','\')
            }

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)] is created by converting multiple path separators to a single."
        }


    #�p�X���t�H���_�Ŗ�����\�����݂����ꍇ�͍폜����B������\�L���Ō��ʂ͈ꏏ�Ȃ̂����A���ꂵ�Ȃ��ƕ����񐔂��قȂ邽�߃p�X������؂�o�����듮�삷��B

    IF ($CheckPath.Substring($CheckPath.Length -1 , 1) -eq '\') {
    
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Windows path format allows the end of path with a path separator '\' , due to processing limitation, remove it."
            $CheckPath = $CheckPath.Substring(0 , $CheckPath.Length -1)
            }


    #TEST-Path -isvalid�̓R����:�̊܂܂�Ă���Path�𐳂������肵�Ȃ��̂Ōʂɔ���

    IF ((Split-Path $CheckPath -noQualifier) -match '(\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "$ObjectName may contain characters that can not use by NTFS  such as BackSlash/ Colon: Question? DoubleQuote`" less or greater than<> astarisk* pipe| "
                Finalize $ErrorReturnCode
                }


    #Windows�\��ꂪ�p�X�Ɋ܂܂�Ă��邩����

    IF($CheckPath -match '\\(AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])(\\|$|\..*$)'){

                Logging -EventType Error -EventID $ErrorEventID -EventMessage "$ObjectName may contain the Windows reserved words such as (AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])"
                Finalize $ErrorReturnCode
                }        

    Return $CheckPath

}





#�I��

function EndingProcess {

Param(
[parameter(mandatory=$TRUE)][int]$ReturnCode
)

    IF (($ErrorCount -gt 0) -OR ($ReturnCode -ge $ErrorReturnCode)) {

        IF ($ErrorAsWarning) {
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "An ERROR termination occurred, specified -ErrorAsWarning[$($ErrorAsWarning)] option, thus the exit code is [$($WarningReturnCode)]"  
            $returnCode = $WarningReturnCode
           
            }else{
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "An ERROR termination occurred, the exit code is [$($ErrorReturnCode)]"
            $returnCode = $ErrorReturnCode
            }

        }elseIF (($WarningCount -gt 0) -or ($ReturnCode -ge $WarningReturnCode)) {

            IF ($WarningAsNormal) {
                Logging -EventID $InfoEventID -EventType Information -EventMessage "A WARNING termination occurred, specified -WarningAsNormal[$($WarningAsNormal)] option, thus the exit code is [$($NormalReturnCode)]" 
                $returnCode = $NormalReturnCode
           
                }else{
                Logging -EventID $WarningEventID -EventType Warning -EventMessage "A WARNING termination occurred, the exit code is [$($WarningReturnCode)]"
                $returnCode = $WarningReturnCode
                }
        
        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Completed successfully. The exit code is [$($NormalReturnCode)]"
        $returnCode = $NormalReturnCode
               
        }

    Logging -EventID $EndEventID -EventType Information -EventMessage "Exit $($ShellName) Version $($Version)"

Exit $returnCode

}


function CheckServiceExist {

<#
.SYNOPSIS
 Check existence of specified Windows Service

.PARAMETER ServiceName
 �m�F����Windows Service���w�肵�Ă��������B

.PARAMETER NoMessage
 ���O�o�͂�}�~���܂��B

 .INPUT
 System.String

 .OUTPUT
 Boolean

#>


Param(
[parameter(mandatory=$TRUE)][String]$ServiceName,
[Switch]$NoMessage
)


# �T�[�r�X��Ԏ擾

    $service = Get-Service | Where-Object {$_.Name -eq $serviceName}


    IF ($service.Status -Match "^$") {
        IF (-not($NoMessage)) {Logging -EventID $InfoEventID -EventType Information -EventMessage "Service [$($ServiceName)] dose not exist."}
        Return $FALSE

        }else{

        IF (-not($NoMessage)) {Logging -EventID $InfoEventID -EventType Information -EventMessage "Service [$($ServiceName)] exists"}
        Return $TRUE
        }
}


#�T�[�r�X��Ԋm�F
#����$Health�ŏ��(Running|Stopped)���w�肵�Ă��������B�߂�l�͎w���Ԃ�$TRUE�܂��͔�w����$FALSE
#�T�[�r�X�N���A��~���Ă���Ԑ��ڂɂ͎��Ԃ��|����܂��B����function�͈�莞��$Span�A����$UpTo�A��Ԋm�F���J��Ԃ��܂�
#�N�����x���T�[�r�X��$Span��傫�����Ă�������

function CheckServiceStatus {

Param(
[parameter(mandatory=$TRUE)][String]$ServiceName,
[String][ValidateSet("Running", "Stopped")]$Health = 'Running',
[int][ValidateRange(0,2147483647)]$Span = 3,
[int][ValidateRange(0,2147483647)]$UpTo = 10
)

    For ( $i = 0 ; $i -lt $UpTo; $i++ )
    {
        # �T�[�r�X���݊m�F
        IF (-not(CheckServiceExist $ServiceName -NoMessage)) {
            Return $FALSE
            }


        # �T�[�r�X��Ԕ���
        $service = Get-Service | Where-Object {$_.Name -eq $ServiceName}

        IF ($service.Status -eq $Health) {
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Service [$($ServiceName)] exists and status is [$($service.Status)]"
            Return $TRUE     
            }

        IF (($Span -eq 0) -and ($UpTo -eq 1)) {
                
                Logging -EventID $InfoEventID -EventType Information -EventMessage "Service [$($ServiceName)] exists and status is [$($service.Status)]"
                Return $FALSE
                }

        # �w��Ԋu(�b)�ҋ@

        Logging -EventID $InfoEventID -EventType Information -EventMessage "Service [$($ServiceName)] exists and status is [$($Service.Status)] , is not [$($Health)] Wait for $($Span)seconds."
        Start-sleep $Span
    }

    # �T�[�r�X�͎w���Ԃ֑J�ڂ��Ȃ�����

Logging -EventID $InfoEventID -EventType Information -EventMessage "Service [$($ServiceName)] exists and status is [$($Service.Status)] now. The specified number of seconds has elapsed but the service has not transitioned to status [$($Health)]"
Return $FALSE

}


function CheckNullOrEmpty {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNullOrEmptyFinalize,
[Switch]$NoMessage

)


    If (-not([String]::IsNullOrEmpty($CheckPath))) {
        Return $FALSE
        }else{

        IF ($IfNullOrEmptyFinalize) {
           
               Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) is required."
               Finalize $ErrorReturnCode
               }
               
        }

    Return $TRUE
       
}


function CheckContainer {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNoExistFinalize

)

    If (Test-Path -LiteralPath $CheckPath -PathType Container) {

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)] exists."
            Return $TRUE

            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)] dose not exist."
                IF($IfNoExistFinalize){
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) is required."
                    Finalize $ErrorReturnCode
                    }else{
                    Return $FALSE
                    }
    }

}


function CheckLeaf {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNoExistFinalize

)

    If (Test-Path -LiteralPath $CheckPath -PathType Leaf) {

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)] exists."
            Return $TRUE

            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)] dose not exist."
                IF($IfNoExistFinalize){
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) is required."
                    Finalize $ErrorReturnCode
                    }else{
                    Return $FALSE
                    }
    }
}


function CheckLogPath {

Param(

[String]$CheckPath,
[String]$ObjectName ,
[String]$FileValue = $NULL

)
    #���O�o�͐�t�@�C���̐e�t�H���_�����݂��Ȃ���Έُ�I��

    Split-Path -Path $CheckPath | ForEach-Object {CheckContainer -CheckPath $_ -ObjectName $ObjectName -IfNoExistFinalize > $NULL}

    #���O�o�͐�i�\��j�t�@�C���Ɠ��ꖼ�̂̃t�H���_�����݂��Ă���Έُ�I��

    If (Test-Path -LiteralPath $CheckPath -PathType Container) {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Same name folder $($CheckLeaf) exists already."        
        Finalize $ErrorReturnCode
        }


    If (Test-Path -LiteralPath $CheckPath -PathType Leaf) {

        Logging -EventID $InfoEventID -EventType Information -EventMessage "Check write permission of $($ObjectName) [$($CheckPath)]"
        $logFormattedDate = (Get-Date).ToString($LogDateFormat)
        $logWrite = $logFormattedDate+" "+$ShellName+" Write Permission Check"
        

        Try {
            Write-Output $logWrite | Out-File -FilePath $CheckPath -Append -Encoding $LogFileEncode
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Successfully complete to write to $($ObjectName) [$($CheckPath)]"
            }
        Catch [Exception]{
            Logging -EventType Error -EventID $ErrorEventID -EventMessage  "Failed to write to $($ObjectName) [$($CheckPath)]"
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "Execution error message : $Error[0]"
            Finalize $ErrorReturnCode
            }
     
     }else{
            TryAction -ActionType MakeNewFileWithValue -ActionFrom $CheckPath -ActionError $CheckPath -FileValue $FileValue
            }

}


function CheckExecUser {

    $Script:ScriptExecUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    Logging -EventID $InfoEventID -EventType Information -EventMessage "Executed in user [$($ScriptExecUser.Name)]"

    IF (-not($ScriptExecUser.Name -match $ExecutableUser)) {
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "Executed in an unauthorized user."
                Finalize $ErrorReturnCode
                }

}



function PreInitialize {

$ERROR.clear()
$ForceConsole = $FALSE
$ForceConsoleEventLog = $FALSE

#ReturnCode�m�F

. CheckReturnCode


#�C�x���g�\�[�X���ݒ莞�̏���

. CheckEventLogSource


#���O�t�@�C���o�͐�m�F

. CheckLogFilePath



#������function�Ȃ̂ŕϐ���function���ł̂��̂ƂȂ�B�X�N���v�g�S�̂ɔ��f����ɂ̓X�R�[�v�𖾎��I��$Script:�ϐ����Ƃ���

#���O�}�~�t���O����

IF ($NoLog2EventLog) {[boolean]$Script:Log2EventLog = $FALSE}
IF ($NoLog2Console)  {[boolean]$Script:Log2Console  = $FALSE}
IF ($NoLog2File)     {[boolean]$Script:Log2File     = $FALSE}


Logging -EventID $StartEventID -EventType Information -EventMessage "Start $($ShellName) Version $($Version)"

Logging -EventID $InfoEventID -EventType Information -EventMessage "Loaded CommonFunctions.ps1 Version $($CommonFunctionsVersion)"

Logging -EventID $InfoEventID -EventType Information -EventMessage "Start to validate parameters."

. CheckExecUser


}


function ExecSQL {

Param(
[String]$SQLLogPath,
[parameter(mandatory=$TRUE)][String]$SQLName,
[parameter(mandatory=$TRUE)][String]$SQLCommand,

[Switch]$IfErrorFinalize

)

    $scriptExecUser = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name

    $logFormattedDate = (Get-Date).ToString($LogDateFormat)

    $sqlLog = $NULL



#Powershell�ł̓q�A�h�L�������g�̉��s��LF�Ƃ��ď��������
#�������Ȃ���A����Oracle����̏o�͂�LF&CR�̂��߁AWindows�������ŊJ���Ɖ��s�R�[�h�����݂��Đ�������������Ȃ�
#����āA�����I��CR��ǉ�����SQLLog�ŉ��s�R�[�h�����݂��Ȃ��悤�ɂ���
#Sakura Editor���ł͉��s�R�[�h���݂����������������

$logWrite = @"
`r
`r
----------------------------`r
DATE: $logFormattedDate`r
SHELL: $ShellName`r
SQL: $SQLName`r
`r
OS User: $ScriptExecUser`r
`r
SQL Exec User: $ExecUser`r
Password Authrization [$PasswordAuthorization]`r
`r
"@


Write-Output $logWrite | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode

Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization) {

    $sqlLog = $SQLCommand | SQLPlus $ExecUser/$ExecUserPassword@OracleSerivce as sysdba

    }else{
    $sqlLog = $SQLCommand | SQLPlus / as sysdba
    }

Write-Output $sqlLog | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode


Pop-Location


    IF ($LASTEXITCODE -eq 0) {

        Logging -EventID $SuccessEventID -EventType Success -EventMessage "Successfully completed to execute SQL Command[$($SQLName)]"
        Return $TRUE

        }else{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute SQL Command[$($SQLName)]"
   
            IF ($IfErrorFinalize) {
            Finalize $ErrorReturnCode
            }
   
        Return $FALSE
    }



}




function CheckOracleBackUpMode {


    Logging -EventID $InfoEventID -EventType Information -EventMessage "Get the backup status of Oracle Database ,determine Oracle Database is running in which mode BackUp/Normal. A line [Active] is in BackUp Mode."
  . ExecSQL -SQLCommand $DBCheckBackUpMode -SQLName "DBCheckBackUpMode" -SQLLogPath $SQLLogPath > $NULL

   
    #������z��ɕϊ�����
    $SQLLog = $SQLLog -replace "`r","" |  ForEach-Object {$_ -split "`n"}

    $normalModeCount = 0
    $backUpModeCount = 0


    $i = 1

    foreach ($line in $SQLLog) {

            IF ($Line -match 'NOT ACTIVE') {
            $normalModeCount ++
            Logging -EventID $InfoEventID -EventType Information -EventMessage "[$line] line[$i] Normal Mode"
 
 
            }elseIF ($Line -match 'ACTIVE') {
            $backUpModeCount ++
            Logging -EventID $InfoEventID -EventType Information -EventMessage "[$line] line[$i] BackUp Mode"
            }
 
    $i ++
    }


    Logging -EventID $InfoEventID -EventType Information -EventMessage "Oracle Database is running in...."

    IF (($backUpModeCount -eq 0) -and ($normalModeCount -gt 0)) {
 
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Normal Mode"
        $Script:NormalModeFlag = $TRUE
        $Script:BackUpModeFlag = $FALSE
        Return

    }elseif (($backUpModeCount -gt 0) -and ($normalModeCount -eq 0)) {
   
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Back Up Mode"
        $Script:NormalModeFlag = $FALSE
        $Script:BackUpModeFlag = $TRUE
        Return


    }else{

        Logging -EventID $InfoEventID -EventType Information -EventMessage "??? Mode ???"
        $Script:NormalModeFlag = $FALSE
        $Script:BackUpModeFlag = $FALSE
        Return
    }


}


function AddTimeStampToFileName {

    Param
    (
    [String]$TimeStampFormat,
    [String]$TargetFileName
    )


    $formattedDate = (Get-Date).ToString($TimeStampFormat)
    $extensionString = [System.IO.Path]::GetExtension($TargetFileName)
    $fileNameWithOutExtentionString = [System.IO.Path]::GetFileNameWithoutExtension($TargetFileName)

    Return $fileNameWithOutExtentionString+$formattedDate+$extensionString

}


function CheckUserName {

Param(
[parameter(mandatory=$TRUE)][String]$CheckUserName,
[String]$ObjectName 
)

    Switch -Regex ($CheckUserName) {

    '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckUserName)] is valid user name."
        Return $TRUE     
        }

    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckUserName)] is invalid user name."
        Finalize $ErroReturnCode
        }

    }

}

function CheckDomainName {

Param(
[parameter(mandatory=$TRUE)][String]$CheckDomainName,
[String]$ObjectName 
)

    Switch -Regex ($CheckDomainName) {

    '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckDomainName)] is valid domain name."
        Return $TRUE     
        }

    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckDomainName)] is invalid domain name."
        Finalize $ErroReturnCode
        }

    }

}


function CheckHostname {

Param(
[parameter(mandatory=$TRUE)][String]$CheckHostName,
[String]$ObjectName 
)

    Switch -Regex ($CheckHostName) {

    '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckHostName)] is valid IP Address."
        Return $TRUE     
        }
    '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckHostName)] is valid Hostname."
        Return $TRUE                
        }
    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckHostName)] is invalid Hostname."
        Finalize $ErroReturnCode
        }

    }

#ValidIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";

#ValidHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";

}
