@ECHO OFF

REM ERRORLEVEL output values:
REM 0 = No Error
REM 1 = Source file not found
REM 2 = Output file not found
REM 3 = Output folder not found
REM 4 = Compile script not found

REM Compile static libraries
IF EXIST ".\compile-libs.bat" (
	CALL ".\compile-libs.bat"
) ELSE (
	SET ERRORLEVEL=4
	GOTO ERR
)

REM Compile modules
IF EXIST ".\compile-mods.bat" (
	CALL ".\compile-mods.bat"
) ELSE (
	SET ERRORLEVEL=4
	GOTO ERR
)

REM Compile resource file
IF EXIST ".\resource.rc" (
	GoRC /r /nu ".\resource.rc"
	
	REM Make sure output file exists
	IF NOT EXIST ".\resource.res" (
		SET ERRORLEVEL=2
		GOTO ERR
	)
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Compile main module
IF EXIST ".\main.bas" (
	IF DEFINED FBDEBUG (
		fbc -g ".\main.bas" ".\*.o" ".\resource.res" -x ".\GD3Edit.exe"
	) ELSE (
		fbc -s gui ".\main.bas" ".\*.o" ".\resource.res" -x ".\GD3Edit.exe"
	)
	
	REM Make sure the output file exists
	IF NOT EXIST ".\GD3Edit.exe" (
		SET ERRORLEVEL=2
		GOTO ERR
	)
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

SET ERRORLEVEL=0
GOTO EOF

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