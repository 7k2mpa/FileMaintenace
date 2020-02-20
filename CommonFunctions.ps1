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

$Script:CommonFunctionsVersion = '20200130_1050'

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
#[boolean]$Log2File = $False,
#[Switch]$NoLog2File,
#[String][ValidatePattern('^(\.+\\|[C-Z]:\\).*')]$LogPath ,
#[String]$LogDateFormat = "yyyy-MM-dd-HH:mm:ss",
#[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default�w���Shift-Jis

#[int][ValidateRange(0,2147483647)]$NormalReturnCode = 0,
#[int][ValidateRange(0,2147483647)]$WarningReturnCode = 1,
#[int][ValidateRange(0,2147483647)]$ErrorReturnCode = 8,
#[int][ValidateRange(0,2147483647)]$InternalErrorReturnCode = 16,

#[int][ValidateRange(1,65535)]$InfoEventID = 1,
#[int][ValidateRange(1,65535)]$WarningEventID = 10,
#[int][ValidateRange(1,65535)]$SuccessEventID = 73,
#[int][ValidateRange(1,65535)]$InternalErrorEventID = 99,
#[int][ValidateRange(1,65535)]$ErrorEventID = 100,

#[Switch]$ErrorAsWarning,
#[Switch]$WarningAsNormal,

#[Regex]$ExecutableUser ='.*'




#���O�o��

function Logging{

Param(
[parameter(mandatory=$true)][ValidateRange(1,65535)][int]$EventID,
[parameter(mandatory=$true)][String][ValidateSet("Information", "Warning", "Error" ,"Success")]$EventType,
[parameter(mandatory=$true)][String]$EventMessage
)


    IF(($Log2EventLog -OR $ForceConsoleEventLog) -and -NOT($ForceConsole) ){

        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType $EventType -EventId $EventID -Message "[$($SHELLNAME)] $($EventMessage)"
        }


    IF($Log2Console -or $ForceConsole -or $ForceConsoleEventLog){

        $ConsoleWrite = $EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
        Write-Host $ConsoleWrite
        }   


    IF($Log2File -and -NOT($ForceConsole -or $ForceConsoleEventLog )){

        $LogFormattedDate = (Get-Date).ToString($LogDateFormat)
        $LogWrite = $LogFormattedDate+" "+$SHELLNAME+" "+$EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
        Write-Output $LogWrite | Out-File -FilePath $LogPath -Append -Encoding $LogFileEncode
        }   

}


#ReturnCode�召�֌W�m�F
#$ErrorReturnCode = 0�ݒ蓙���l�����Ĉُ펞��Exit 1�Ŕ�����

function CheckReturnCode {

    IF(-NOT(($InternalErrorReturnCode -ge $WarningReturnCode) -AND ($ErrorReturnCode -ge $WarningReturnCode) -AND ($WarningReturnCode -ge $NormalReturnCode))){

    Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID "ReturnCode�̑召�֌W���������ݒ肳��Ă��܂���B"
    Write-Output "ReturnCode�̑召�֌W���������ݒ肳��Ă��܂���B"
    Exit 1
    }
}



#�C�x���g�\�[�X���ݒ莞�̏���
#���̊m�F���I���܂ł̓��O�o�͉\���m�肵�Ȃ��̂ŃR���\�[���o�͂�����

function CheckEventLogSource{

    IF (-NOT($Log2EventLog)){
        Return
        }


$ForceConsole = $TRUE

    TRY{

        If (-NOT([System.Diagnostics.Eventlog]::SourceExists($ProviderName) ) ){
        #�V�K�C�x���g�\�[�X��ݒ�
           
            New-EventLog -LogName $EventLogLogName -Source $ProviderName  -ErrorAction Stop
            $ForceConsoleEventLog = $TRUE    
            Logging -EventID $InfoEventID -EventType Information -EventMessage "�V�K�C�x���g�\�[�X[$($ProviderName)]��[$($EventLogLogName)]�֓o�^���܂���"
            }
       
    }
    Catch [Exception]{
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "EventLog��Souce $($ProviderName)�����݂��Ȃ����߁A�V�K�쐬�����݂܂��������s���܂����B�V�KSource�̍쐬�͎��s���[�U���Ǘ��Ҍ�����ۗL���Ă���K�v������܂��B��xPowershell���Ǘ��Ҍ����ŊJ���Ď蓮�ł��̃v���O���������s���Ă��������B"
    Logging -EventID $ErrorEventID -EventType Error -EventMessage "�N�����G���[���b�Z�[�W : $Error[0]"
    Exit $ErrorReturnCode
    }

$ForceConsole = $false
$ForceConsoleEventLog = $false

}


#���O�t�@�C���o�͐�m�F
#���̊m�F���I���܂ł̓��O�o�͉\���m�肵�Ȃ��̂�EventLog�ƃR���\�[���o�͂�����

function CheckLogFilePath{

    IF (-NOT($Log2File)){
        Return
        }

$ForceConsleEventLog = $TRUE    

    $LogPath = ConvertToAbsolutePath -CheckPath $LogPath -ObjectName '-LogPath'

    CheckLogPath -CheckPath $LogPath -ObjectName '-LogPath' > $NULL
    
$ForceConsoleEventLog = $false

}






function TryAction {
    
    Param(

#    [parameter(mandatory=$true)][String]
#    [ValidateSet("Move", "Copy", "Delete" , "AddTimeStamp" , "NullClear" ,"Compress" , "CompressAndAddTimeStamp" `
#     , "MakeNewFolder" ,"MakeNewFileWithValue" , "Rename" , "Archive" , "ArchiveAndAddTimeStamp" `
#     , "7zCompress" , "7zZipCompress" , "7zArchive" , "7zZipArchive")]$ActionType,

    [parameter(mandatory=$true)][String]
    [ValidatePattern("^(Move|Copy|Delete|AddTimeStamp|NullClear|Rename|MakeNew(FileWithValue|Folder)|(7z|7zZip|^)(Compress|Archive)(AndAddTimeStamp|$))$")]$ActionType,

#    [ValidatePattern("^(Move|Copy|Delete|AddTimeStamp|NullClear|Rename|(MakeNew(FileWithValue|Folder))|((7z|7zZip|$)(Compress|Archive)(AndAddTimeStamp|$))$")]$ActionType,

    [parameter(mandatory=$true)][String]$ActionFrom,
    [String]$ActionTo,
    [parameter(mandatory=$true)][String]$ActionError,
    [String]$FileValue,
    [Switch]$NoContinueOverRide

    )

    IF (-NOT($ActionType -match "^(Delete|NullClear|MakeNewFolder|Rename)$" ) -and ($Null -eq $ActionTo)){

        Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Function TryAction�����G���[�B${ActionType}�ł�$'$ActionTo'�̎w�肪�K�v�ł�"
        Finalize $InternalErrorReturnCode
        }


    IF($NoAction){
    
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "-NoAction���w�肳��Ă��邽�߁A${ActionError}��[${ActionType}]�͎��s���܂���ł���"
        $Script:NormalFlag = $TRUE

        IF($OverRideFlag){
            $Script:OverRideCount ++
            $Script:InLoopOverRideCount ++
            $Script:OverRideFlag = $False
            }

        Return
        }

      
    Try{
  

       Switch -Regex ($ActionType){



        '^(Copy|AddTimeStamp)$'
            {
            Copy-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $Null -ErrorAction Stop
            }

        '^(Move|Rename)$'
            {
            Move-Item -LiteralPath $ActionFrom -Destination $ActionTo -Force > $Null -ErrorAction Stop
            }

        '^Delete$'
            {
            Remove-Item -LiteralPath $ActionFrom -Force > $Null -ErrorAction Stop
            }
                       
        '^NullClear$'
            {
            Clear-Content -LiteralPath $ActionFrom -Force > $Null -ErrorAction Stop
            }

        '^(Compress|CompressAndAddTimeStamp)$'
            {

           $ActionTo = $ActionTo -replace "\[" , "````["

#            $ActionTo = "``"+$ActionTo

#          echo $ActionTo
#           exit
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Force > $Null  -ErrorAction Stop
            }                  
                                       
        '^MakeNewFolder$'
            {
            New-Item -ItemType Directory -Path $ActionFrom > $Null  -ErrorAction Stop
            }

        '^MakeNewFileWithValue$'
            {
            New-Item -ItemType File -Path $ActionFrom -Value $FileValue > $Null -ErrorAction Stop
            }

        '^(Archive|ArchiveAndAddTimeStamp)$'
            {
            $ActionTo = $ActionTo -replace "\[" , "````["

#                        echo $ActionTo
            Compress-Archive -LiteralPath $ActionFrom -DestinationPath $ActionTo -Update > $Null  -ErrorAction Stop
            }                  


        '^((7z|7zZip)(Archive|Compress))$'
            {

            Push-Location -LiteralPath $7zFolderPath

            IF($ActionType -match '7zZip'){
                
                $7zType = 'zip'
                
                }else{
                $7zType = '7z'
                }

            Switch -Regex ($ActionType){
            
                'Compress'{
                    [String]$ErrorDetail = .\7z a $ActionTo $ActionFrom -t"$7zType" 2>&1 
                    }

                'Archive'{
                    [String]$ErrorDetail = .\7z u $ActionTo $ActionFrom -t"$7zType" 2>&1  
                    }
            
                Default{
                    Pop-Location
                    Throw "internal error in 7Zip Section"
                    }            
                }

#            IF($ActionType -match 'Compress'){

#                [String]$ErrorDetail = .\7z a $ActionTo $ActionFrom -t"$7zType" 2>&1 
#                }elseIF($ActionType -match 'Archive'){
            
#            [String]$ErrorDetail = .\7z u $ActionTo $ActionFrom -t"$7zType" 2>&1             
#            }else{Throw "internal error in 7ZipSection"}


            Pop-Location
            $ProcessError = $TRUE
            IF($LASTEXITCODE -ne 0){

                Throw "error in 7zip"            
                }
            }

#        '^(7zCompress|7zZipCompress)$'
#            {
            
#            echo '7zip'

#            Push-Location -LiteralPath $7zFolderPath
 #           .\7z a $ActionTo $ActionFrom | Tee-Object -Variable ProcessError

#            IF($ActionType -match '7zZip'){$7zType = 'zip'}else{$7zType = '7z'}

#             echo $7zType
#             [String]$ErrorDetail = .\7z a $ActionTo $ActionFrom -t"$7zType" 2>&1 
#            echo $ErrorDetail
#            $ErrorDetail = .\7z a $ActionToo $ActionFromm | ForEach-Object {Write-Output $_}
#            $ErrorDetail = .\7z a $ActionToo $ActionFromm

#            Pop-Location
#            $ProcessError = $TRUE
#            IF($LASTEXITCODE -ne 0){
#            Throw "error in 7zip"
            
#            }


 #           }
                                           
        Default                                 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Function TryAction�����G���[�B���莮��bug������܂�"
            Finalize $InternalErrorReturnCode
            }
      }       
   
   
   
    }   
    catch [Exception]{
       
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "${ActionError}��[${ActionType}]�Ɏ��s���܂���"
        IF(-NOT($ProcessError)){
            $ErrorDetail = $Error[0] | Out-String
            }
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "�N�����G���[���b�Z�[�W : $ErrorDetail"
        $Script:ErrorFlag = $TRUE

        If(($Continue) -AND (-NOT($NoContinueOverRide))){
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]�̂��ߏ������p�����܂��B"
            $Script:WarningFlag = $TRUE
            $Script:ContinueFlag = $TRUE
            Return
            }

        #Continue���Ȃ��ꍇ�͏I�������֐i��
        IF($ForceEndLoop){
            $Script:ErrorFlag = $TRUE
            $Script:ForceFinalize = $TRUE
            Break
            }else{
            Finalize $ErrorReturnCode
            }
   
    }


   IF($ActionType -match '^(Compress|CompressAndAddTimeStamp|AddTimeStamp|Copy|Move|Rename|Archive|ArchiveAndAddTimeStamp)$' ){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ActionTo)���쐬���܂���"
        }


    IF($OverRideFlag){
        $Script:OverRideCount ++
        $Script:InLoopOverRideCount ++
        $Script:OverRideFlag = $False
        }
           
    Logging -EventID $SuccessEventID -EventType Success -EventMessage "${ActionError}��[${ActionType}]�ɐ������܂���"
    $Script:NormalFlag = $TRUE

}




#���΃p�X�����΃p�X�֕ϊ�
#���΃p�X��.\ �܂��� ..\����n�߂ĉ������B
#����function�͌����Ώۃp�X��Null , empty�̏ꍇ�A�ُ�I�����܂��B�m�F���K�v�ȃp�X�݂̂��������ĉ������B
#* ?����NTFS�Ɏg�p�ł��Ȃ��������p�X�Ɋ܂܂�Ă���ꍇ�ُ͈�I�����܂�
#[]��Powershell�Ń��C���h�J�[�h�Ƃ��Ĉ����镶���́A���C���h�J�[�h�Ƃ��Ĉ����܂���BLiteralPath�Ƃ��Ă��̂܂܏������܂�
#�Ȃ�TryAction�̓��C���h�J�[�h[]�������܂���BLiteralPath�Ƃ��Ă��̂܂܏������܂�

Function ConvertToAbsolutePath {

Param(
[String]$CheckPath,
[parameter(mandatory=$true)][String]$ObjectName

)



    IF ([String]::IsNullOrEmpty($CheckPath)){
           
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) �̎w��͕K�{�ł�"
                    Finalize $ErrorReturnCode
                    }

    #Windows�ł̓p�X��؂�/���g�p�ł���B�������Ȃ���A�������ȒP�ɂ��邽��\�ɓ��ꂷ��

    $CheckPath = $CheckPath.Replace('/','\')

    IF(Test-Path -LiteralPath $CheckPath -IsValid){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]�͗L���ȃp�X�\�L�ł�"
   
        }else{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)]�͗L���ȃp�X�\�L�ł͂���܂���B���݂��Ȃ��h���C�u���w�肵�Ă���ANTFS�Ɏg�p�ł��Ȃ������񂪊܂܂�ĂȂ��������m�F���ĉ�����"
        Finalize $ErrorReturnCode
        }



    Switch -Regex ($CheckPath){

    "^\.+\\.*"{
       
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]�͑��΃p�X�\�L�ł�"

        $ConvertedCheckPath = Join-Path -Path $DatumPath -ChildPath $CheckPath | ForEach-Object {[System.IO.Path]::GetFullPath($_)}
         
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�X�N���v�g���z�u����Ă���t�H���_[$($DatumPath)]�A[$($CheckPath)]�Ƃ�����������΃p�X�\�L[$($ConvertedCheckPath)]�ɕϊ����܂�"

        $CheckPath = $ConvertedCheckPath

        }

        "^[c-zC-Z]:\\.*"{

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]�͐�΃p�X�\�L�ł�"


        }
        Default{
      
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)]�͑��΃p�X�A��΃p�X�\�L�ł͂���܂���"
        Finalize $ErrorReturnCode
        }
    }

    #�p�X������\\���A������Ə��������G�ɂȂ�̂ŁA�g�킹�Ȃ�

    IF($CheckPath -match '\\\\'){
 
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Windows�p�X�w��ŋ�؋L��\�̏d���͋��e����Ă��܂����A�{�v���O�����ł͓s����g�p���܂���B�d������\���폜���܂�"

            For ( $i = 0 ; $i -lt $CheckPath.Length-1 ; $i++ )        
            {
            $CheckPath = $CheckPath.Replace('\\','\')
            }

        Logging -EventID $InfoEventID -EventType Information -EventMessage "�d������\���폜����$ObjectName[$($CheckPath)]�ɕϊ����܂���"
        }


    #�p�X���t�H���_�Ŗ�����\�����݂����ꍇ�͍폜����B������\�L���Ō��ʂ͈ꏏ�Ȃ̂����A���ꂵ�Ȃ��ƕ����񐔂��قȂ邽�߃p�X������؂�o�����듮�삷��B

    IF($CheckPath.Substring($CheckPath.Length -1 , 1) -eq '\'){
    
            Logging -EventID $InfoEventID -EventType Information -EventMessage "Windows�p�X�w��Ŗ���\�͋��e����Ă��܂����A�{�v���O�����ł͓s����g�p���܂���B����\���폜���܂�"
            $CheckPath = $CheckPath.Substring(0 , $CheckPath.Length -1)
            }


    #TEST-Path -isvalid�̓R����:�̊܂܂�Ă���Path�𐳂������肵�Ȃ��̂Ōʂɔ���

    IF ((Split-Path $CheckPath -noQualifier) -match '(\/|:|\?|`"|<|>|\||\*)') {
    
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "$ObjectName ��NTFS�Ŏg�p�ł��Ȃ��������w�肵�Ă��܂�"
                Finalize $ErrorReturnCode
                }


    #Windows�\��ꂪ�p�X�Ɋ܂܂�Ă��邩����

    IF($CheckPath -match '\\(AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])(\\|$|\..*$)'){

                Logging -EventType Error -EventID $ErrorEventID -EventMessage "$ObjectName �̃p�X��Windows�\�����܂�ł��܂��B�ȉ��͗\���̂���Windows�Ńt�@�C���A�t�H���_���̂Ɏg�p�ł��܂���(AUX|CON|NUL|PRN|CLOCK\$|COM[0-9]|LPT[0-9])"
                Finalize $ErrorReturnCode
                }        





    Return $CheckPath

}





#�I��

function EndingProcess{

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)

    IF(($ErrorCount -gt 0) -OR ($ReturnCode -ge $ErrorReturnCode)){

        IF($ErrorAsWarning){
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "�ُ�I�����������܂������A-ErrorAsWarning[$($ErrorAsWarning)]���w�肳��Ă��邽�ߏI���R�[�h��[$($WarningReturnCode)]�ł�"  
            $ReturnCode = $WarningReturnCode
           
            }else{
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "�ُ�I���������������ߏI���R�[�h��[$($ErrorReturnCode)]�ł�"
            $ReturnCode = $ErrorReturnCode
            }

        }elseIF(($WarningCount -gt 0) -OR ($ReturnCode -ge $WarningReturnCode)){

            IF($WarningAsNormal){
                Logging -EventID $InfoEventID -EventType Information -EventMessage "�x���I�����������܂������A-WarningAsNormal[$($WarningAsNormal)]���w�肳��Ă��邽�ߏI���R�[�h��[$($NormalReturnCode)]�ł�" 
                $ReturnCode = $NormalReturnCode
           
                }else{
                Logging -EventID $WarningEventID -EventType Warning -EventMessage "�x���I���������������ߏI���R�[�h��[$($WarningReturnCode)]�ł�"
                $ReturnCode = $WarningReturnCode
                }
        
        }else{
        Logging -EventID $SuccessEventID -EventType Success -EventMessage "����I�����܂����B�I���R�[�h��[$($NormalReturnCode)]�ł�"
        $ReturnCode = $NormalReturnCode
               
        }

    Logging -EventID $InfoEventID -EventType Information -EventMessage "${SHELLNAME} Version $($Version)���I�����܂�"

Exit $ReturnCode

}


#�T�[�r�X���݊m�F


function CheckServiceExist {

Param(
[parameter(mandatory=$true)][String]$ServiceName,
[Switch]$NoMessage
)


# �T�[�r�X��Ԏ擾

    $Service = Get-Service | Where-Object {$_.Name -eq $serviceName}


    IF($Service.Status -Match "^$"){
        IF(-NOT($NoMessage)){Logging -EventID $InfoEventID -EventType Information -EventMessage "�T�[�r�X[$($ServiceName)]�����݂��܂���"}
        Return $False

        }else{

        IF(-NOT($NoMessage)){Logging -EventID $InfoEventID -EventType Information -EventMessage "�T�[�r�X[$($ServiceName)]�͑��݂��܂�"}
        Return $TRUE
        }
}


#�T�[�r�X��Ԋm�F
#����$Health�ŏ��(Running|Stopped)���w�肵�Ă��������B�߂�l�͎w���Ԃ�$TRUE�܂��͔�w����$False
#�T�[�r�X�N���A��~���Ă���Ԑ��ڂɂ͎��Ԃ��|����܂��B����function�͈�莞��$Span�A����$UpTo�A��Ԋm�F���J��Ԃ��܂�
#�N�����x���T�[�r�X��$Span��傫�����Ă�������

function CheckServiceStatus {

Param(
[parameter(mandatory=$true)][String]$ServiceName,
[String][ValidateSet("Running", "Stopped")]$Health = 'Running',
[int][ValidateRange(0,2147483647)]$Span = 3,
[int][ValidateRange(0,2147483647)]$UpTo = 10
)


# �J�E���g�p�ϐ�������
$Counter = 0


    # �������[�v
    While ($true) {

      # �`�F�b�N�񐔃J�E���g�A�b�v
      $Counter++

      # �T�[�r�X���݊m�F
      IF(-NOT(CheckServiceExist $ServiceName -NoMessage)){
      Return $False
      }

      $Service = Get-Service | Where-Object {$_.Name -eq $ServiceName}

      # �T�[�r�X��Ԕ���
      IF ($Service.Status -eq $Health) {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�T�[�r�X[$($ServiceName)]�͑��݂��܂��BStatus[$($Service.Status)]"
        Return $true
       
        }elseIF($Counter -eq $Upto){

            IF(($SPAN -eq 0) -AND ($UpTo -eq 1)){
                Logging -EventID $InfoEventID -EventType Information -EventMessage "�T�[�r�X[$($ServiceName)]�͑��݂��܂��BStatus[$($Service.Status)]"
                Return $False
                }else{

                Logging -EventID $InfoEventID -EventType Information -EventMessage "�T�[�r�X[$($ServiceName)]�͑��݂��܂��B�w����ԁA�񐔂��o�߂��܂�����Status[$($Health)]�ɂ͑J�ڂ��܂���ł����B"
                return $false
                }
        }
     

      # ���Ғl�łȂ��A�`�F�b�N�񐔂̏���ɒB���Ă��Ȃ��ꍇ�́A�w��Ԋu(�b)�ҋ@

      Logging -EventID $InfoEventID -EventType Information -EventMessage "�T�[�r�X[$($ServiceName)]�͑��݂��܂��BStatus[$($Health)]�ł͂���܂���B$($SPAN)�b�ҋ@���܂��B"
      Start-sleep $Span

      # �������[�v�ɖ߂�

    }

}



function CheckNullOrEmpty {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNullOrEmptyFinalize,
[Switch]$NoMessage

)


    If (-NOT([String]::IsNullOrEmpty($CheckPath))){
        Return $False
        }else{

        IF($IfNullOrEmptyFinalize){
           
               Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) �̎w��͕K�{�ł�"
               Finalize $ErrorReturnCode
               }
               
        }

    Return $true
       
}


function CheckContainer {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNoExistFinalize

)


    If (Test-Path -LiteralPath $CheckPath -PathType Container){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)]�͑��݂��܂�"
            Return $true

            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)]�͑��݂��܂���"
                IF($IfNoExistFinalize){
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) �̎w��͕K�{�ł�"
                    Finalize $ErrorReturnCode
                    }else{
                    Return $false
                    }
    }

}


function CheckLeaf {

Param(
[String]$CheckPath,
[String]$ObjectName,

[Switch]$IfNoExistFinalize

)

    If (Test-Path -LiteralPath $CheckPath -PathType Leaf){

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)]�͑��݂��܂�"
            Return $true

            }else{

            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName)[$($CheckPath)]�͑��݂��܂���"
                IF($IfNoExistFinalize){
                    Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) �̎w��͕K�{�ł�"
                    Finalize $ErrorReturnCode
                    }else{
                    Return $false
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

    Split-Path $CheckPath | ForEach-Object {CheckContainer -CheckPath $_ -ObjectName $ObjectName -IfNoExistFinalize > $NULL}

    #���O�o�͐�i�\��j�t�@�C���Ɠ��ꖼ�̂̃t�H���_�����݂��Ă���Έُ�I��

    If(Test-Path -LiteralPath $CheckPath -PathType Container){
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "���ɓ��ꖼ�̃t�H���_$($CheckLeaf)�����݂��܂�"        
        Finalize $ErrorReturnCode
        }


    If(Test-Path -LiteralPath $CheckPath -PathType Leaf){

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckPath)]�ւ̏����������m�F���܂�"
        $LogFormattedDate = (Get-Date).ToString($LogDateFormat)
        $LogWrite = $LogFormattedDate+" "+$SHELLNAME+" Write Permission Check"
        

        Try{
            Write-Output $LogWrite | Out-File -FilePath $CheckPath -Append -Encoding $LogFileEncode
            Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckPath)]�ւ̏����ɐ������܂���"
            }
        Catch [Exception]{
            Logging -EventType Error -EventID $ErrorEventID -EventMessage  "$($ObjectName) [$($CheckPath)]�ւ̏����Ɏ��s���܂���"
            Logging -EventID $ErrorEventID -EventType Error -EventMessage "�N�����G���[���b�Z�[�W : $Error[0]"
            Finalize $ErrorReturnCode
            }
     
     }else{
            TryAction -ActionType MakeNewFileWithValue -ActionFrom $CheckPath -ActionError $CheckPath -FileValue $FileValue
            }

}



function CheckPrivileges {

Param(
[parameter(mandatory=$true)][String]$CheckPath
)

    $FormattedDate = (Get-Date).ToString($TimeStampFormat)

    $TempItemPath = Join-Path $CheckPath ($FormattedDate+".tmp")

        Try{
            New-Item -Path $TempItemPath -ErrorAction Stop -Force >$Null
            Remove-Item -Path $TempItemPath -ErrorAction Stop -Force >$Null
            }

        catch [Exception]{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($CheckPath)�ɕK�v�Ȍ������t�^����Ă��܂���"
        Return $false
        }



}


function CheckExecUser {

    $Script:ScriptExecUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    Logging -EventID $InfoEventID -EventType Information -EventMessage "���s���[�U��$($ScriptExecUser.Name)�ł�"

    IF(-NOT($ScriptExecUser.Name -match $ExecutableUser)){
                Logging -EventType Error -EventID $ErrorEventID -EventMessage "���s������Ă��Ȃ����[�U�ŋN�����Ă��܂��B"
                Finalize $ErrorReturnCode
                }

}



function PreInitialize {

$error.clear()
$ForceConsole = $false
$ForceConsoleEventLog = $false

#ReturnCode�m�F

. CheckReturnCode


#�C�x���g�\�[�X���ݒ莞�̏���

. CheckEventLogSource


#���O�t�@�C���o�͐�m�F

. CheckLogFilePath



#������function�Ȃ̂ŕϐ���function���ł̂��̂ƂȂ�B�X�N���v�g�S�̂ɔ��f����ɂ̓X�R�[�v�𖾎��I��$Script:�ϐ����Ƃ���

#���O�}�~�t���O����

IF($NoLog2EventLog){[boolean]$Script:Log2EventLog = $False}
IF($NoLog2Console){[boolean]$Script:Log2Console = $False}
IF($NoLog2File){[boolean]$Script:Log2File = $False}


Logging -EventID $InfoEventID -EventType Information -EventMessage "${SHELLNAME} Version $($Version)���N�����܂�"

Logging -EventID $InfoEventID -EventType Information -EventMessage "CommonFunctions.ps1 Version $($CommonFunctionsVersion)��Load���܂���"

Logging -EventID $InfoEventID -EventType Information -EventMessage "�p�����[�^�̊m�F���J�n���܂�"

. CheckExecUser


}


function ExecSQL {

Param(
[String]$SQLLogPath,
[parameter(mandatory=$true)][String]$SQLName,
[parameter(mandatory=$true)][String]$SQLCommand,

[Switch]$IfErrorFinalize

)

    $ScriptExecUser = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name

    $LogFormattedDate = (Get-Date).ToString($LogDateFormat)

    $SQLLog = $Null



#Powershell�ł̓q�A�h�L�������g�̉��s��LF�Ƃ��ď��������
#�������Ȃ���A����Oracle����̏o�͂�LF&CR�̂��߁AWindows�������ŊJ���Ɖ��s�R�[�h�����݂��Đ�������������Ȃ�
#����āA�����I��CR��ǉ�����SQLLog�ŉ��s�R�[�h�����݂��Ȃ��悤�ɂ���
#Sakura Editor���ł͉��s�R�[�h���݂����������������

$LogWrite = @"
`r
`r
----------------------------`r
DATE: $LogFormattedDate`r
SHELL: $SHELLNAME`r
SQL: $SQLName`r
`r
OS User: $ScriptExecUser`r
`r
SQL Exec User: $ExecUser`r
Password Authrization [$PasswordAuthorization]`r
`r
"@


Write-Output $LogWrite | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode

Push-Location $OracleHomeBinPath

    IF ($PasswordAuthorization){

    $SQLLog = $SQLCommand | SQLPlus $ExecUser/$ExecUserPassword@OracleSerivce as sysdba

    }else{
    $SQLLog = $SQLCommand | SQLPlus / as sysdba
    }

Write-Output $SQLLog | Out-File -FilePath $SQLLogPath -Append  -Encoding $LogFileEncode


Pop-Location


    IF ($LastExitCode -eq 0){

        Logging -EventID $SuccessEventID -EventType Success -EventMessage "SQL Command[$($SQLName)]���s�ɐ������܂���"
        Return $True

        }else{
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "SQL Command[$($SQLName)]���s�Ɏ��s���܂���"
   
            IF($IfErrorFinalize){
            Finalize $ErrorReturnCode
            }
   
        Return $False
    }



}




function CheckOracleBackUpMode {


    Logging -EventID $InfoEventID -EventType Information -EventMessage "BackUpStatus���擾���āABackUp/Normal�ǂ���̃��[�h�����肵�܂��BActive�̍s��BackUp���[�h�ł�"
  . ExecSQL -SQLCommand $DBCheckBackUpMode -SQLName "DBCheckBackUpMode" -SQLLogPath $SQLLogPath > $Null

   
    #������z��ɕϊ�����
    $SQLLog = $SQLLog -replace "`r","" |  ForEach-Object {$_ -split "`n"}

    $NormalModeCount = 0
    $BackUpModeCount = 0


    $i=1

    foreach ($Line in $SQLLog){

            IF ($Line -match 'NOT ACTIVE'){
            $NormalModeCount ++
            Logging -EventID $InfoEventID -EventType Information -EventMessage "[$Line][$i]�s�� Normal Mode"
 
 
            }elseIF ($Line -match 'ACTIVE'){
            $BackUpModeCount ++
            Logging -EventID $InfoEventID -EventType Information -EventMessage "[$Line][$i]�s�� BackUp Mode"
            }
 
    $i ++
    }


    Logging -EventID $InfoEventID -EventType Information -EventMessage "���݂�Oracle Database�̓��샂�[�h...."

    IF (($BackUpModeCount -eq 0) -and ($NormalModeCount -gt 0)) {
 
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Normal Mode"
        $Script:NormalModeFlag = $TRUE
        $Script:BackUpModeFlag = $False
        Return

    }elseif(($BackUpModeCount -gt 0) -and ($NormalModeCount -eq 0)){
   
        Logging -EventID $InfoEventID -EventType Information -EventMessage "Back Up Mode"
        $Script:NormalModeFlag = $False
        $Script:BackUpModeFlag = $TRUE
        Return


    }else{

        Logging -EventID $InfoEventID -EventType Information -EventMessage "??? Mode ???"
        $Script:NormalModeFlag = $False
        $Script:BackUpModeFlag = $False
        Return
    }


}


function AddTimeStampToFileName{

    Param
    (
    [String]$TimeStampFormat,
    [String]$TargetFileName
    )


    $FormattedDate = (Get-Date).ToString($TimeStampFormat)
    $ExtensionString = [System.IO.Path]::GetExtension($TargetFileName)
    $FileNameWithOutExtentionString = [System.IO.Path]::GetFileNameWithoutExtension($TargetFileName)

    Return $FileNameWithOutExtentionString+$FormattedDate+$ExtensionString

}


function CheckUserName {

Param(
[parameter(mandatory=$true)][String]$CheckUserName,
[String]$ObjectName 
)

    Switch -Regex ($CheckUserName){

    '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckUserName)] is valid"
        Return $TRUE     
        }

    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckUserName)] is invalid"
        Finalize $ErroReturnCode
        }

    }

}

function CheckDomainName {

Param(
[parameter(mandatory=$true)][String]$CheckDomainName,
[String]$ObjectName 
)

    Switch -Regex ($CheckDomainName){

    '^[a-zA-Z][a-zA-Z0-9-]{1,61}[a-zA-Z]$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckDomainName)] is valid"
        Return $TRUE     
        }

    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckDomainName)] is invalid"
        Finalize $ErroReturnCode
        }

    }

}


function CheckHostname {

Param(
[parameter(mandatory=$true)][String]$CheckHostName,
[String]$ObjectName 
)

    Switch -Regex ($CheckHostName){

    '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckHostName)] is valid IP Address"
        Return $TRUE     
        }
    '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'
        {
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$($ObjectName) [$($CheckHostName)] is valid Hostname"
        Return $TRUE                
        }
    Default
        {
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "$($ObjectName) [$($CheckHostName)] is invalid Hostname"
        Finalize $ErroReturnCode
        }

    }

#ValidIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";

#ValidHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";

}
