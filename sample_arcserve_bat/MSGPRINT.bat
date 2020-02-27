@echo off

rem ========================================================
rem メッセージ出力
rem バッチを実行しているコンピュータのWindows Event Logを出力
rem 変数MYSELF_NAMEは呼び出し元で実行バッチ名を取得して、実行バッチ名を入力しておく
rem call MSGPRINT [出力するメッセージ] [INFORMATION|WARNING|ERROR] [ID 1-1000までの範囲]
rem IDの目安
rem INFORMATION	1
rem WARNING 10
rem ERROR 100
rem ========================================================

rem 引数確認
set argc=0

for %%a in ( %* ) do set /a argc=argc+1
if not %argc% == 3 (
rem 引数個数違い
	eventcreate /L Application /T WARNING /SO Infra /D %MYSELF_NAME%＝エラー処理の引数個数が違います。 /ID 99
  	exit /b 1
)

eventcreate /L Application /T "%2" /SO Infra /D %MYSELF_NAME%＝%1 /ID %3

exit /b

