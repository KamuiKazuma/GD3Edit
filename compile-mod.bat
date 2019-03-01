@ECHO OFF

REM ERRORLEVEL output values:
REM 0 = No Error
REM 1 = Source file not found
REM 2 = Output file not found
REM 3 = Output folder not found

REM Syntax:
REM compile-mod[.bat] <source file> <output file> <output folder>
REM <source file> - The file to compile
REM <output file> - The output (*.o) file
REM <output folder>	- The file to move the compiled output file to.

ECHO.
ECHO %~0
ECHO FreeBASIC Module Compiler Tool v1.2
ECHO.

IF EXIST %~f1 (
	
	REM Compile module source file
	IF DEFINED FBDEBUG (
		fbc -c -g %~f1
	) ELSE (
		fbc -c %~f1
	)
	
	REM Make sure output file exists
	IF EXIST %~f2 (
		
		REM Move output file to output folder
		IF EXIST %~dp3 (
			ECHO Moving %~f2 to %~dp3.
			MOVE %~f2 %~dp3
		) ELSE (
			SET ERRORLEVEL=3
			GOTO ERR
		)
	) ELSE (
		SET ERRORLEVEL=2
		GOTO ERR
	)
	
	SET ERRORLEVEL=0
	GOTO EOF
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Error handler
:ERR
IF NOT ERRORLEVEL 0 (
	ECHO.
	ECHO %~0 ERROR (%ERRORLEVEL%):
	GOTO ERR%ERRORLEVEL%
) ELSE (
	GOTO EOF
)

:ERR1
ECHO Source file %~f1 not found.
GOTO EOF

:ERR2
ECHO Output file %~f2 not found.
GOTO EOF

:ERR3
ECHO Output folder %~f3 not found.
GOTO EOF

:ERR4
ECHO Compile script not found.
GOTO EOF

:EOF