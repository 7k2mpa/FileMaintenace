@echo off

rem ---- スクリプトディレクトリ ----
set SC_DIR=%~dp0
set Myself_name=%~nx0


D:

cd D:\Scripts\Infra


set P_NAME=OracleDB2NormalMode.ps1


powershell -Noninteractive -Command ".\OracleDB2NormalMode.ps1 -OracleService SSDBT ; exit $LASTEXITCODE"

	IF %errorlevel%==8 (
	call %SC_DIR%MSGPRINT.bat %P_NAME%が異常終了しました。エラーレベル＝%errorlevel% ERROR 100
	goto :ERR
	)


set P_NAME=OracleDeleteArchiveLog.ps1

powershell -Noninteractive -Command ".\OracleDeleteArchiveLog.ps1 -OracleService SSDBT -Days 1 ; exit $LASTEXITCODE"


	IF %errorlevel%==8 (
	call %SC_DIR%MSGPRINT.bat %P_NAME%が異常終了しました。エラーレベル＝%errorlevel% ERROR 100
	goto :ERR
	)



set P_NAME=Wrapper.ps1

powershell -Noninteractive -Command ".\Wrapper.ps1 -CommandPath .\FileMaintenance.ps1 -CommandFile .\Config\Command.txt ; exit $LASTEXITCODE"


	IF %errorlevel%==8 (
	call %SC_DIR%MSGPRINT.bat %P_NAME%が異常終了しました。エラーレベル＝%errorlevel% ERROR 100
	goto :ERR

)



exit /B

:ERR

exit /B 100