/'
    
    header.bi - main header
    
    Created with Kazusoft's Dialog App Template v2.4
    
'/

''preprocesser
#Pragma Once


''make sure target is Windows
#Ifndef __FB_WIN32__
    #Error "This program must be compiled for Windows."
#EndIf

''check compiler output type
#If __FB_OUT_EXE__ = 0
    #Error "This program must be compiled as an executable."
#EndIf

''include header files
#Include Once "windows.bi"
#Include Once "win/commdlg.bi"
#Include "mod/createtooltip/createtooltip.bi"
#Include "mod/errmsgbox/errmsgbox.bi"
#Include "mod/heapptrlist/heapptrlist.bi"
#Include "mod/openproghkey/openproghkey.bi"
#Include "defines.bas"

''define constants
Const MainClass = "MAINCLASS"   ''main window class

''declare shared variables
Dim Shared hInstance As HMODULE ''instance handle
Dim Shared lpszCmdLine As LPSTR ''command line
Dim Shared hWin As HWND         ''main window handle


''declare functions

''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32

''starts the main dialog, to be called only by WinMain, do not call this function.
Declare Sub StartMainDlg (ByVal nShowCmd As INT32, ByVal lParam As LPARAM)

''main dialog procedure
Declare Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''EOF
