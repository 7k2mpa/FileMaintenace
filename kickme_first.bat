@echo off

rem ========================================================
rem ソースを登録するので、1回だけ管理者権限で実行すること
rem 登録後は起動不要
rem To register event source, execute with administrator priviledge once.
rem After registration, no need to execute this script.
rem ========================================================

eventcreate /L Application /T INFORMATION /SO Infra /ID 1000 /D "regist a new source in event log"

pause

exit /b

