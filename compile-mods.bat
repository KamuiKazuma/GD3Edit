@ECHO OFF

IF EXIST ".\compile-mod.bat" (
	CALL ".\compile-mod.bat" ".\Mod\filenameinfo.bas" ".\Mod\filenameinfo.o" ".\filenameinfo.o"
	CALL ".\compile-mod.bat" ".\Mod\vgmhead.bas" ".\Mod\vgmhead.o" ".\vgmhead.o"
	GOTO EOF
) ELSE (
	SET ERRORLEVEL=3
	GOTO EOF
)

:EOF