@echo off

rem ---- �X�N���v�g�f�B���N�g�� ----
set SC_DIR=%~dp0
set Myself_name=%~nx0

D:

cd D:\Scripts\Infra


set P_NAME=FileMaintenance.ps1

powershell -Noninteractive -Command ".\FileMaintenance.ps1 -TargetFolder .\Lock -RegularExpression '^BkupDB.flg$' -Action Delete ; exit $LASTEXITCODE"



	IF %errorlevel%==8 (
	call %SC_DIR%MSGPRINT.bat %P_NAME%���ُ�I�����܂����B�G���[���x����%errorlevel% ERROR 100
	goto :ERR

)



exit /B

:ERR

exit /B 100