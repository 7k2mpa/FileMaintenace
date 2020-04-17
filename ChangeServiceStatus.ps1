#Requires -Version 3.0


<#
.SYNOPSIS
This scipt start or stop Windows Service specified.
CommonFunctions.ps1 is required.
You can process multiple Windows services with Wrapper.ps1
<Common Parameters> is not supported.


�w�肵���T�[�r�X���N��,��~����v���O�����ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B
�Z�b�g�ŊJ�����Ă���FileMaintenance.ps1�ƕ��p����ƕ����̃T�[�r�X���ꊇ�N��,��~�ł��܂��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

.DESCRIPTION
This scipt start or stop Windows Service specified.
If start(stop) Windows serivce already started(stopped), will temrminate as WARNING.

Output log to [Windows Event Log] or [Console] or [Text Log] and specify to supress or to output individually. 


�w�肵���T�[�r�X���N��,��~����v���O�����ł��B
(��~|�N��)�σT�[�r�X��(��~|�N��)�w�肷��ƌx���I�����܂��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B


.EXAMPLE
ChangeServiceStatus.ps1 -Service Spooler -TargetStatus Stopped -RetrySpanSec 5 -RetryTimes 5

Stop Windows serivice(Service Name:Spooler, Print Spooler)
If it dose not stop immediately, retry 5times every 5seconds.

If the service is stoped already, terminate as WARNING.

�T�[�r�X��:Spooler�i�\������Print Spooler�j���~���܂��B
�����ɒ�~���Ȃ��ꍇ�́A5�b�Ԋu�ōő�5�񎎍s���܂��B

��~�σT�[�r�X���~���悤�Ƃ����ꍇ�́A�x���I�����܂��B



.EXAMPLE
ChangeServiceStatus.ps1 -Service Spooler -TargetStatus Running -RetrySpanSec 5 -RetryTimes 5 -WarningAsNormal

Start Windows serivice(Service Name:Spooler, Display Name:Print Spooler)
If it dose not start immediately, retry 5times every 5seconds.

Specified -WarningAsNormal option and, if the service is started already, terminate as NORMAL.


�T�[�r�X��:Spooler�i�\������Print Spooler�j���N�����܂��B
�����ɋN�����Ȃ��ꍇ�́A5�b�Ԋu�ōő�5�񎎍s���܂��B

�N���σT�[�r�X���~���悤�Ƃ����ꍇ�́A����I�����܂��B



.PARAMETER Service
Specify Windows 'Service name'.  'Service name' is diffent from 'Display name'.
Sample
Serivce Name:Spooker
Display Name:Print Spooler
 
Specification is required.

�@(��~|�N��)����T�[�r�X�����w�肵�܂��B
�u�T�[�r�X���v�Ɓi�T�[�r�X�́j�u�\�����v�͈قȂ�܂��̂ŗ��ӂ��ĉ������B
�Ⴆ�΁u�\����:Print Spooler�v�́u�T�[�r�X��:Spooler�v�ƂȂ��Ă��܂��B
�w��K�{�ł��B

.PARAMETER TargetStatus
Specify target status (Stopped|Running) of the service.
Specification is required.

�J�ڂ���T�[�r�X��Ԃ��w�肵�܂��B
(Stopped|Running)�ǂ��炩���w�肵�ĉ������B
�w��K�{�ł��B

.PARAMETER RetrySpanSec
Specify interval to check service status.
Some services require long time to translate serivce status, specify appropriate value.
Default is 3seconds.


�@�T�[�r�X��~�Ċm�F�̊Ԋu�b�����w�肵�܂��B
�T�[�r�X�ɂ���Ă͐��b�K�v�Ȃ��̂�����̂œK�؂ȕb���ɐݒ肵�ĉ������B
�f�t�H���g��3�b�ł��B

.PARAMETER RetryTimes
Specify times to check service status.
Some services require long time to translate serivce status, specify appropriate value.
Default is 5times.

�@�T�[�r�X��~�Ċm�F�̉񐔂��w�肵�܂��B
�T�[�r�X�ɂ���Ă͐��b�K�v�Ȃ��̂�����̂œK�؂ȉ񐔂ɐݒ肵�ĉ������B
�f�t�H���g��5��ł��B





.PARAMETER Log2EventLog
�@Windows Event Log�ւ̏o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE��Event Log�o�͂��܂��B

.PARAMETER NoLog2EventLog
�@Event Log�o�͂�}�~���܂��B-Log2EventLog $FALSE�Ɠ����ł��B

.PARAMETER ProviderName
�@Windows Event Log�o�͂̃v���o�C�_�����w�肵�܂��B�f�t�H���g��[Infra]�ł��B

.PARAMETER EventLogLogName
�@Windows Event Log�o�͂̃��O�������Ă��܂��B�f�t�H���g��[Application]�ł��B

.PARAMETER Log2Console 
�@�R���\�[���ւ̃��O�o�͂𐧌䂵�܂��B
�f�t�H���g��$TRUE�ŃR���\�[���o�͂��܂��B

.PARAMETER NoLog2Console
�@�R���\�[�����O�o�͂�}�~���܂��B-Log2Console $FALSE�Ɠ����ł��B

.PARAMETER Log2File
�@���O�t�B���ւ̏o�͂𐧌䂵�܂��B�f�t�H���g��$FALSE�Ń��O�t�@�C���o�͂��܂���B

.PARAMETER NoLog2File
�@���O�t�@�C���o�͂�}�~���܂��B-Log2File $FALSE�Ɠ����ł��B

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


MICROSOFT LIMITED PUBLIC LICENSE version 1.1

.LINK

https://github.com/7k2mpa/FileMaintenace

#>

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
Param(

[parameter(position = 0, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter Service name (ex. spooler) To View all help , Get-Help StartService.ps1')]
[String][Alias("Name")]$Service ,

[parameter(position = 1, mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
[String][ValidateSet("Running", "Stopped")][Alias("Status")]$TargetStatus , 


#[String][parameter(position=1)][ValidateSet("Running", "Stopped")]$TargetStatus = 'Running', 
#[String][parameter(position=1)][ValidateSet("Running", "Stopped")]$TargetStatus = 'Stopped', 


[int][parameter(position=2)][ValidateRange(1,65535)]$RetrySpanSec = 3 ,
[int][parameter(position=3)][ValidateRange(1,65535)]$RetryTimes = 5 ,


[boolean]$Log2EventLog = $TRUE,
[Switch]$NoLog2EventLog,
[String]$ProviderName = "Infra",
[String][ValidateSet("Application")]$EventLogLogName = 'Application',

[boolean]$Log2Console = $TRUE,
[Switch]$NoLog2Console,
[boolean]$Log2File = $FALSE,
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
    Catch [Exception] {
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


    IF (-not($Service | Test-ServiceExist -NoMessage)) {
        Write-Log -Id $ErrorEventID -Type Error -Message "Service [$($Service)] dose not exist."
        Finalize $ErrorReturnCode
        }


     IF ($TargetStatus -notmatch '(Running|Stopped)') {
        Write-Log -Id $ErrorEventID -Type Error -Message "-TargetStatus [$($TargetStatus)] is invalid specification."
        Finalize $ErrorReturnCode   
        }


    IF ($Service | Test-ServiceStatus -Status $TargetStatus -Span 0 -UpTo 1 ) {
        Write-Log -Id $WarningEventID -Type Warning -Message "Service [$($Service)] status is already [$($TargetStatus)]"
        Finalize $WarningReturnCode
        }
        



#�����J�n���b�Z�[�W�o��


Write-Log -Id $InfoEventID -Type Information -Message "All parameters are valid."

Write-Log -Id $InfoEventID -Type Information -Message "Starting to switch Service [$($Service)] status."

}


function Finalize {

Param(
[parameter(mandatory)][int]$ReturnCode
)


 Invoke-PostFinalize $ReturnCode


}


#####################   ��������{��  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.1"

[String]$computer = "localhost" 
[String]$class = "win32_service" 
[Object]$WMIservice = Get-WMIobject -Class $class -computer $computer -filter "name = '$Service'" 


#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

. Initialize

 Switch -Regex ($TargetStatus) {
 
    'Stopped' {
        $originalStatus = 'Running'    
        }
    
    'Running' {
        $originalStatus = 'Stopped'
        }

    Default {
        Write-Log -Id $InternalErrorEventID -Type Error -Message 'Internal Error. $TargetStatus is invalid.'
        Finalize $InternalErrorReturnCode
        } 
 }



#�ȉ��̃R�[�h��MS�̃T���v�����Q�l
#MICROSOFT LIMITED PUBLIC LICENSE version 1.1
#https://gallery.technet.microsoft.com/scriptcenter/aa73bb75-38a6-4bd4-b72e-a6aede76d6ad
#https://devblogs.microsoft.com/scripting/hey-scripting-guy-how-can-i-use-windows-powershell-to-stop-services/

$result = $ErrorReturnCode

:ForLoop For ( $i = 0 ; $i -le $RetryTimes ; $i++ ) {

    # �T�[�r�X���݊m�F
    IF (-not($Service | Test-ServiceExist)) {
        Break
        }

    Write-Log -Id $InfoEventID -Type Information -Message "With WMIService.(start|stop)Service, starting to switch Service [$($Service)] status from [$($originalStatus)] to [$($TargetStatus)]"

Write-Debug (Get-Service | Where-Object {$_.Name -eq $Service}).Status

    Switch -Regex ($TargetStatus) {
 
        'Stopped' {
            IF ($WMIservice.AcceptStop) {
                $return = $WMIservice.stopService()

                } else {
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] will not accept a stop request. Wait for $($RetrySpanSec) seconds."
                Start-Sleep -Seconds $RetrySpanSec
                Continue ForLoop
                }
            }
    
        'Running' {

            #https://docs.microsoft.com/ja-jp/windows/win32/cimwin32prov/win32-service
            #[AcceptStart Class] dose not exist

            $return = $WMIservice.startService()
            }

        Default {
            Write-Log -Id $InternalErrorEventID -Type Error -Message 'Internal Error. $TargetStatus is invalid. '
            $result = $InternalErrorReturnCode
            Break ForLoop
            }
    }



    Switch ($return.returnvalue) {
        
            0 {
                $serviceStatus = $Service | Test-ServiceStatus -Status $TargetStatus -Span $RetrySpanSec -UpTo $RetryTimes

                IF ($serviceStatus) {
                    Write-Log -Id $SuccessEventID -Type Success -Message "Service [$($Service)] is [$($TargetStatus)]"
                    $result = $NormalReturnCode
                    Break ForLoop

                    } else {
                    Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] is not [$($TargetStatus)]"
                    }
                }

            2 {
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] reports access denied."
                }

            5 { 
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] can not accept control at this time."
                } 
            
            10 {
                Write-Log -Id $WarningEventID -Type Warning -Message "Service [$($Service)] is already [$($TargetStatus)]"
                $result = $WarningErrorCode
                Break ForLoop
                }
              
            DEFAULT {
                Write-Log -Id $InfoEventID -Type Information -Message "Service [$($Service)] reports ERROR $($Return.returnValue)"
                } 
    }  
    
    IF ($i -ge $RetryTimes) {
        Write-Log -Id $ErrorEventID -Type Error -Message "Although retry specified times, service [$($Service)] status is not switched to [$($TargetStatus)]"
        Break
        }

      #�`�F�b�N�񐔂̏���ɒB���Ă��Ȃ��ꍇ�́A�w��b�ҋ@

      Write-Log -Id $InfoEventID -Type Information -Message ("Serivce [$($Service)] exists and service status dose not switch to [$($TargetStatus)] " +
        "Wait for $($RetrySpanSec) seconds. Retry [" + ($i+1) + "/$RetryTimes]")
      Start-Sleep -Seconds $RetrySpanSec
}

Finalize $result
