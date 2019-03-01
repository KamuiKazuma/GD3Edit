@ECHO OFF

IF EXIST ".\compile-mod.bat" (
	CALL ".\compile-mod.bat" ".\Mod\filenameinfo.bas" ".\Mod\filenameinfo.o" ".\filenameinfo.o"
	CALL ".\compile-mod.bat" ".\Mod\options.bas" ".\Mod\options.o" ".\options.o"
	CALL ".\compile-mod.bat" ".\Mod\vgmhead.bas" ".\Mod\vgmhead.o" ".\vgmhead.o"
	GOTO EOF
) ELSE (
	SET ERRORLEVEL=4
	GOTO EOF
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