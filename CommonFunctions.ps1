#Requires -Version 3.0

$Script:CommonFunctionsVersion = '20200115_2115'

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


    IF($Log2EventLog){

    Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType $EventType -EventId $EventID -Message "[$($SHELLNAME)] $($EventMessage)"
    }


    IF($Log2Console){

    $ConsoleWrite = $EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
    Write-Host $ConsoleWrite
    }   


    IF($Log2File){
    $LogFormattedDate = (Get-Date).ToString($LogDateFormat)
    $LogWrite = $LogFormattedDate+" "+$SHELLNAME+" "+$EventType.PadRight(14)+"EventID "+([String]$EventID).PadLeft(6)+"  "+$EventMessage
    Write-Output $LogWrite | Out-File -FilePath $LogPath -Append 
    }   

}


#�C�x���g�\�[�X���ݒ莞�̏���
#���̊m�F���I���܂ł�Function Logging�̃��O�o�͉\���m�肵�Ȃ��̂ŁA�ُ펞��Exit�Ŕ�����

function CheckEventLogSource{

    Try{

           
        If (-NOT([System.Diagnostics.Eventlog]::SourceExists($ProviderName) ) ){
        #�V�K�C�x���g�\�[�X��ݒ�

           
            New-EventLog -LogName $EventLogLogName -Source $ProviderName  -ErrorAction Stop
            Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Information -EventId $InfoEventID -Message "[$($SHELLNAME)] �V�K�C�x���g�\�[�X[$(ProviderName)]��[$($EventLogLogName)]�֓o�^���܂���"
            }
       
    }
    Catch [Exception]{
    Write-Output "EventLog��Souce $($ProviderName)�����݂��Ȃ����߁A�V�K�쐬�����݂܂��������s���܂����B�V�KSource�̍쐬�͎��s���[�U���Ǘ��Ҍ�����ۗL���Ă���K�v������܂��B��xPowershell���Ǘ��Ҍ����ŊJ���Ď蓮�ł��̃v���O���������s���Ă��������B"
    Write-Output "�N�����G���[���b�Z�[�W : $Error[0]"
    Exit $ErrorReturnCode
    }
       
}


#���O�t�@�C���o�͐�m�F
#���̊m�F���I���܂ł�Function Logging�̃��O�o�͉\���m�肵�Ȃ��̂ŁA�ُ펞��Exit�Ŕ�����

function CheckLogFilePath{




    IF (-NOT($Log2File)){
        Return
        }


    IF(-NOT(Test-Path -LiteralPath $LogPath -IsValid)){

       Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID -Message "[$($LogPath)]�͗L���ȃp�X�\�L�ł͂���܂���BNTFS�Ɏg�p�ł��Ȃ������񂪊܂܂�ĂȂ��������m�F���ĉ�����"
       Write-Output  "[$($LogPath)]�͗L���ȃp�X�\�L�ł͂���܂���BNTFS�Ɏg�p�ł��Ȃ������񂪊܂܂�ĂȂ��������m�F���ĉ�����"
       Exit $ErrorReturnCode  

    }



        IF ([String]::IsNullOrEmpty($LogPath)){
           
            Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID -Message "[$($SHELLNAME)] -Log2File[$($Log2File)]���w�肵�����A���O�o�͐� -LogPath�̎w�肪�K�v�ł�"
           
            Write-Output "-Log2File[$($Log2File)]���w�肵�����A���O�o�͐� -LogPath�̎w�肪�K�v�ł�"
           
            Exit $ErrorReturnCode
            }




                #���O�o�͐�w�肪���΃p�X&�J�����g�p�X���X�N���v�g�z�u��ł͂Ȃ��\�����l�����āA���΃p�X�w��̓X�N���v�g�z�u�����ɂ����p�X�ɕϊ�����

    Switch -Regex ($LogPath){

        "^\.+\\.*"{
       
            $Script:LogPath =  Join-Path ${THIS_PATH} $LogPath | ForEach-Object {[System.IO.Path]::GetFullPath($_)}

            }

        "^[c-zC-Z]:\\.*"{
       
            }
      
        Default{
       
            Write-Output "-LogPath [-LogPath $($LogPath)]�͑��΃p�X�A��΃p�X�\�L�ł͂���܂���"
            Exit $ErrorReturnCode
            }
    }


        IF(Test-Path -LiteralPath $LogPath -PathType Container){
                   Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID -Message "[$($SHELLNAME)] ���O�o�͐�t�@�C���w���ɓ��ꖼ�̂̃t�H���_�����݂��Ă��܂��B"      
                   Write-Output "[$($SHELLNAME)] ���O�o�͐�t�@�C���w���ɓ��ꖼ�̂̃t�H���_�����݂��Ă��܂��B"      
                  
                   Exit $ErrorReturnCode

                    #���̎��_��$LogPath�ɂ͓����t�H���_�͑��݂��Ȃ��̂ŁA�����t�@�C�������݂��邩���m�F����
                    }elseif(-NOT(Test-Path -LiteralPath $LogPath -PathType Leaf) ){
                   
                        Try{
                            New-Item $LogPath -ItemType File > $NULL  -ErrorAction Stop

                            #�V�K�쐬�ɐ�������΁ALogging���g����
                            Logging -EventID $InfoEventID -EventType Information -EventMessage "[$($SHELLNAME)] ���O�o�͐�t�@�C�������݂��܂���B$($LogPath)��V�K�쐬���܂�"
                        }
       
                        catch [Exception]{
                        Write-EventLog -LogName $EventLogLogName -Source $ProviderName -EntryType Error -EventId $ErrorEventID -Message "[$($SHELLNAME)] ���O�o�͐�t�@�C��$($LogPath)�̍쐬�Ɏ��s���܂����B�쐬��t�H���_�����݂��Ȃ����A�������s�����Ă��܂�"
                        Write-Output "���O�o�͐�t�@�C��$($LogPath)�̍쐬�Ɏ��s���܂����B�쐬��t�H���_�����݂��Ȃ����A�������s�����Ă��܂�"
                        Write-Output "�N�����G���[���b�Z�[�W : $Error[0]"
                        Exit $ErrorReturnCode
                        }
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




function TryAction {
    
    Param(

    [parameter(mandatory=$true)][String][ValidateSet("Move", "Copy", "Delete" , "AddTimeStamp" , "NullClear" ,"Compress" , "CompressAndAddTimeStamp" , "MakeNewFolder" ,"MakeNewFileWithValue")]$ActionType,
    [parameter(mandatory=$true)][String]$ActionFrom,
    [String]$ActionTo,
    [parameter(mandatory=$true)][String]$ActionError,
    [String]$FileValue,
    [Switch]$NoContinueOverRide

    )

    IF (-NOT($ActionType -match "^(Delete|NullClear|MakeNewFolder)$" ) -and ($Null -eq $ActionTo)){

    Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Function TryAction�����G���[�B${ActionType}�ł�$'$ActionTo'�̎w�肪�K�v�ł�"
    Finalize $InternalErrorReturnCode
    }

    IF($NoAction){
    
        Logging -EventID $WarningEventID -EventType Warning -EventMessage "-NoAction���w�肳��Ă��邽�߁A${ActionError}��[${ActionType}]�͎��s���܂���ł���"
        Return
        }
      
    Try{
  

       Switch -Regex ($ActionType){



        '^(Copy|AddTimeStamp)$'
            {
            Copy-Item -LiteralPath $ActionFrom $ActionTo -Force > $Null -ErrorAction Stop
            }

        '^Move$'
            {
            Move-Item -LiteralPath $ActionFrom $ActionTo -Force > $Null -ErrorAction Stop
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
                                           
        Default                                 
            {
            Logging -EventID $InternalErrorEventID -EventType Error -EventMessage "Function TryAction�����G���[�B���莮��bug������܂�"
            Finalize $InternalErrorReturnCode
            }
      }       
   
   
   
    }   
    catch [Exception]{
       
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "${ActionError}��[${ActionType}]�Ɏ��s���܂���"
        $ErrorDetail = $Error[0] | Out-String
        Logging -EventID $ErrorEventID -EventType Error -EventMessage "�N�����G���[���b�Z�[�W : $ErrorDetail"
        $Script:ErrorFlag = $TRUE

        If(($Continue) -AND (-NOT($NoContinueOverRide))){
            Logging -EventID $WarningEventID -EventType Warning -EventMessage "-Continue[$($Continue)]�̂��ߏ������p�����܂��B"
            $Script:WarningFlag = $TRUE
            $Script:ContinueFlag = $TRUE
            Return
            }

        #Continue���Ȃ��ꍇ�͏I�������֐i��
        Finalize $ErrorReturnCode   
    }


   
    Logging -EventID $SuccessEventID -EventType Success -EventMessage "${ActionError}��[${ActionType}]�ɐ������܂���"
   

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


    IF(Test-Path -LiteralPath $CheckPath -IsValid){
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]�͗L���ȃp�X�\�L�ł�"
   
    }else{
       Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)]�͗L���ȃp�X�\�L�ł͂���܂���BNTFS�Ɏg�p�ł��Ȃ������񂪊܂܂�ĂȂ��������m�F���ĉ�����"
       Finalize $ErrorReturnCode  

    }


    Switch -Regex ($CheckPath){

    "^\.+\\.*"{
       
        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]�͑��΃p�X�\�L�ł�"

        $ConvertedCheckPath = Join-Path ${THIS_PATH} $CheckPath | ForEach-Object {[System.IO.Path]::GetFullPath($_)}
         
        Logging -EventID $InfoEventID -EventType Information -EventMessage "�X�N���v�g���z�u����Ă���t�H���_[${THIS_PATH}]�A[$($CheckPath)]�Ƃ�����������΃p�X�\�L[$($ConvertedCheckPath)]�ɕϊ����܂�"

        Return $ConvertedCheckPath
        }

        "^[c-zC-Z]:\\.*"{

        Logging -EventID $InfoEventID -EventType Information -EventMessage "$ObjectName[$($CheckPath)]�͐�΃p�X�\�L�ł�"

        Return $CheckPath

        }
       Default{
      
       Logging -EventID $ErrorEventID -EventType Error -EventMessage "$ObjectName[$($CheckPath)]�͑��΃p�X�A��΃p�X�\�L�ł͂���܂���"
       Finalize $ErrorReturnCode
       }
    }

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
       
        }elseif ($Counter -eq $Upto){

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
      sleep $Span

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


#�C�x���g�\�[�X���ݒ莞�̏���

. CheckEventLogSource


#���O�t�@�C���o�͐�m�F

. CheckLogFilePath


#ReturnCode�m�F

. CheckReturnCode

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

    $ScriptExecUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    $ScriptExecUser = $ScriptExecUser.Name

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
#    $SQLLog = $SQLLog -replace "`r",""
#    $SQLLog = $SQLLog -split "`n"

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


#https://github.com/mnaoumov/Invoke-NativeApplication

function Invoke-NativeApplication
{
    param
    (
        [ScriptBlock] $ScriptBlock,
        [int[]] $AllowedExitCodes = @(0),
        [switch] $IgnoreExitCode
    )

    $backupErrorActionPreference = $ErrorActionPreference

    $ErrorActionPreference = "Continue"
    try
    {
        if (Test-CalledFromPrompt)
        {
            $wrapperScriptBlock = { & $ScriptBlock }
        }
        else
        {
            $wrapperScriptBlock = { & $ScriptBlock 2>&1 }
        }

        & $wrapperScriptBlock | ForEach-Object -Process `
            {
                $isError = $_ -is [System.Management.Automation.ErrorRecord]
                "$_" | Add-Member -Name IsError -MemberType NoteProperty -Value $isError -PassThru
            }
        if ((-not $IgnoreExitCode) -and (Test-Path -LiteralPath -Path Variable:LASTEXITCODE) -and ($AllowedExitCodes -notcontains $LASTEXITCODE))
        {
            throw "Execution failed with exit code $LASTEXITCODE"
        }
    }
    finally
    {
        $ErrorActionPreference = $backupErrorActionPreference
    }
}

function Invoke-NativeApplicationSafe
{
    param
    (
        [ScriptBlock] $ScriptBlock
    )

    Invoke-NativeApplication -ScriptBlock $ScriptBlock -IgnoreExitCode | `
        Where-Object -FilterScript { -not $_.IsError }
}

function Test-CalledFromPrompt
{
    (Get-PSCallStack)[-2].Command -eq "prompt"
}

Set-Alias -Name exec -Value Invoke-NativeApplication
Set-Alias -Name safeexec -Value Invoke-NativeApplicationSafe
