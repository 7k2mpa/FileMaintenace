#Requires -Version 3.0

<#
.SYNOPSIS
This script start arcserve UDP backup job with arcserve UDP CLI.
CommonFunctions.ps1 is required.

arcserveUDP ver.6�ȍ~�Ŏ������ꂽCLI�o�R�Ńo�b�N�A�b�v�W���u���N������v���O�����ł��B
���s�ɂ�CommonFunctions.ps1���K�v�ł��B

<Common Parameters>�̓T�|�[�g���Ă��܂���

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


arcserveUDP CLI�o�R�Ńo�b�N�A�b�v�W���u���N������v���O�����ł��B
�o�b�N�A�b�v�̓t���o�b�N�A�b�v�A�����o�b�N�A�b�v��I���ł��܂��B
�F�؂̓p�X���[�h�����A�p�X���[�h�t�@�C���A�������T�|�[�g���Ă��܂��B
�p�X���[�h�t�@�C����p����ꍇ�A���s���[�U�̓p�X���[�h���쐬�������[�U�Ɠ���ɂ���K�v������܂��B�����WindowsOS�̎d�l�ł��B
�Ⴆ�ΐݒ�t�@�C����$ExecUser��'arcserve'�Ƃ��A�v���O���������s���Ă��郆�[�U���قȂ�ꍇ�̓p�X���[�h�t�@�C����'arcserve'���[�U�ō쐬���Ă��F�؂��鎖�͏o���܂���B
�W���u�X�P�W���[�����Ŏ��s���鎞�̃��[�U��'arcserve'�Ƃ��Ď��s���ĉ������B

���̃v���O�����ƃo�b�N�A�b�v�R���\�[���T�[�o�Ƃ͓���܂��͈قȂ�z�X�g�A�������T�|�[�g���Ă��܂��B
�o�b�N�A�b�v�R���\�[����CPU�R�A���̑����o�b�N�A�b�v�T�[�o�ɓ��ڂ����ꍇ�A��ʂ̃W���u�X�P�W���[�����C�Z���X���K�v�ł����A�قȂ�z�X�g�ɓ��v���O������z�u���鎖�Ń��C�Z���X��ߖ�\�ł��B

���O�o�͐��[Windows EventLog][�R���\�[��][���O�t�@�C��]���I���\�ł��B���ꂼ��o�́A�}�~���w��ł��܂��B

�t�@�C���z�u��

D:\script\infra\arcserveUDPBackUp.ps1
D:\script\infra\Log\backup.flg
D:\script\infra\UDP.psw




---



.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -Server SVDB01 -BackUpJobType Incr

Start incremental backup targeting server [SVDB] in the plan [SSDB] 

arcserveUDP�̃o�b�N�A�b�v�v����[SSDB]�Ɋ܂܂��A�T�[�o[SVDB01]�������o�b�N�A�b�v�N�����܂��B

.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -AllServers -BackUpJobType Full -UDPConsoleServerName BKUPSV01.corp.local

Start full backup targeting all servers in the plan [SSDB]
and specify arcserve UDP console BKUPSV01.corp.local 

arcserveUDP�̃o�b�N�A�b�v�v����[SSDB]�Ɋ܂܂��A�S�ẴT�[�o���t���o�b�N�A�b�v�N�����܂��B
arcserveUDP�̃R���\�[���T�[�o��BKUPSV01.corp.local���w�肵�܂��B

.EXAMPLE



arcserveUDPBackUp.ps1 -Plan SSDB -Server SVDB02 -BackUpJobType Incr -AuthorizationType PlainText -ExecUser = 'arcserve' -ExecUserDomain = 'INTRA' -ExecUserPassword = 'hogehoge'

Start incremental backup targeting server[SVDB02] in the plan [SSDB] 
with plain password.
Specify execution backup domain user [INTRA\arcserve] password [hogehoge]
You can specify other user from running the script, but you shoud not use plain pssword for security reason.

arcserveUDP�̃o�b�N�A�b�v�v����[SSDB]�Ɋ܂܂��A�T�[�o[SVDB02]�������o�b�N�A�b�v�N�����܂��B
�F�ؕ����͕����p�X���[�h�Ƃ��܂��B
�o�b�N�A�b�v�R���\�[���T�[�o�̊Ǘ����[�U�̓h���C�����[�UINTRA\arcserve�A�p�X���[�h��hogehoge���w�肵�܂��B
�F�ؕ����𕽕��p�X���[�h�Ƃ����ꍇ�A���̃v���O���������s���Ă��郆�[�U�ƈقȂ郆�[�U���w�肷�鎖���o���܂��B


.EXAMPLE

arcserveUDPBackUp.ps1 -Plan SSDB -AllServers -BackUpJobType Full -AuthorizationType JobExecUserAndPasswordFile -ExecUserPasswordFilePath '.\UDP.psw'

Start full backup targeting all servers in the plan [SSDB] 
Autorization style is execution user of the script and password file.
You need to make password file in the same user of executing the script.
Password file name is set with the user name automatically.
'_[username]' is added to the filename to load.
If you specify '.\UDP.psw' and execution user is 'Domain\arcserve' , this script load the password file '.\UDP_arcserve.psw'

arcserveUDP�̃o�b�N�A�b�v�v����[SSDB]�Ɋ܂܂��A�S�ẴT�[�o���t���o�b�N�A�b�v�N�����܂��B
�F�ؕ����̓W���u���s���[�U�ƃp�X���[�h�t�@�C���Ƃ��܂��B�W���u���s���[�U�Ńo�b�N�A�b�v�R���\�[���T�[�o�Ƀ��O�I�����܂��B
���̎��̃p�X���[�h�͗\�߃W���u���s���[�U�̃p�X���[�h�t�@�C�����쐬���Ă����K�v������܂��B
�p�X���[�h�t�@�C���͎w�肵���t�@�C����UDP.psw�������ϊ����܂��B
���̃v���O���������s���郆�[�U��Domain\arcserve�̎��ɂ́A�t�@�C�����{�̂ɃA���_�[�X�R�A'_'�ɑ����ă��[�U��[arcserve]�������I�ɕt�������t�@�C����UDP_arcserve.psw��ǂݍ��݁A�p�X���[�h�t�@�C���Ƃ��Ďg�p���܂��B


.PARAMETER Plan
Specify the plan in arcserve UDP.
Specification is required.
Wild card dose not be accepted.

arcserveUDP�ɓo�^���Ă���v���������w�肵�܂��B
�w��͕K�{�ł��B

���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER Server
Specify one server name in the -Plan option.
Can not specify a server name not in the plan.
Wild card dose not be accepted.

arcserveUDP�ɓo�^���Ă���v�����Ɋ܂܂��T�[�o����1�䕪�w�肵�܂��B
�v�����Ɋ܂܂�Ȃ��T�[�o�͎w��ł��܂���B
���C���h�J�[�h*�͎g�p�ł��܂���B

.PARAMETER AllServers
If you want specify all servers in the plan.

arcserveUDP�ɓo�^���Ă���v�����Ɋ܂܂��T�[�o�S�Ă��o�b�N�A�b�v�Ώۂɂ��܂��B

.PARAMETER BackUpJobType
Specify back up type.
Full:Full BackUp
Incr:Incremental BackUp

�Ώۂ̃o�b�N�A�b�v���������Ă��܂��B

Full:�t���o�b�N�A�b�v
Incr:�����o�b�N�A�b�v




.PARAMETER BackupFlagFilePath
Specify lock file path of back up status.
This script generete and save flag file with plan name and server name added.
If specify -AllServers option, file name be with 'All'

�o�b�N�A�b�v���������o�b�N�A�b�v�t�@�C���̕ۑ���p�X���w�肵�܂��B
�t�@�C����.�g���q�Ŏw�肵�܂����A�t�@�C�����Ɏ����I��_Plan��_�o�b�N�A�b�v�ΏۃT�[�o����t�������t�@�C�����ŕۑ����܂��B
AllServers���w�肵���ꍇ�A�o�b�N�A�b�v�T�[�o����All�ƂȂ�܂��B


.PARAMETER PROTOCOL

Specify protocol to logon to arcserve UDP console server.
http or https are allowed.
[http] is default.

arcserveUDP�R���\�[���T�[�o�Ƀ��O�I�����鎞�̃v���g�R�����w�肵�܂��B
http / https���w�肵�Ă��������B
�f�t�H���g��http�ł��B

.PARAMETER UDPConsolePort

Specify port number to logon to arcserve UDP console server.
[8015] is default.

arcserveUDP�R���\�[���T�[�o�Ƀ��O�I�����鎞�̒ʐM�|�[�g�ԍ����w�肵�܂��B
�f�t�H���g��8015�ł��B


.PARAMETER UDPCLIPath

Specify arcserve UDP CLI folder path.
Relative or absolute path format is allowed.

arcserveUDP CLI���z�u���ꂽ�p�X���w�肵�܂��B
���΁A��΃p�X�Ŏw��\�ł��B


.PARAMETER AuthorizationType

Specify authorization type to logon to the arcserve UDP console server.

JobExecUserAndPasswordFile:script execution user / password file(user name is added to the file name )
FixedPasswordFile:fixed user / password file
PlanText:fixed user / plain password string

arcserveUDP�R���\�[���T�[�o�Ƀ��O�I������F�ؕ������w�肵�܂��B

JobExecUserAndPasswordFile:�{�v���O���������s���Ă��郆�[�U / �{�v���O���������s���Ă��郆�[�U�����܂ރp�X���[�h�t�@�C��
FixedPasswordFile:�w�肵�����[�U / �w�肵���p�X���[�h�t�@�C��
PlanText:�w�肵�����[�U / �����p�X���[�h

.PARAMETER ExecUser

Specify OS user to logon to the arcserve UDP console in authorization type PlainText or FixedPasswordFile.
If domain user runs the script, you specify user name without domain name.

Sample:FooDOMAIN\BarUSER , specify -ExecUser BarUSER

�F�ؕ�����PlainText , FixedPasswordFile�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I����OS���[�U�����w�肵�܂��B
�h���C�����[�U�̏ꍇ�A�h���C�������������������̂��w�肵�Ă��������B

��:FooDOMAIN\BarUSER�ł���΁ABarUSER


.PARAMETER ExecUserDomain

Specify OS user's domain to logon to the arcserve UDP console in authorization type PlainText or FixedPasswordFile.

Sample:FooDOMAIN\BarUSER , specify -ExecDomain FooDOMAIN


�F�ؕ�����PlainText , FixedPasswordFile�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I��OS���[�U�̃h���C�������w�肵�܂��B

��:FooDOMAIN\BarUSER�ł���΁AFooDOMAIN

.PARAMETER ExecUserPassword
�F�ؕ�����PlainText�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I��OS���[�U�̃p�X���[�h�𕽕��Ŏw�肵�܂��B


.PARAMETER FixedPasswordFilePath
Specify password file path in authorization style [FixedPasswordFile] to logon to the arcserve UDP console.

�F�ؕ�����FixedPasswordFile�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I��OS���[�U�̃p�X���[�h�t�@�C�����w�肵�܂��B



.PARAMETER ExecUserPasswordFilePath

Specify password file path in authorization style [JobExecUserAndPasswordFile] to logon to the arcserve UDP console.

Sample:'.\UDP.psw' , script running user FooDOMAIN\BarUSER
password file '.UDP_BarUSER.psw' will be loaded automatically.

_ and script running user name is inserted to the path specificated.

�F�ؕ�����JobExecUserAndPasswordFile�Ƃ�������arcserveUDP�R���\�[���T�[�o���O�I��OS���[�U�̃p�X���[�h�t�@�C���p�X���w�肵�܂��B

��:'.\UDP.psw' , �{�v���O���������s���Ă��郆�[�U��FooDOMAIN\BarUSER
'.UDP_BarUSER.psw'���p�X���[�h�t�@�C���Ƃ��Ďw�肳��܂��B
�A���_�[�X�R�A_�ȍ~�̕����͎��s���Ă��郆�[�U���������I�ɑ}������܂��B


.PARAMETER UDPConsoleServerName

Specify arcserve UDP console server's host name or IP address.

arcserveUDP�R���\�[���T�[�o�̃z�X�g���AIP�A�h���X���w�肵�܂��B



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

    IF (-not($AllServers)) {

        $Server | Test-Hostname -ObjectName 'BackUp target -Server' -IfInvalidFinalize > $NULL
        }

    $UDPConsoleServerName | Test-Hostname -ObjectName 'arcserveUDP Console Server -UDPConsoleServerName' -IfInvalidFinalize > $NULL

#[String][ValidateSet("JobExecUserAndPasswordFile","FixedPasswordFile" , "PlanText")]$AuthorizationType = 'JobExecUserAndPasswordFile' ,


    IF ($AuthorizationType -match '^(FixedPasswordFile|PlainText)$' ) {

        $ExecUserDomain | Test-DomainName -ObjectName 'The domain of execution user -ExecUserDomain' -IfInvalidFinalize > $NULL    
        $ExecUser | Test-UserName -ObjectName 'Execution user -ExecUser ' -IfInvalidFinalize > $NULL

        }

#UDPConsole�̑��݂��m�F

    IF (Test-Connection -ComputerName $UDPConsoleServerName -Quiet) {
    
        Write-Log -EventID $SuccessEventID -EventType Success -EventMessage "UDP Console Server [$($UDPConsoleServerName)] responsed."

        } else {
        Write-Log -EventID $ErrorEventID -EventType Error -EventMessage "UDP Console Server [$($UDPConsoleServerName)] did not response. Check -UDPConsoleServerName"
        Finalize $ErrorReturnCode
        }


#Password File�̗L�����m�F

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


#arcserveUDP CLI�̗L�����m�F
    

    $UDPCLIPath = $UDPCLIPath | ConvertTo-AbsolutePath -Name 'arcserveUDP CLI -UDPCLIPath'

    $UDPCLIPath | Test-Leaf -Name 'arcserveUDP CLI -UDPCLIPath' -IfNoExistFinalize > $NULL



#�����J�n���b�Z�[�W�o��


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



#####################   ��������{��  ######################

$DatumPath = $PSScriptRoot

$Version = "2.0.0-RC.2"
 
 
#�����ݒ�A�p�����[�^�m�F�A�N�����b�Z�[�W�o��

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
        #���̂Ƃ���A���̔F�ؕ�����arcserve UDP�ł͏o���Ȃ��B���s���[�U�������������Ă��Ă�(�p�X���[�h�t�@�C��|�p�X���[�h)��^����K�v������
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
