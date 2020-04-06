@echo off

rem ---- Script Directory ----
set SC_DIR=%~dp0
set Myself_name=%~nx0

cd /D %SC_DIR%


set P_NAME=OracleDB2NormalMode.ps1

powershell -Noninteractive -Command ".\%P_NAME% ; exit $LASTEXITCODE"

	IF %errorlevel%==8 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)


set P_NAME=OracleDeleteArchiveLog.ps1

powershell -Noninteractive -Command ".\%P_NAME% -Days 1 ; exit $LASTEXITCODE"

	IF %errorlevel%==8 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)


set P_NAME=Wrapper.ps1

powershell -Noninteractive -Command ".\%P_NAME% -CommandPath .\FileMaintenance.ps1 -CommandFile .\Config\Command.txt ; exit $LASTEXITCODE"

	IF %errorlevel%==8 (
		call %SC_DIR%MSGPRINT.bat "%P_NAME% terminated as Error Erro LevelÅÅ%errorlevel%" ERROR 100
		goto :ERR
		)


#set P_NAME=LoopWrapper.ps1

#powershell -Noninteractive -Command ".\%P_NAME% -CommandPath .\CheckFlag.ps1 -CommandFile .\Config\LoopWrapperCommand.txt ; exit $LASTEXITCODE"

#	IF %errorlevel%==1 (
#		set P_NAME=FileMaintenance.ps1
#		powershell -Noninteractive -Command ".\FileMaintenance.ps1 -TargetFolder .\Lock -Action Delete ; exit $LASTEXITCODE"
#		)

exit /B

:ERR

exit /B 100