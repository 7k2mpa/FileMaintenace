#Requires -Version 3.0

<#
.SYNOPSIS
�w�肵���v���O������ݒ�t�@�C���ɏ����ꂽ�p�����[�^��ǂݍ���Ŏ��s���܂��B
����I���ɑJ�ڂ���܂ŁA�w��b���Ԋu�Ŏw��񐔎��s���܂��B


���s�ɂ�CommonFunctions.ps1���K�v�ł��B


<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
�w�肵���v���O������ݒ�t�@�C���ɏ����ꂽ�p�����[�^��ǂݍ���Ŏ��s���܂��B
����I���ɑJ�ڂ���܂ŁA�w��b���Ԋu�Ŏw��񐔎��s���܂��B
�w�肵���v���O����������I�������ꍇ�A�{�v���O�����͐���I�����܂��B
�w�肵���v���O�������x���I�������ꍇ�A�{�v���O�����͎w��b���Ԋu�Ŏw��񐔎w�肵���v���O�������Ď��s���܂��B
�w��񐔂𒴉߂����ꍇ�͌x���I�����܂��B

�w�肵���v���O�������ُ�I�������ꍇ�A�{�v���O�����ُ͈�I�����܂��B


�ݒ�t�@�C���͔C�ӂɐݒ�\�ł��B
�ݒ�t�@�C����1�s�ڂ݂̂��w�肵���v���O�����ɓn���Ď��s���܂��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B



�ݒ�t�@�C����ł��B
�Ⴆ�Έȉ���LoopWrapperCommand.txt�ɕۑ����܂��B
�����-CommandPath .\CheckFlag.ps1 -CommandFile .\LoopWrapperCommand.txt�������Ƃ��Ė{�v���O���������s���܂���

---�@
-CheckFolder .\Lock -CheckFile BkupDB.flg
---



.EXAMPLE

LoopWrapper.ps1 -CommandPath .\CheckFlag.ps1 -CommandFile .\Command.txt
�@���̃v���O�����Ɠ���t�H���_�ɑ��݂���CheckFlag.ps1���N�����܂��B
�N������ۂɓn���p�����[�^�͐ݒ�t�@�C��Comman.txt��1�s�ڂł��B

CheckFlag.ps1������I������ƁA�{�v���O�����͐���I�����܂��B

CheckFlag.ps1���x���I������ƁA�{�v���O�����͎w��b���Ԋu�Ŏw���CheckFlag.ps1���Ď��s���܂��B
CheckFlag.ps1�̓t���O�t�@�C�������݂��Ȃ��Ɛ���I���A���݂���ƌx���I�����܂��B
���̐ݒ�ł́A�t���O�t�@�C�����폜�����܂Ŗ{�v���O�����͎w��񐔃��[�v�p�����܂��B
�w��񐔂𒴉߂����ꍇ�͌x���I�����܂��B


CheckFlag.ps1���ُ�I������ƁA�{�v���O�����ُ͈�I�����܂��B


.EXAMPLE

LoopWrapper.ps1 -CommandPath .\CheckFlag.ps1 -CommandFile .\Command.txt -Span 60 -UpTo 120
�@���̃v���O�����Ɠ���t�H���_�ɑ��݂���CheckFlag.ps1���N�����܂��B
�N������ۂɓn���p�����[�^�͐ݒ�t�@�C��Comman.txt��1�s�ڂł��B

CheckFlag.ps1������I������ƁA�{�v���O�����͐���I�����܂��B

CheckFlag.ps1���x���I������ƁA�{�v���O�����͎w��b���Ԋu�Ŏw���CheckFlag.ps1���Ď��s���܂��B
60�b�Ԋu��120�񎎍s���܂��B

CheckFlag.ps1�̓t���O�t�@�C�������݂��Ȃ��Ɛ���I���A���݂���ƌx���I�����܂��B
���̐ݒ�ł́A�t���O�t�@�C�����폜�����܂Ŗ{�v���O�����͎w��񐔃��[�v�p�����܂��B

�w��񐔂𒴉߂����ꍇ�͌x���I�����܂��B


CheckFlag.ps1���ُ�I������ƁA�{�v���O�����ُ͈�I�����܂��B



.PARAMETER CommandPath
�@�N������v���O�����p�X���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER CommandFile
�@�N������v���O�����ɓn���R�}���h�t�@�C�����w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER CommandFileEncode
�@�R�}���h�t�@�C���̕����R�[�h���w�肵�܂��B
�f�t�H���g��[Default]��Shif-Jis�ł��B


.PARAMETER Span
�Ď��s���̊Ԋu��b���Ŏw�肵�܂��B
�f�t�H���g��10�b�ł��B

.PARAMETER UpTo
�Ď��s�̎��s�񐔂��w�肵�܂��B
�f�t�H���g��1000��ł��B

.PARAMETER Continue
�N�������v���O�������ُ�I�����Ă����[�v�������p�����܂��B



.PARAMETER Log2EventLog
�@Windows Event Log�ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE��Event Log�o�͂��܂��B

.PARAMETER NoLog2EventLog
�@Event Log�o�͂�}�~���܂��B-Log2EventLog $False�Ɠ����ł��B

.PARAMETER ProviderName
�@Windows Event Log�o�͂̃v���o�C�_�����w�肵�܂��B�f�t�H���g��[Infra]�ł��B

.PARAMETER EventLogLogName
�@Windows Event Log�o�͂̃��O�������Ă��܂��B�f�t�H���g��[Application]�ł��B

.PARAMETER Log2Console 
�@�R���\�[���ւ̃��O�o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE�ŃR���\�[���o�͂��܂��B

.PARAMETER NoLog2Console
�@�R���\�[�����O�o�͂�}�~���܂��B-Log2Console $False�Ɠ����ł��B

.PARAMETER Log2File
�@���O�t�B���ւ̏o�͂𐧌䂵�܂��B�f�t�H���g��$False�Ń��O�t�@�C���o�͂��܂���B

.PARAMETER NoLog2File
�@���O�t�@�C���o�͂�}�~���܂��B-Log2File $False�Ɠ����ł��B

.PARAMETER LogPath
�@���O�t�@�C���o�̓p�X���w�肵�܂��B�f�t�H���g��$NULL�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���΃p�X�\�L�́A.����n�߂�\�L�ɂ��ĉ������B�i�� .\Log\Log.txt , ..\Script\log\log.txt�j
���C���h�J�[�h* ? []�͎g�p�ł��܂���B
�t�H���_�A�t�@�C�����Ɋ��� [ , ] ���܂ޏꍇ�̓G�X�P�[�v�����ɂ��̂܂ܓ��͂��Ă��������B
�t�@�C�������݂��Ȃ��ꍇ�͐V�K�쐬���܂��B
�t�@�C���������̏ꍇ�͒ǋL���܂��B

.PARAMETER LogDateFormat
�@���O�t�@�C���o�͂Ɋ܂܂������\���t�H�[�}�b�g���w�肵�܂��B�f�t�H���g��[yyyy-MM-dd-HH:mm:ss]�`���ł��B

.PARAMETER NormalReturnCode
�@����I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��0�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER WarningReturnCode
�@�x���I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��1�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER ErrorReturnCode
�@�ُ�I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��8�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER InternalErrorReturnCode
�@�v���O���������ُ�I�����̃��^�[���R�[�h���w�肵�܂��B�f�t�H���g��16�ł��B����I��=<�x���I��=<�i�����j�ُ�I���Ƃ��ĉ������B

.PARAMETER InfoEventID
�@Event Log�o�͂�Information�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��1�ł��B

.PARAMETER WarningEventID
�@Event Log�o�͂�Warning�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��10�ł��B

.PARAMETER SuccessErrorEventID
�@Event Log�o�͂�Success�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��73�ł��B

.PARAMETER InternalErrorEventID
�@Event Log�o�͂�Internal Error�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��99�ł��B

.PARAMETER ErrorEventID
�@Event Log�o�͂�Error�ɑ΂���Event ID���w�肵�܂��B�f�t�H���g��100�ł��B

.PARAMETER ErrorAsWarning
�@�ُ�I�����Ă��x���I����ReturnCode��Ԃ��܂��B

.PARAMETER WarningAsNormal
�@�x���I�����Ă�����I����ReturnCode��Ԃ��܂��B

.PARAMETER ExecutableUser
�@���̃v���O���������s�\�ȃ��[�U�𐳋K�\���Ŏw�肵�܂��B
�f�t�H���g��[.*]�őS�Ẵ��[�U�����s�\�ł��B�@
�L�q�̓V���O���N�I�[�e�[�V�����Ŋ����ĉ������B
���K�\���̂��߁A�h���C���̃o�b�N�X���b�V����[domain\\.*]�̗l�Ƀo�b�N�X���b�V���ŃG�X�P�[�v���ĉ������B�@

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

[parameter(position=0, mandatory=$true , HelpMessage = '�N���Ώۂ�powershell�v���O�������w��(ex. .\FileMaintenance.ps1) �S�Ă�Help��Get-Help Wrapper.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*\.ps1$')]$CommandPath ,
[parameter(position=1, mandatory=$true , HelpMessage = 'powershell�v���O�����Ɏw�肷��R�}���h�t�@�C�����w��(ex. .\Command.txt) �S�Ă�Help��Get-Help Wrapper.ps1')][String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommandFile,


[parameter(position=2)][ValidateRange(1,65535)][int]$Span = 10,
[parameter(position=3)][ValidateRange(1,65535)][int]$UpTo = 1000,

[Switch]$Continue,

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default', #Default�w���Shift-Jis


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
[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$LogFileEncode = 'Default', #Default�w���Shift-Jis

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

    #CommonFunctions.ps1�̔z�u���ύX�����ꍇ�́A������ύX�B����t�H���_�ɔz�u�O��
    ."$PSScriptRoot\CommonFunctions.ps1"
    }
    Catch [Exception]{
    Write-Output "Fail to load CommonFunctions.ps1 Please verfy existence of CommonFunctions.ps1 in the same folder."
    Exit 1
    }


################ �ݒ肪�K�v�Ȃ̂͂����܂� ##################



################# ���ʕ��i�A�֐�  #######################

function Initialize {

$ShellName = Split-Path -Path $PSCommandPath -Leaf

#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. Invoke-PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�


#�p�����[�^�̊m�F


#�R�}���h�̗L�����m�F


    $CommandPath = $CommandPath | ConvertTo-AbsolutePath -ObjectName '-CommandPath'

    Test-Leaf -CheckPath $CommandPath -ObjectName '-CommandPath' -IfNoExistFinalize > $NULL

#�R�}���h�t�@�C���̗L�����m�F
    

    $CommandFile = $CommandFile | ConvertTo-AbsolutePath -ObjectName '-CommandFile'

    Test-Leaf -CheckPath $CommandFile -ObjectName '-CommandFile' -IfNoExistFinalize > $NULL


#�����J�n���b�Z�[�W�o��


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Starting to exec command [$($CommandPath)]�ł�"

}

function Finalize {

Param(
[parameter(mandatory=$true)][int]$ReturnCode
)




 Invoke-PostFinalize $ReturnCode

}



#####################   ��������{��  ######################

$DatumPath = $PSScriptRoot

$Version = '20200224_1640'

#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

    Try {

        $line = @(Get-Content $CommandFile -Encoding $CommandFileEncode -TotalCount 1  -ErrorAction Stop)
        }
                    catch [Exception]
                    {
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to load -CommandFile"
                    $errorDetail = $Error[0] | Out-String
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
                    Finalize $ErrorReturnCode
                    }




For ( $i = 1 ; $i -le $UpTo ; $i++ ){

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute 1st line in [$($CommandFile)]"
    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Try times [$($i)/$($UpTo)]"

        Try {
        
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute command [$($CommandPath)] with arguments [$($line)]"
            Invoke-Expression "$CommandPath $Line" -ErrorAction Stop

            }

            catch [Exception]{

            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute [$($CommandPath)]"
            $errorDetail = $Error[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
            }

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Result of execution [$($CommandFile)] is [$($LASTEXITCODE)]"
                    

        #�I���R�[�h�ŕ���
        Switch ($LastExitCode) {

                        #����1 �ُ�I��
                        {$_ -ge $ErrorReturnCode} {
 
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "An ERROR termination occurred at line 1 in -CommandFile [$($CommandFile)]"
       
                            IF ($Continue) {
                                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Will try again, because option -Continue[$($Continue)] is used." 
                                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Wait for [$($Span)] seconds."
                                Start-Sleep -Seconds $Span
                                Break     
     
                                }else{
                                Finalize $ErrorReturnCode
                                }
                            }

                    
                        #����2 �x���I��
                        {$_ -ge $WarningReturnCode} {
                            

                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "A WARNING termination occurred at line 1 in [$($CommandFile)] , will try again. " 
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Waint for [$($Span)] seconds."
                            Start-Sleep -Seconds $Span                             
                            }

                        
                        #����3 ����I��
                        Default {

                            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Completed successfully in [$($i)] times try."                        
                            Finalize $NormalReturnCode
                            }
        }
    
  

#�ΏیQ�̏������[�v�I�[
}

Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Although with [$($UpTo)] times retry, did not complete successfully. Thus terminate as WARNING." 

Finalize $WarningReturnCode