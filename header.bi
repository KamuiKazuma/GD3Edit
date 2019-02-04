/'
    
    header.bi - main header
    
    Created with Kazusoft's Dialog App Template v2.4
    
'/

''preprocesser
#Pragma Once

#Ifdef __FB_64BIT__
    #Print "Compiling for Win64."
#Else
    #Print "Compiling for Win32."
#EndIf
#If __FB_DEBUG__
    #Print "Compiling in debug mode."
#Else
    #Print "Compiling in release mode."
#EndIf

'#Ifndef UNICODE
'    #Define UNICODE
'#EndIf

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
#Include Once "win/commctrl.bi"
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
Dim Shared hHeap As HANDLE      ''handle to the main application heap

''declare functions

''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32

''starts the main dialog, to be called only by WinMain, do not call this function.
Declare Sub StartMainDlg (ByVal nShowCmd As INT32, ByVal lParam As LPARAM)

''main dialog procedure
Declare Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

Declare Function ResizeMainChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL

''displays the about message box
Declare Function AboutMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL

''EOF
