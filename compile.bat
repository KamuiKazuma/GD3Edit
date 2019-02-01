@ECHO OFF

REM ERRORLEVEL ouput values:
REM 0 = No Error
REM 1 = Source file not found
REM 2 = Output file not found
REM 3 = Compile Script not found

REM Compile modules
IF EXIST ".\compile-module.bat" (
	CALL ".\compile-module.bat" ".\Mod\CreateToolTip\CreateToolTip.bas" ".\Mod\CreateToolTip\libCreateToolTip.a"
	IF NOT ERRORLEVEL 0 GOTO ERR
	CALL ".\compile-module.bat" ".\Mod\ErrMsgBox\ErrMsgBox.bas" ".\Mod\ErrMsgBox\libErrMsgBox.a"
	IF NOT ERRORLEVEL 0 GOTO ERR
	CALL ".\compile-module.bat" ".\Mod\HeapPtrList\HeapPtrList.bas" ".\Mod\HeapPtrList\libHeapPtrList.a"
	IF NOT ERRORLEVEL 0 GOTO ERR
	CALL ".\compile-module.bat" ".\Mod\OpenProgHKey\OpenProgHKey.bas" ".\Mod\OpenProgHKey\libOpenProgHKey.a"
	IF NOT ERRORLEVEL 0 GOTO ERR
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

:ERR
ECHO ERROR: %ERRORLEVEL%

:EOF
