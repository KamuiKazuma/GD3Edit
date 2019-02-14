@ECHO OFF

REM ERRORLEVEL ouput values:
REM 0 = No Error
REM 1 = Source file not found
REM 2 = Output file not found
REM 3 = Compile Script not found

REM Compile static libraries
IF EXIST ".\combile-libs.bat" (
	CALL ".\combile-libs.bat"
) ELSE (
	SET ERRORLEVEL=3
	GOTO ERR
)


REM Compile resource file
IF EXIST ".\resource.rc" (
	GoRC /r /nu ".\resource.rc"
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
		fbc -g ".\main.bas" ".\resource.res" -x ".\GD3Edit.exe"
	) ELSE (
		fbc -s gui ".\main.bas" ".\resource.res" -x ".\GD3Edit.exe"
	)
	IF EXIST ".\GD3Edit.exe" (
		IF EXIST ".\clean-up.bat" (
			CALL ".\clean-up.bat"
		) ELSE (
			SET ERRORLEVEL=3
			GOTO ERR
		)
	) ELSE (
		SET ERRORLEVEL=2
		GOTO ERR
	)
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

SET ERRORLEVEL=0
GOTO EOF

:ERR
ECHO.
ECHO %~0 ERROR: %ERRORLEVEL%

:EOF
