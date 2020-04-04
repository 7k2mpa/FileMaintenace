@echo off

rem ---- Script Directory ----
set SC_DIR=%~dp0
set Myself_name=%~nx0

cd /D %SC_DIR%


set P_NAME=CheckFlag.ps1

powershell -Noninteractive -Command ".\%P_NAME% -FlagFolder .\Lock -FlagFile BkupDB.flg  -Status NoExist ; exit $LASTEXITCODE"

	IF not %errorlevel%==0 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error. Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)


set P_NAME=OracleDB2BackUpMode.ps1


powershell -Noninteractive -Command ".\%P_NAME% -NoChangeToBackUpMode ; exit $LASTEXITCODE"

	IF %errorlevel%==8 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error. Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)


set P_NAME=CheckFlag.ps1

powershell -Noninteractive -Command ".\%P_NAME% -FlagFolder .\Lock -FlagFile BkupDB.flg -Status NoExist -PostAction Create ; exit $LASTEXITCODE"

	IF not %errorlevel%==0 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error. Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)

exit /B

:ERR

exit /B 100