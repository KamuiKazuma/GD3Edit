/'
    
    header.bi - main header
    
    Created with Kazusoft's Dialog App Template v2.4
    
'/

''preprocesser
#Pragma Once

#Ifdef __FB_64BIT__
    #Print "Compiling for 64-bit Windows."
#Else
    #Print "Compiling for 32-bit Windows."
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

''include header files
#Include Once "windows.bi"
#Include Once "win/commdlg.bi"
#Include Once "win/commctrl.bi"

#Include "inc/vgmhead.bi"
#Include "inc/filenameinfo.bi"
#Include "defines.bi"

''define constants
Const MainClass = "MAINCLASS"   ''main window class

''declare shared variables
Dim Shared hInstance As HINSTANCE   ''instance handle
Dim Shared lpszCmdLine As LPSTR     ''command line
Dim Shared hWin As HWND             ''main window handle

''declare functions

''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As LRESULT

''initializes classes
Declare Function InitClasses (ByVal hInst As HINSTANCE) As BOOL

''starts the main dialog, to be called only by WinMain, do not call this function.
Declare Function StartMainDlg (ByVal hInst As HINSTANCE, ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL

''main dialog procedure
Declare Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''EnumChidWindows proc for resizing the main dialog 
Declare Function ResizeMainChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL

''starts the open dialog to browse for a file
Declare Function BrowseForFile (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal pFni As FILENAMEINFO Ptr) As BOOL

''updates the main dialog's title bar
Declare Function SetMainWndTitle (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal lpszFile As LPCTSTR) As BOOL

Declare Sub FatalErrorProc (ByVal hDlg As HWND, ByVal dwErrCode As DWORD32)

''displays the about message box
Declare Function AboutMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL

Declare Function InitMainChildren (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
Declare Function InitMainListView (ByVal hInst As HINSTANCE, ByVal hWnd As HWND) As BOOL
Declare Function InitMainListViewColumns (ByVal hInst As HINSTANCE, ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL
Declare Function InitMainListViewItems (ByVal hInst As HINSTANCE, ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL

''EOF
