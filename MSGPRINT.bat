@echo off

rem ========================================================
rem ���b�Z�[�W�o��
rem �o�b�`�����s���Ă���R���s���[�^��Windows Event Log���o��
rem �ϐ�MYSELF_NAME�͌Ăяo�����Ŏ��s�o�b�`�����擾���āA���s�o�b�`������͂��Ă���
rem call MSGPRINT [�o�͂��郁�b�Z�[�W] [INFORMATION|WARNING|ERROR] [ID 1-1000�܂ł͈̔�]
rem ID�̖ڈ�
rem INFORMATION	1
rem WARNING 10
rem ERROR 100
rem ========================================================

rem �����m�F
set argc=0

for %%a in ( %* ) do set /a argc=argc+1
if not %argc% == 3 (
rem �������Ⴂ
	eventcreate /L Application /T WARNING /SO Infra /D %MYSELF_NAME%���G���[�����̈��������Ⴂ�܂��B /ID 99
  	exit /b 1
)

eventcreate /L Application /T "%2" /SO Infra /D %MYSELF_NAME%��%1 /ID %3

exit /b

