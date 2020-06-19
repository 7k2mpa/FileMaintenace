@echo off

rem ========================================================
rem This scprit writes Windows Event Log
rem Before calling MSGPRINT.bat, set variable MYSELF_NAME 
rem with the script's name which calls MSGPRINT.bat
rem
rem Usage
rem call MSGPRINT [message to output] [INFORMATION|WARNING|ERROR] [ID 1-1000]
rem
rem sample ID number
rem INFORMATION	1
rem WARNING 10
rem ERROR 100
rem ========================================================

rem validate the number of the arguments

set argc=0

for %%a in ( %* ) do set /a argc=argc+1

if not %argc% == 3 (
	eventcreate /L Application /T WARNING /SO Infra /D "[%MYSELF_NAME%]invalid numbers of arguments" /ID 99
  	exit /b 1
	)

eventcreate /L Application /T "%2" /SO Infra /D [%MYSELF_NAME%]%1 /ID %3

exit /b

