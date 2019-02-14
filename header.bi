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

#Include "defines.bas"

''define constants
Const MainClass = "MAINCLASS"   ''main window class

''define structures
Type FILENAMEINFO
    lpszFile As LPTSTR      ''pointer to buffer containing full file name ("C:\Folder\Example.txt")
    lpszFileTitle As LPTSTR ''pointer to file name ("Example.txt")
End Type

Type CONFIG
    ShowFullPath As BOOL    ''show full path to opened file in title bar?
    lpszCustFilt As LPTSTR  ''custom filter information for Open/Save As common dialogs
End Type

''declare shared variables
Dim Shared hInstance As HINSTANCE   ''instance handle
Dim Shared lpszCmdLine As LPSTR     ''command line
Dim Shared hWin As HWND             ''main window handle
Dim Shared hCfg As HANDLE           ''handle to the heap containing the config structure
Dim Shared pCfg As CONFIG Ptr       ''pointer to application config structure

''declare functions

''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As LRESULT

Declare Function InitClasses (ByVal hInst As HINSTANCE) As BOOL

Declare Function InitFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT
Declare Function FreeFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT

Declare Function InitConfig (ByVal hHeap As HANDLE, ByVal pCfg As CONFIG Ptr) As LRESULT
Declare Function FreeConfig (ByVal hHeap As HANDLE, ByVal pCfg As CONFIG Ptr) As LRESULT

''loads the config
Declare Function LoadConfig (ByVal hHeap As HANDLE, ByVal hInst As HINSTANCE, ByVal pConfig As CONFIG Ptr, ByVal dwItems As DWORD32) As BOOL

''starts the main dialog, to be called only by WinMain, do not call this function.
Declare Function StartMainDlg (ByVal hInst As HINSTANCE, ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL

''main dialog procedure
Declare Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''EnumChidWindows proc for resizing the main dialog 
Declare Function ResizeMainChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL

Declare Function BrowseForFile (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal pFni As FILENAMEINFO Ptr) As BOOL
Declare Function SetMainWndTitle (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal lpszFile As LPCTSTR) As BOOL

''displays the about message box
Declare Function AboutMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL

''EOF
