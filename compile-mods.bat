@ECHO OFF

IF EXIST ".\compile-mod.bat" (
	CALL ".\compile-mod.bat" ".\Mod\config.bas" ".\Mod\config.o" ".\config.o"
	CALL ".\compile-mod.bat" ".\Mod\filenameinfo.bas" ".\Mod\filenameinfo.o" ".\filenameinfo.o"
	GOTO EOF
) ELSE (
	SET ERRORLEVEL=3
	GOTO EOF
)

:EOF