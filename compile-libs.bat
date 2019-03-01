@ECHO OFF

IF EXIST ".\compile-lib.bat" (
	CALL ".\compile-lib.bat" ".\Mod\CreateToolTip\CreateToolTip.bas" ".\Mod\CreateToolTip\libCreateToolTip.a" ".\libCreateToolTip.a"
	CALL ".\compile-lib.bat" ".\Mod\ErrMsgBox\ErrMsgBox.bas" ".\Mod\CreateToolTip\libErrMsgBox.a" ".\libErrMsgBox.a"
	CALL ".\compile-lib.bat" ".\Mod\HeapPtrList\HeapPtrList.bas" ".\Mod\HeapPtrList\libHeapPtrList.a" ".\libHeapPtrList.a"
	SET ERRORLEVEL=0
	GOTO EOF
) ELSE (
	SET ERRORLEVEL=3
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