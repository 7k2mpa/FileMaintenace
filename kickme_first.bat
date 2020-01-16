@echo off

rem ========================================================
rem ソースを登録するので、1回だけ管理者権限で実行すること
rem 登録後は起動不要
rem ========================================================



eventcreate /L Application /T INFORMATION /SO Infra /ID 1000 /D ソースにInfraを登録しました。

exit /b

