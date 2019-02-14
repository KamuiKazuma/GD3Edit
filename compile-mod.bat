@ECHO OFF

REM ERRORLEVEL ouput values:
REM 0 = No Error
REM 1 = Source file not found
REM 2 = Output file not found
REM 3 = Output folder not found

IF EXIST %~f1 (
	IF DEFINED FBDEBUG (
		fbc -c -g %~f1
	) ELSE (
		fbc -c %~f1
	)
	
	IF EXIST %~f2 (
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
	GOTO EOF
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Error handler
:ERR
IF NOT ERRORLEVEL 0 (
	ECHO.
	GOTO ERR%ERRORLEVEL%
) ELSE (
	GOTO EOF
)

:ERR1
ECHO %~0 ERROR: Source file %~f1 not found.
GOTO EOF

:ERR2
ECHO %~0 ERROR: Output file %~f2 not found.
GOTO EOF

:ERR3
ECHO %~0 ERROR: Output folder %~f3 not found.
GOTO EOF

:EOF