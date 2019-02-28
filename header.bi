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

''make sure target is Windows
#Ifndef __FB_WIN32__
    #Error "This program must be compiled for Windows."
#EndIf

''include windows header files
#Include Once "windows.bi"

''define DWL_MSGRESULT, for some reason FB v1.05.0's Win64 headers don't define this
#Ifndef DWL_MSGRESULT
    #Define DWL_MSGRESULT 0
#EndIf

#Include Once "win/commdlg.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/prsht.bi"

''include module headers
#Include "inc/filenameinfo.bi"
#Include "inc/options.bi"
#Include "inc/vgmhead.bi"
#Include "defines.bi"

Extern hInstance As HINSTANCE
Extern hWin As HWND

''define constants
Const MainClass = "MAINCLASS"   ''main window class

''declare functions

''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As LRESULT

''initializes classes
Declare Function InitClasses () As BOOL

''starts the main dialog, to be called only by WinMain, do not call this function.
Declare Function StartMainDlg (ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL

''main dialog procedure
Declare Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

Declare Function CreateMainChildren (ByVal hDlg As HWND) As BOOL

''EnumChidWindows proc for resizing the main dialog 
Declare Function ResizeMainChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL

''starts the open dialog to browse for a file
Declare Function BrowseForFile (ByVal hDlg As HWND, ByVal pFni As FILENAMEINFO Ptr) As BOOL

/'updates the main dialog's title bar
    hDlg:HWND           -   Handle to the main window.
    lpszFile:LPCTSTR    -   File name to use to set the file title to. Uses
                            the form "<app name> - [<file name>]". If this is
                            NULL, then the title is reset.
'/
Declare Function SetMainWndTitle (ByVal hDlg As HWND, ByVal lpszFile As LPCTSTR) As BOOL

/'used to set up file access rights by MainProc
    bReadOnly:BOOL      - File is read only?
    dwAccess:DWORD32    - Buffer to fill with access rights.
    dwShare:DWORD32     - Buffer to fill with sharing rights.
'/
Declare Sub SetupFileRights (ByVal bReadOnly As BOOL, ByRef dwAccess As DWORD32, ByRef dwShare As DWORD32)

Declare Sub FatalErrorProc (ByVal hDlg As HWND, ByVal dwErrCode As DWORD32)

''displays the about message box
Declare Function AboutMsgBox (ByVal hDlg As HWND) As BOOL

''main window children initialization functions:

/'Initializes the main window's children
    hDlg:HWND   -   Handle to the main window.
'/
Declare Function InitMainChildren (ByVal hDlg As HWND) As BOOL

/'Initializes the main listbox control
    hWnd:HWND   -   Handle to the listbox contorl.
'/
Declare Function InitMainListView (ByVal hWnd As HWND) As BOOL
Declare Function InitMainListViewColumns (ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL
Declare Function InitMainListViewItemNames (ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL

''EOF
