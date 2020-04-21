#Requires -Version 3.0


<#
.SYNOPSIS
Script to Stop or Start IIS site.
CommonFunctions.ps1 is required.
With Wrapper.ps1 start or stop multiple IIS sites.

<Common Parameters> is not supported.

.DESCRIPTION
Script to Stop or Start IIS site.
If start(stop) IIS site already started(stopped), will temrminate with WARNING.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


.EXAMPLE
ChangeIIState.ps1 -Site SSL -TargetState stopped

Stop IIS site 'SSL'


.EXAMPLE
ChangeIIState.ps1 -Site SSL -TargetState started

Start IIS site 'SSL'


.PARAMETER Site
Specify IIS site

.PARAMETER TargetState
Specify IIS site state 'Started' or 'Stopped' 


.PARAMETER RetrySpanSec
�@�T�[�r�X��~�Ċm�F�̊Ԋu�b�����w�肵�܂��B
�T�[�r�X�ɂ���Ă͐��b�K�v�Ȃ��̂�����̂œK�؂ȕb���ɐݒ肵�ĉ������B
�f�t�H���g��3�b�ł��B

.PARAMETER RetryTimes
�@�T�[�r�X��~�Ċm�F�̉񐔂��w�肵�܂��B
�T�[�r�X�ɂ���Ă͐��b�K�v�Ȃ��̂�����̂œK�؂ȉ񐔂ɐݒ肵�ĉ������B
�f�t�H���g��5��ł��B





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

[String][parameter(position = 0, mandatory, HelpMessage = 'Enter IIS site name. To view all help , Get-Help ChangeIISstate.ps1')]$Site ,

[String][parameter(position = 1)][ValidateNotNullOrEmpty()][ValidateSet("Started", "Stopped")][Alias("State")]$TargetState = 'Stopped' , 
[int][parameter(position = 2)][ValidateRange(1,65535)]$RetrySpanSec = 3 ,
[int][parameter(position = 3)][ValidateRange(1,65535)]$RetryTimes = 5 ,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $False,
[Switch]$NoLog2File,
[String][ValidatePattern('^(\.+\\|[c-zC-Z]:\\).*')]$LogPath ,
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

    IF (-not('W3SVC' | Test-ServiceExist)) {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Web Service [W3SVC] dose not exist."
        Finalize $ErrorReturnCode
        }
 
     IF ($TargetState -notmatch '^(Started|Stopped)$') {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "-TargetState [$($TargetState)] is invalid specification."
        Finalize $ErrorReturnCode   
        }
       

    IF (Get-Website | Where-Object{$_.Name -ne $Site}) {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Site [$($Site)] dose not exist."
        Finalize $ErrorReturnCode
        }


    IF (Get-Website | Where-Object{$_.Name -eq $Site} | Where-Object {$_.State -eq $TargetState}) {
        Write-Log -EventID $WarningEventID -EventType Warning -EventMessage "Site [$($Site)] state is already [$($TargetState)]."
        Finalize $WarningReturnCode
        }
        



#�����J�n���b�Z�[�W�o��


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "All parameters are valid."

Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Starting to change IIS Site [$($Site)] state."

}


function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)


 Invoke-PostFinalize $ReturnCode


}


#####################   ��������{��  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.4"


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize


 Switch -Regex ($TargetState) {
 
    'Stopped' {
        $OriginalState = 'Started'    
        }
    
    'Started' {
        $OriginalState = 'Stopped'
        }

    Default {
        Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage 'Internal Error. $TargetState is invalid. '
        Finalize $InternalErrorReturnCode    
        }
 }


Write-Log -EventID $InfoEventID -EventType Information -EventMessage "With Powershell Cmdlet, Starting to switch site [$($Site)] state from [$($OriginalState)] to [$($TargetState)]"
        
    Switch -Regex ($TargetState) {
 
        'Stopped' {
            Stop-Website -Name $Site
            }
    
        'Started' {
            Start-Website -Name $Site
            }

        Default {
            Write-Log -EventID $InternalErrorEventID -EventType Error -EventMessage 'Internal Error. $TargetState is invalid. '
            Finalize $InternalErrorReturnCode
            }
    }

$result = $ErrorReturnCode

:ForLoop For ( $i = 0 ; $i -le $RetryTimes ; $i++ ) {

      $siteState = Get-Website | Where-Object{$_.Name -eq $Site} | ForEach-Object{$_.State}

           Switch ($siteState) {
        
                $TargetState {
                    Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "Site[$($Site)] state was [$($SiteState)]"
                    $result = $NormalReturnCode
                    Break ForLoop
                    }


                $OriginalState {
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Site [$($Site)] state is still [$($SiteState)]"
                    }

              
                DEFAULT {
                    Write-Log -EventID $InfoEventID -EventType Information -EventMessage "Site [$($site)] state is [$($SiteState)]"
                    } 
            }  
    
    IF ($i -ge $RetryTimes) {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "Although waiting specified times , site [$($Site)] state did not switch to [$($TargetState)]"
        Break
        }

    #�`�F�b�N�񐔂̏���ɒB���Ă��Ȃ��ꍇ�́A�w��b�ҋ@

    Write-Log -EventID $InfoEventID -EventType Information -EventMessage ("Site [$($Site)] exists and site state did not change to [$($TargetState)] " +
        "Wait for $($RetrySpanSec) seconds. Retry [" + ($i+1) + "/$RetryTimes]")
    Start-Sleep -Seconds $RetrySpanSec
}

Finalize $result
