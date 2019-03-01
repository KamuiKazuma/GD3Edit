@ECHO OFF

REM ERRORLEVEL output values:
REM 0 = No Error
REM 1 = Source file not found
REM 2 = Output file not found

REM Syntax:
REM compile-lib[.bat] <source file> <output file> <output folder>
REM <source file> - The file to compile
REM <output file> - The output (*.a) file
REM <output folder>	- The file to move the compiled output file to.

REM Parameters:
REM %0 = File name
REM %1 = Source file
REM %2 = Output file

ECHO.
ECHO %~0
ECHO FreeBASIC Static Library Compiler Tool v1.3.2
ECHO.

REM compile library source file if it exists
IF EXIST %~f1 (
	
	REM Compile source file
	IF DEFINED FBDEBUG (
		fbc -lib -g %~f1 -x %~f2
	) ELSE (
		fbc -lib %~f1 -x %~f2
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