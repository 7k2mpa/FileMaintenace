@echo off

rem ---- Script Directory ----
set SC_DIR=%~dp0
set Myself_name=%~nx0

cd /D %SC_DIR%


set P_NAME=CheckFlag.ps1

powershell -Noninteractive -Command ".\CheckFlag.ps1 -FlagFolder .\Lock -FlagFile BkupDB.flg ; exit $LASTEXITCODE"

	IF not %errorlevel%==0 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error. Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)


set P_NAME=OracleDB2BackUpMode.ps1


powershell -Noninteractive -Command ".\OracleDB2BackUpMode.ps1 -NoChangeToBackUpMode ; exit $LASTEXITCODE"

	IF %errorlevel%==8 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error. Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)


set P_NAME=CheckFlag.ps1

powershell -Noninteractive -Command ".\CheckFlag.ps1 -FlagFolder .\Lock -FlagFile BkupDB.flg -CreateFlag ; exit $LASTEXITCODE"

	IF not %errorlevel%==0 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error. Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)

exit /B

:ERR

exit /B 100