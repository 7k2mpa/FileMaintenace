@echo off

rem ========================================================
rem �\�[�X��o�^����̂ŁA1�񂾂��Ǘ��Ҍ����Ŏ��s���邱��
rem �o�^��͋N���s�v
rem To register event source, execute with administrator priviledge once.
rem After registration, no need to execute this script.
rem ========================================================

eventcreate /L Application /T INFORMATION /SO Infra /ID 1000 /D "regist a new source in event log"

pause

exit /b

