@echo off

rem ---- Script Directory ----
set SC_DIR=%~dp0
set Myself_name=%~nx0

cd /D %SC_DIR%

set P_NAME=FileMaintenance.ps1

powershell -Noninteractive -Command ".\%P_NAME% -TargetFolder .\Lock -Action Delete ; exit $LASTEXITCODE"

	IF %errorlevel%==8 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated with an Error. Error LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)

exit /B

:ERR

exit /B 100