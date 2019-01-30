@ECHO OFF

REM ERRORLEVEL ouput values:
REM 0 = No Error
REM 1 = Source file not found
REM 2 = Output file not found

ECHO compile-module.bat
ECHO FreeBASIC Static Library Compiler Tool
ECHO v1.2.0
ECHO.

REM compile module if it exists
IF EXIST %~f1 (
	IF DEFINED FBDEBUG (
		fbc -g -lib %~f1 -x %~f2
	) ELSE (
		fbc -lib %~f1 -x %~f2
	)
	SET ERRORLEVEL=0
) ELSE (
	SET ERRORLEVEL=1
	GOTO EOF
)

IF EXIST %~f2 (
	MOVE %~f2 %3
	SET ERRORLEVEL=0
) ELSE (
	SET ERRORLEVEL=2
)

:EOF
