#Requires -Version 3.0

<#
.SYNOPSIS

This script loads a configuration file including arguments, execute the other script with arguments in every lines.
CommonFunctions.ps1 is required.
You can process log files in multiple folders with FileMaintenance.ps1
<Common Parameters> is not supported.

�w�肵���v���O������ݒ�t�@�C���ɏ����ꂽ�p�����[�^��ǂݍ���ŁA�����Ăяo���v���O�����ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B
�Z�b�g�ŊJ�����Ă���FileMaintenance.ps1�ƕ��p����ƕ����̃��O�������ꊇ���s�ł��܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION

This script loads a configuration file including arguments, execute the other script with arguments in every lines.
The configuration file can be set arbitrarily.
A line starting with # in the configuration file, it is proccessed as a comment.
An empty line in the configuration file, it is sikkiped.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 

�ݒ�t�@�C������1�s�Âp�����[�^��ǂݍ��݁A�w�肵���v���O�����ɏ������s�����܂��B

�ݒ�t�@�C���͔C�ӂɐݒ�\�ł��B
�ݒ�t�@�C���̍s����#�Ƃ���Ɠ��Y�s�̓R�����g�Ƃ��ď�������܂��B
�ݒ�t�@�C���̋󔒍s�̓X�L�b�v���܂��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B

Sample Configuration file. 
Save the file as DailyMaintenance.txt, execute with option '-CommandPath [TargetScript.ps1] -CommandFile .\DailyMaintenance.txt'
---
#delete files older than 14days and end with .log.
-TargetFolder D:\IIS\LOG -RegularExpression '^.*\.log$' -Action Delete -Days 14

#move access log older 7days to Old_Log
-TargetFolder D:\AccessLog -MoveToFolder .\Old_Log -Days 7
---

�ݒ�t�@�C����ł��B�Ⴆ�Έȉ���DailyMaintenance.txt�ɕۑ�����-CommandFile .\DailyMaintenance.txt�Ǝw�肵�ĉ������B

---
#14���o�߂���.log�ŏI���t�@�C�����폜
-TargetFolder D:\IIS\LOG -RegularExpression '^.*\.log$' -Action Delete -Days 14

#7���o�߂����A�N�Z�X���O��Old_Log�֑ޔ�
-TargetFolder D:\AccessLog -MoveToFolder .\Old_Log -Days 7
---



.EXAMPLE

Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Command.txt

Execute .\FileMaintenance.ps1 in the same folder.
Load the parameter file .\Command.txt and execute .\FileMaintenance with arguments in the parameter file every lines.

���̃v���O�����Ɠ���t�H���_�ɑ��݂���FileMaintenance.ps1���N�����܂��B
�N������ۂɓn���p�����[�^�͐ݒ�t�@�C��Comman.txt��1�s�Âǂݍ��݁A�������s���܂��B


.EXAMPLE

Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Command.txt -Continue

Execute .\FileMaintenance.ps1 in the same folder.
Load the parameter file .\Command.txt and execute .\FileMaintenance with arguments in the parameter file every lines.
If ERROR termination occur in the line, do not terminate Wrapper.ps1 and execute FileMaintenance.ps1 with argument in the next line.

�@���̃v���O�����Ɠ���t�H���_�ɑ��݂���FileMaintenance.ps1���N�����܂��B
�N������ۂɓn���p�����[�^�͐ݒ�t�@�C��Comman.txt��1�s�Âǂݍ��݁A�������s���܂��B
�����AFileMaintenance.ps1�����s�������ʂ��ُ�I���ƂȂ����ꍇ�́AWrapper.ps1���ُ�I���������ACommand.txt�̎��s��ǂݍ��݌p�����������܂��B



.PARAMETER CommandPath

Specify the path of script to execute.
Specification is required.
Wild cards are not accepted.

�@�N������v���O�����p�X���w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER CommandFile

Specify the path of command file with arguments.
Specification is required.
Wild cards are not accepted.


�@�N������v���O�����ɓn���R�}���h�t�@�C�����w�肵�܂��B
�w��͕K�{�ł��B
���΁A��΃p�X�Ŏw��\�ł��B
���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER CommandFileEncode

Specify encode chracter code in the command file.
[Default(ShitJIS)] is default.

�@�R�}���h�t�@�C���̕����R�[�h���w�肵�܂��B
�f�t�H���g��[Default]��Shif-Jis�ł��B


.PARAMETER Continue

If you want to execute script with argument next line in the command file ending the script with error.
[This script terminates with Error] is default.

�@�N�������v���O�������ُ�I�����Ă��A�R�}���h�t�@�C���̎��s���p���������܂��B
�f�t�H���g�ł͂��̂܂܈ُ�I�����܂��B



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

[String]
[parameter(position = 0, mandatory, HelpMessage = 'Specify path of powershell script to execute(ex. .\FileMaintenance.ps1)  or Get-Help Wrapper.ps1')]
[ValidateNotNullOrEmpty()]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')][Alias("Path","LiteralPath","FullName")]$CommandPath ,

[String]
[parameter(position = 1, mandatory, HelpMessage = 'Specify path of command file including arguments(ex. .\Command.txt)  or Get-Help Wrapper.ps1')]
[ValidateNotNullOrEmpty()]
[ValidatePattern('^(\\\\|\.+\\|[c-zC-Z]:\\)(?!.*(\/|:|\?|`"|<|>|\||\*)).*$')]$CommandFile ,

[String][ValidateSet("Default", "UTF8" , "UTF7" , "UTF32" , "Unicode")]$CommandFileEncode = 'Default' , #Default�w���Shift-Jis

[Switch]$Continue ,

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

$ShellName = $PSCommandPath | Split-Path -Leaf

#�C�x���g�\�[�X���ݒ莞�̏���
#���O�t�@�C���o�͐�m�F
#ReturnCode�m�F
#���s���[�U�m�F
#�v���O�����N�����b�Z�[�W

. Invoke-PreInitialize

#�����܂Ŋ�������΋Ɩ��I�ȃ��W�b�N�݂̂��m�F����Ηǂ�


#�p�����[�^�̊m�F


#�R�}���h�̗L�����m�F


    $CommandPath = $CommandPath | ConvertTo-AbsolutePath -ObjectName ' -CommandPath'

    $CommandPath | Test-Leaf -Name '-CommandPath' -IfNoExistFinalize > $NULL

#�R�}���h�t�@�C���̗L�����m�F
    

    $CommandFile = $CommandFile | ConvertTo-AbsolutePath -ObjectName '-CommandFile'

    $CommandFile | Test-Leaf -Name '-CommandFile' -IfNoExistFinalize > $NULL


#�����J�n���b�Z�[�W�o��


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Start to execute command [$($CommandPath)] with arguments [$($CommandFile)]"

}

function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)

    IF (-not(($NormalCount -eq 0) -and ($WarningCount -eq 0) -and ($ErrorCount -eq 0))) {

        Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execution Results NORMAL[$($NormalCount)], WARNING[$($WarningCount)], ERROR[$($ErrorCount)]"

        If (($Continue) -and ($ErrorCount -gt 0)){
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "An ERROR termination occurred. Specified -Continue[${Continue}] option, thus will terminate with ERROR and had executed command of the next lines."
            }


    }


 Invoke-PostFinalize $ReturnCode

}



#####################   ��������{��  ######################

[int][ValidateRange(0,2147483647)]$NormalCount  = 0
[int][ValidateRange(0,2147483647)]$WarningCount = 0
[int][ValidateRange(0,2147483647)]$ErrorCount   = 0

$DatumPath = $PSScriptRoot

$Version = "2.0.0-beta.14"

#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

    Try {

        $lines = @(Get-Content $CommandFile -Encoding $CommandFileEncode -ErrorAction Stop)  
        }
        
        catch [Exception] {
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to load -CommandFile"
            $errorDetail = $ERROR[0] | Out-String
            Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
            Finalize $ErrorReturnCode
            }


For ( $i = 0 ; $i -lt $lines.Count; $i++ ) {

    $line = $lines[$i]

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)]"


    Switch -Regex ($line) {

        #����1 �s��#�ŃR�����g
        '^#.*$' {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Comment[$($line)]"
            }

        #����2 ��
        '^$' {
            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Empty Line"
            }

        #����3 �R�}���h���s
        default {

            Try{        
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execute Command [$($CommandPath)] with arguments [$($line)]"
                    Invoke-Expression "$CommandPath $line" -ErrorAction Stop
                    }

                catch [Exception] {
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Failed to execute [$($CommandPath)] and force to exit."
                    $errorDetail = $ERROR[0] | Out-String
                    Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Execution Error Message : $errorDetail"
                    Finalize $ErrorReturnCode
                    }

            Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Execution Result is [$($LASTEXITCODE)] at line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)]"
                    

            #�I���R�[�h�ŕ���
            Switch ($LASTEXITCODE) {

                        #����1 �ُ�I��
                        {$_ -ge $ErrorReturnCode} {
 
                            $ErrorCount++
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "An ERROR termination occurred at line [$($i+1)/$($Lines.Count)] in -CommandFile [$($CommandFile)]"
       
                            IF ($Continue) {
                                Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Specified -Continue[$($Continue)] option, thus execute next line."   
                                Break     
     
                                }else{
                                Finalize $ErrorReturnCode
                                }
                            }
                    
                        #����2 �x���I��
                        {$_ -ge $WarningReturnCode} {
                            
                            $WarningCount++
                            Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "A WARNING termination occurred at line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)] Will execute next line." 
                            Break        
                            }
                        
                        #����3 ����I��
                        Default {
                            $NormalCount++
                            Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Completed successfully at line [$($i+1)/$($lines.Count)] in -CommandFile [$($CommandFile)]"
                            }
                   }
    
   
                # ����3 �R�}���h���s default�I�[ 
                }

    #Switch -Regex ($Line)�I�[
    }

#�ΏیQ�̏������[�v�I�[
}


#�I�����b�Z�[�W�o�́B�����ł�NormalReturnCode�ŌĂяo�����AFinalize�ŃG���[�J�E���g�����ď������Ă����

Finalize $NormalReturnCode
