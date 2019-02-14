/'
    
    main.bas - main module
    
    GD3Edit
    
    Created with Kazusoft's Dialog App Template v2.4
    
    compile with:
        fbc -s gui "main.bas" "resource.res" -x "GD3Edit.exe"
    
'/

''check compiler output type
#If __FB_OUT_EXE__ = 0
    #Error "This program must be compiled as an executable."
#EndIf

''make sure this is main module
#Ifndef __FB_MAIN__
    #Error "This file must be the main module."
#EndIf

''include header file
#Include "header.bi"
#Include "mod/createtooltip/createtooltip.bi"
#Include "mod/errmsgbox/errmsgbox.bi"
#Include "mod/heapptrlist/heapptrlist.bi"
#Include "mod/openproghkey/openproghkey.bi"

hInstance   = GetModuleHandle(NULL) ''get a handle to this module's instance
lpszCmdLine = GetCommandLine()      ''get the command-line parameters
'Dim iccx As InitCommonControlsEx
'With iccx
'    .dwSize = SizeOf(iccx)
'    .dwICC  = (ICC_STANDARD_CLASSES Or ICC_BAR_CLASSES)
'End With
'If (InitCommonControlsEx(@iccx) = FALSE) Then ExitProcess(GetLastError())
InitCommonControls()

Dim uExitCode As UINT32 = Cast(UINT32, WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL))

#If __FB_DEBUG__
    ? !"uExitCode\t= 0x"; Hex(uExitCode, 8)
#EndIf

ExitProcess(uExitCode)
End(uExitCode)

''main function
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hInstPrev\t= 0x"; Hex(hInstPrev, 8)
        ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine, 8)
        ? !"*lpszCmdLine\t= "; *lpszCmdLine
        ? !"nShowCmd\t= 0x"; hex(nShowCmd, 8)
    #EndIf
    
    If (InitClasses(hInst) = FALSE) Then Return(GetLastError())
    
    ''create a heap for the config
    hCfg = HeapCreate(NULL, SizeOf(CONFIG), NULL)
    If (hCfg = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    #If __FB_DEBUG__
        ? !"hCfg\t= 0x"; Hex(hCfg, 8)
    #EndIf
    
    ''allocate config structure
    pCfg = Cast(CONFIG Ptr, HeapAlloc(hCfg, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(CONFIG))))
    If (pCfg = NULL) Then Return(GetLastError())
    #If __FB_DEBUG__
        ? !"pCfg\t= 0x"; Hex(pCfg, 8)
    #EndIf
    
    'With *pCfg
    '    .ShowFullPath = FALSE
    '    .lpszCustFilt = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_CUSTFILT))
    '    If (.lpszCustFilt = NULL) Then Return(Cast(LRESULT, GetLastError()))
    '    #If __FB_DEBUG__
    '        ? !"lpszCustFilt\t= 0x"; Hex(.lpszCustFilt, 8)
    '    #EndIf
    'End With
    
    'If (LoadConfig(hCfg, hInst, pCfg, CFG_ALL) = FALSE) Then Return(GetLastError())
    
    ''start the main dialog
    If (StartMainDlg(hInst, nShowCmd, NULL) = FALSE) Then Return(GetLastError())
    
    ''start message loop
    Dim msg As MSG
    While (GetMessage(@msg, hWin, 0, 0) = TRUE)
        
        ''make sure msg is a valid dialog message
        If (IsDialogMessage(hWin, @msg) = FALSE) Then
            TranslateMessage(@msg)  ''translate msg into a dialog message
            DispatchMessage(@msg)   ''dispatch msg to system
        End If
        
    Wend
    
    ''free config structure
    If (HeapFree(hCfg, NULL, Cast(LPVOID, pCfg)) = FALSE) Then Return(GetLastError())
    
    ''destroy the config heap
    If (HeapDestroy(hCfg) = FALSE) Then Return(GetLastError())
    
    ''unregister MainClass
    If (UnregisterClass(Cast(LPCTSTR, @MainClass), hInst) = FALSE) Then Return(GetLastError())
    
    ''return exit code
    Return(msg.wParam)
    
End Function

Function InitClasses (ByVal hInst As HINSTANCE) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
    #EndIf
    
    ''setup main class
    Dim wcxMain As WNDCLASSEX
    ZeroMemory(@wcxMain, SizeOf(WNDCLASSEX))
    With wcxMain
        .cbSize         = SizeOf(wcxMain)
        .style          = (CS_HREDRAW Or CS_VREDRAW)
        .lpfnWndProc    = @MainProc
        .cbClsExtra     = 0
        .cbWndExtra     = DLGWINDOWEXTRA
        .hInstance      = hInst
        .hIcon          = LoadIcon(hInst, MAKEINTRESOURCE(IDI_KAZUSOFT))
        .hCursor        = LoadCursor(NULL, IDC_ARROW)
        .hbrBackground  = Cast(HBRUSH, (COLOR_BTNFACE + 1))
        .lpszMenuName   = MAKEINTRESOURCE(IDR_MENUMAIN)
        .lpszClassName  = Cast(LPCTSTR, @MainClass)
        .hIconSm        = .hIcon
    End With
    
    ''register main class
    If (RegisterClassEx(@wcxMain) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Function LoadConfig (ByVal hHeap As HANDLE, ByVal hInst As HINSTANCE, ByVal pConfig As CONFIG Ptr, ByVal dwItems As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap, 8)
        ? !"pConfig\t= 0x"; Hex(pConfig, 8)
        ? !"dwItems\t= 0x"; Hex(dwItems, 8)
    #EndIf
    
    ''get a lock on the heap, by doing this, we also verify the heap's existence
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''make sure a null (uninitialized) pointer was passed
    If (pConfig) Then
        SetLastError(ERROR_INVALID_PARAMETER)
        Return(FALSE)
    End If
    
    ''allocate config structure
    pConfig = Cast(CONFIG Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(CONFIG))))
    If (pConfig = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"pConfig\t= 0x"; Hex(pConfig, 8)
    #EndIf
    
    ''allocate config structure's items
    With *pConfig
        .lpszCustFilt = Cast(LPTSTR, HeapAlloc(hHeap,  HEAP_ZERO_MEMORY, CB_CUSTFILT))
        #If __FB_DEBUG__
            ? !"pConfig->lpszCustFilt\t= 0x"; Hex(.lpszCustFilt, 8)
        #EndIf
    End With
    
    ''allocate memory for app name
    Dim lpszAppName As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME))
    If (lpszAppName = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpszAppName\t= 0x"; Hex(lpszAppName, 8)
    #EndIf
    
    ''load app name
    If (LoadString(hInst, IDS_APPNAME, lpszAppName, CCH_APPNAME) = 0) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"*lpszAppName\t= "; *lpszAppName
    #EndIf
    
    ''open/create registry key
    Dim hProgKey As HKEY
    Dim dwDisp As DWORD32
    SetLastError(Cast(DWORD32, OpenProgHKey(@hProgKey, Cast(LPCTSTR, lpszAppName), NULL, KEY_ALL_ACCESS, @dwDisp)))
    If (GetLastError()) Then Return(FALSE)
    
    ''free memory used for app name
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszAppName)) = FALSE) Then Return(FALSE)
    
    ''load config
    If (dwDisp = REG_OPENED_EXISTING_KEY) Then
        
        ''allocate memory for key value names
        Dim plpszValue As LPTSTR Ptr
        SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszValue), CB_REGVAL, C_REGVAL)))
        If (GetLastError()) Then Return(FALSE)
        
        ''load registry key value names
        SetLastError(Cast(DWORD32, LoadStringRange(hInst, plpszValue, IDS_REG_SHOWFULLPATH, CCH_REGVAL, C_REGVAL)))
        If (GetLastError()) Then Return(FALSE)
        
        Dim dwType As DWORD32
        Dim cbSize As DWORD32
        
        cbSize = SizeOf(BOOL)
        SetLastError(Cast(DWORD32, RegQueryValueEx(hProgKey, Cast(LPCTSTR, plpszValue[REGVAL_SHOWFULLPATH]), NULL, @dwType, Cast(LPBYTE, @pConfig->ShowFullPath), @cbSize)))
        If (GetLastError()) Then Return(FALSE)
        
        cbSize = CB_CUSTFILT
        SetLastError(Cast(DWORD32, RegQueryValueEx(hProgKey, Cast(LPCTSTR, plpszValue[REGVAL_CUSTFILT]), NULL, @dwType, Cast(LPBYTE, @pConfig->lpszCustFilt), @cbSize)))
        If (GetLastError()) Then Return(FALSE)
        
        ''free memory used for key value names
        SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszValue), CB_REGVAL, C_REGVAL)))
        If (GetLastError()) Then Return(FALSE)
        
    End If
    
    ''close registry key
    SetLastError(Cast(DWORD32, RegCloseKey(hProgKey)))
    If (GetLastError()) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''starts the main dialog, to be called only by WinMain, do not call this function.
Private Function StartMainDlg (ByVal hInst As HINSTANCE, ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"nShowCmd\t= 0x"; Hex(nShowCmd, 8)
        ? !"lParam\t= 0x"; Hex(lParam, 8)
    #EndIf
    
    ''create, show, and update the main dialog
    DialogBoxParam(hInstance, MAKEINTRESOURCE(IDD_MAIN), NULL, @MainProc, lParam)   ''create the main window
    hWin = FindWindow(Cast(LPCTSTR, @MainClass), NULL)                              ''find the main window
    If (hWin = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (ShowWindow(hWin, nShowCmd) = FALSE) Then Return(FALSE)                      ''show the main window
    If (SetForegroundWindow(hWin) = FALSE) Then Return(FALSE)                       ''move the main window to the foreground
    SetActiveWindow(hWin)                                                           ''set the main window as active
    If (UpdateWindow(hWin) = FALSE) then return(FALSE)                              ''update the main window
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''main dialog procedure
Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''process messages
    Select Case uMsg
        Case WM_CREATE      ''create the dialog
            
            ''set program's icon
            SendMessage(hWnd, WM_SETICON, NULL, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_KAZUSOFT))))
            
            If (CreateWindowEx(NULL, STATUSCLASSNAME, NULL, WS_CHILD Or WS_VISIBLE, 0, 0, 0, 0, hWnd, Cast(HMENU, IDC_SBR_MAIN), hInstance, NULL) = INVALID_HANDLE_VALUE) Then SysErrMsgBox(hWnd, GetLastError())
            
        Case WM_DESTROY     ''destroy the dialog
            
            ''post quit message
            PostQuitMessage(ERROR_SUCCESS)
            
        Case WM_INITDIALOG  ''initialize the dialog
            
        Case WM_CLOSE       ''dialog's close button is pressed
            
            ''destroy main window
            DestroyWindow(hWnd)
            
        Case WM_COMMAND     ''command
            Select Case HiWord(wParam)  ''command code
                Case BN_CLICKED         ''button clicked
                    Select Case LoWord(wParam)  ''button id
                        Case IDM_NEW            ''menu/file/new
                            
                        Case IDM_OPEN           ''menu/file/open
                            
                            Dim hFni As HANDLE = HeapCreate(NULL, FNI_CBFILE, Cast(SIZE_T, (FNI_CFILE * FNI_CBFILE)))
                            If (hFni = INVALID_HANDLE_VALUE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            Dim fni As FILENAMEINFO
                            SetLastError(InitFileNameInfo(hFni, @fni))
                            If (GetLastError()) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''open browse dialog box
                            If (BrowseForFile(hInstance, hWnd, @fni) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''update title bar
                            If (SetMainWndTitle(hInstance, hWnd, Cast(LPCTSTR, fni.lpszFileTitle)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''open file
                            Dim hFile As HANDLE = CreateFile(Cast(LPCTSTR, fni.lpszFile), GENERIC_READ, NULL, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
                            If (hFile = INVALID_HANDLE_VALUE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''read from file
                            Dim szVGM As ZString*4
                            Dim dwRead As DWORD32
                            If (ReadFile(hFile, Cast(LPVOID, @szVGM), SizeOf(szVGM), @dwRead, NULL) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            ? !"szVGM\t= "; szVGM
                            
                            ''close file
                            If (CloseHandle(hFile) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''free FNI
                            SetLastError(FreeFileNameInfo(hFni, @fni))
                            If (GetLastError()) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''destroy the local heap
                            If (HeapDestroy(hFni) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_SAVE           ''menu/file/save
                            
                        Case IDM_SAVEAS         ''menu/file/save as
                            
                        Case IDM_EXIT           ''menu/file/exit
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_ABOUT          ''menu/about
                            
                            If (AboutMsgBox(hInstance, hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                    End Select
                    
            End Select
            
        Case WM_SIZE        ''window resized
            
            Dim rcSbr As RECT
            Dim rcParent As RECT
            
            ''get rects for statusbar and main dialog, and subtract the statusbar's height from that of the main window
            With rcParent
                .right  = LoWord(lParam)
                .bottom = HiWord(lParam)
            End With
            If (GetClientRect(GetDlgItem(hWnd, IDC_SBR_MAIN), @rcSbr) = FALSE) Then
                SysErrMsgBox(hWnd, GetLastError())
                Exit Select
            End If
            rcParent.bottom -= rcSbr.bottom
            
            If (EnumChildWindows(hWnd, @ResizeMainChildren, Cast(LPARAM, @rcParent)) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
            Return(Cast(LRESULT, TRUE))
            
        Case Else           ''otherwise
            
            ''use the default window procedure to return a value
            Return(DefWindowProc(hWnd, uMsg, wParam, lParam))
            
    End Select
    
    ''return success code (0)
    Return(ERROR_SUCCESS)
    
End Function

Private Function ResizeMainChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL
    
    ''get parent rect from lParam
    Dim lprcParent As LPRECT = Cast(LPRECT, lParam)
    If (lprcParent = NULL) Then
        SetLastError(ERROR_INVALID_PARAMETER)
        Return(FALSE)
    End If
    
    ''resize child window
    Dim rcChild As RECT
    With rcChild
        Select Case GetWindowLong(hWnd, GWL_ID)
            Case IDC_SBR_MAIN
                .left   = 0
                .top    = 0
                .right  = 0
                .bottom = 0
        End Select
        
        ''resize the child window
        If (MoveWindow(hWnd, .left, .top, .right, .bottom, TRUE) = FALSE) Then Return(FALSE)
        
    End With
    
    ''return
    Return(TRUE)
    
End Function

Private Function BrowseForFile (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal pFni As FILENAMEINFO Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
        ? !"pFni\t= 0x"; Hex(pfni, 8)
    #EndIf
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(hInst, IDC_WAIT))
    If (hCurPrev = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''create a local heap
    Dim hOfn As HANDLE = HeapCreate(NULL, SizeOf(OPENFILENAME), NULL)
    If (hOfn = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''lock the local heap
    If (HeapLock(hOfn) = FALSE) Then Return(FALSE)
    
    ''allocate file filter
    Dim lpszFilt As LPTSTR = Cast(LPTSTR, HeapAlloc(hOfn, HEAP_ZERO_MEMORY, CB_FILTER))
    If (lpszFilt = NULL) Then Return(FALSE)
    
    ''load the file filter
    If (LoadString(hInst, IDS_FILTER, lpszFilt, CCH_FILTER) = 0) Then Return(FALSE)
    
    ''allocate ofn
    Dim lpOfn As LPOPENFILENAME = Cast(LPOPENFILENAME, HeapAlloc(hOfn, HEAP_ZERO_MEMORY, SizeOf(OPENFILENAME)))
    If (lpOfn = NULL) Then Return(FALSE)
    
    ''setup ofn
    With *lpOfn
        .lStructSize        = SizeOf(OPENFILENAME)
        .hwndOwner          = hDlg
        .hInstance          = NULL
        .lpstrFilter        = Cast(LPCTSTR, lpszFilt)
        .lpstrCustomFilter  = NULL
        .nMaxCustFilter     = NULL
        .nFilterIndex       = 2
        .lpstrFile          = pFni->lpszFile
        .nMaxFile           = MAX_PATH
        .lpstrFileTitle     = pFni->lpszFileTitle
        .nMaxFileTitle      = MAX_PATH
        .lpstrInitialDir    = NULL
        .lpstrTitle         = NULL
        .Flags              = (OFN_DONTADDTORECENT Or OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST)
        .nFileOffset        = NULL
        .nFileExtension     = NULL
        .lpstrDefExt        = NULL
    End With
    
    GetOpenFileName(lpOfn)
    
    ''free memory
    If (HeapFree(hOfn, NULL, Cast(LPVOID, lpOfn)) = FALSE) Then Return(FALSE)
    If (HeapFree(hOfn, NULL, Cast(LPVOID, lpszFilt)) = FALSE) Then Return(FALSE)
    
    ''unlock the heap
    If (HeapUnlock(hOfn) = FALSE) Then Return(FALSE)
    
    ''destroy the local heap
    If (HeapDestroy(hOfn) = FALSE) Then Return(FALSE)
    
    ''restore old cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function SetMainWndTitle (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
        ? !"lpszFile\t= 0x"; Hex(lpszFile, 8)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, CB_APPNAME, NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate space for app name
    Dim lpszAppName As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME))
    If (lpszAppName = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpszAppName\t= 0x"; Hex(lpszAppName, 8)
    #EndIf
    
    ''load the app name
    If (LoadString(hInst, IDS_APPNAME, lpszAppName, CCH_APPNAME) = 0) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"*lpszAppName\t= "; *lpszAppName
    #EndIf
    
    '''calculate # of TCHARs to allocate
    'Dim cchTitle As ULONG32
    'If (pFni) Then
    '    If (pCfg->ShowFullPath) Then
    '        cchTitle = (CCH_APPNAME + MAX_PATH + 5)
    '    Else
    '        cchTitle = (CCH_APPNAME + MAX_PATH + 5)
    '    End If
    'Else
    '    cchTitle = CCH_APPNAME
    'End If
    '#If __FB_DEBUG__
    '    ? !"cchTitle\t= "; cchTitle
    '#EndIf
    
    ''allocate space for new window title
    Dim lpszTitle As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (MAX_PATH * SizeOf(TCHAR)))))
    If (lpszTitle = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpszTitle\t= 0x"; Hex(lpszTitle, 8)
    #EndIf
    
    *lpszTitle = (*lpszAppName + " - [" + *lpszFile + "]")
    #If __FB_DEBUG__
        ? !"*lpszTitle\t= "; *lpszTitle
    #EndIf
    
    ''update the window title
    If (SetWindowText(hDlg, Cast(LPCTSTR, lpszTitle)) = FALSE) Then Return(FALSE)
    
    ''free allocated memory
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszAppName)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszTitle)) = FALSE) Then Return(FALSE)
    
    ''unlock & destroy the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''display the about message box
Private Function AboutMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
    #EndIf
    
    ''set loading cursor
    Dim hCursorPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''create a local heap
    Dim hAmb As HANDLE = HeapCreate(NULL, NULL, NULL)
    If (hAmb = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''get a lock on the heap
    If (HeapLock(hAmb) = FALSE) Then Return(FALSE)
    
    ''allocate space for the unformatted strings
    Dim plpszUnformatted As LPTSTR Ptr
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hAmb, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''load unformatted strings
    SetLastError(Cast(DWORD32, LoadStringRange(hInst, plpszUnformatted, IDS_APPNAME, CCH_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''allocate space for the formatted string
    Dim lpszFormatted As LPTSTR = Cast(LPTSTR, HeapAlloc(hAmb, HEAP_ZERO_MEMORY, Cast(SIZE_T, (C_ABT * CB_ABT))))
    If (lpszFormatted = NULL) Then Return(FALSE)
    
    ''format string
    #Ifdef __FB_64BIT__
        *lpszFormatted = (*plpszUnformatted[ABT_ABOUT] + *plpszUnformatted[ABT_VER64BIT] + *plpszUnformatted[ABT_BUILDDATE] + __DATE__ + Space(1) + __TIME__ + *plpszUnformatted[ABT_COMPILER] + *plpszUnformatted[ABT_SIGNATURE] + __FB_SIGNATURE__ + *plpszUnformatted[ABT_BUILDDATE] + __FB_BUILD_DATE__)
    #Else
        *lpszFormatted = (*plpszUnformatted[ABT_ABOUT] + *plpszUnformatted[ABT_VER32BIT] + *plpszUnformatted[ABT_BUILDDATE] + __DATE__ + Space(1) + __TIME__ + *plpszUnformatted[ABT_COMPILER] + *plpszUnformatted[ABT_SIGNATURE] + __FB_SIGNATURE__ + *plpszUnformatted[ABT_BUILDDATE] + __FB_BUILD_DATE__)
    #EndIf
    
    ''allocate space for message box parameters
    Dim lpMbp As LPMSGBOXPARAMS = Cast(LPMSGBOXPARAMS, HeapAlloc(hAmb, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(MSGBOXPARAMS))))
    If (lpMbp = NULL) Then Return(FALSE)
    
    ''set up message box parameters
    With *lpMbp
        .cbSize         = SizeOf(MSGBOXPARAMS)
        .hwndOwner      = hDlg
        .hInstance      = hInst
        .lpszText       = Cast(LPCTSTR, lpszFormatted)
        .lpszCaption    = Cast(LPCTSTR, plpszUnformatted[ABT_APPNAME])
        .dwStyle        = MB_USERICON
        .lpszIcon       = MAKEINTRESOURCE(IDI_KAZUSOFT)
        .dwLanguageId   = MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US)
    End With
    
    ''restore previous cursor
    hCursorPrev = SetCursor(hCursorPrev)
    
    ''display message box
    If (MessageBoxIndirect(lpMbp) = 0) Then Return(FALSE)
    
    ''set loading cursor
    hCursorPrev = SetCursor(hCursorPrev)
    
    ''free memory
    If (HeapFree(hAmb, NULL, Cast(LPVOID, lpMbp)) = FALSE) Then Return(FALSE)
    If (HeapFree(hAmb, NULL, Cast(LPVOID, lpszFormatted)) = FALSE) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapFreePtrList(hAmb, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''unlock & destroy the local heap
    If (HeapUnlock(hAmb) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hAmb) = FALSE) Then Return(FALSE)
    
    ''restore previous cursor
    SetCursor(hCursorPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
