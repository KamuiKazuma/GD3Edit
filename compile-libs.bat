@ECHO OFF

IF EXIST ".\compile-lib.bat" (
	CALL ".\compile-lib.bat" ".\Mod\CreateToolTip\CreateToolTip.bas" ".\libCreateToolTip.a"
	CALL ".\compile-lib.bat" ".\Mod\ErrMsgBox\ErrMsgBox.bas" ".\libErrMsgBox.a"
	CALL ".\compile-lib.bat" ".\Mod\HeapPtrList\HeapPtrList.bas" ".\libHeapPtrList.a"
	SET ERRORLEVEL=0
	GOTO EOF
) ELSE (
	SET ERRORLEVEL=3
	GOTO EOF
)

:EOF
