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
    
    If Not(InitClasses(hInst)) Then Return(GetLastError())
    
    ''start the main dialog
    If Not(StartMainDlg(hInst, nShowCmd, NULL)) Then Return(GetLastError())
    
    ''start message loop
    Dim msg As MSG
    While (GetMessage(@msg, hWin, 0, 0))
        
        ''make sure msg is a valid dialog message
        If Not(IsDialogMessage(hWin, @msg)) Then
            TranslateMessage(@msg)  ''translate msg into a dialog message
            DispatchMessage(@msg)   ''dispatch msg to system
        End If
        
    Wend
    
    ''unregister MainClass
    If Not(UnregisterClass(Cast(LPCTSTR, @MainClass), hInst)) Then Return(GetLastError())
    
    ''return exit code
    Return(msg.wParam)
    
End Function

''initializes classes
Private Function InitClasses (ByVal hInst As HINSTANCE) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
    #EndIf
    
    ''make sure hInst is a valid handle
    If (hInst = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    
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
    If Not(RegisterClassEx(@wcxMain)) Then Return(FALSE)
    
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
            
            If (CreateWindowEx(NULL, STATUSCLASSNAME, NULL, (WS_CHILD Or WS_VISIBLE), 0, 0, 0, 0, hWnd, Cast(HMENU, IDC_SBR_MAIN), hInstance, NULL) = INVALID_HANDLE_VALUE) Then SysErrMsgBox(hWnd, GetLastError())
            
        Case WM_DESTROY     ''destroy the dialog
            
            ''post quit message
            PostQuitMessage(ERROR_SUCCESS)
            
        Case WM_INITDIALOG  ''initialize the dialog
            
        Case WM_CLOSE       ''dialog's close button is pressed
            
            ''destroy main window
            If Not(DestroyWindow(hWnd)) Then SysErrMsgBox(hWnd, GetLastError())
            
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
                            If Not(BrowseForFile(hInstance, hWnd, @fni)) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''update title bar
                            If Not(SetMainWndTitle(hInstance, hWnd, Cast(LPCTSTR, fni.lpszFileTitle))) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''open file
                            Dim hFile As HANDLE = CreateFile(Cast(LPCTSTR, fni.lpszFile), GENERIC_READ, NULL, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
                            If (hFile = INVALID_HANDLE_VALUE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''read from file
                            Dim szVGM As ZString*4
                            Dim dwRead As DWORD32
                            If Not(ReadFile(hFile, Cast(LPVOID, @szVGM), SizeOf(szVGM), @dwRead, NULL)) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            ? !"szVGM\t= "; szVGM
                            
                            ''close file
                            If Not(CloseHandle(hFile)) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''free FNI
                            SetLastError(FreeFileNameInfo(hFni, @fni))
                            If (GetLastError()) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''destroy the local heap
                            If Not(HeapDestroy(hFni)) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_SAVE           ''menu/file/save
                            
                        Case IDM_SAVEAS         ''menu/file/save as
                            
                        Case IDM_EXIT           ''menu/file/exit
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_ABOUT          ''menu/about
                            
                            If Not(AboutMsgBox(hInstance, hWnd)) Then SysErrMsgBox(hWnd, GetLastError())
                            
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
            If Not(GetClientRect(GetDlgItem(hWnd, IDC_SBR_MAIN), @rcSbr)) Then
                SysErrMsgBox(hWnd, GetLastError())
                Exit Select
            End If
            rcParent.bottom -= rcSbr.bottom
            
            If Not(EnumChildWindows(hWnd, @ResizeMainChildren, Cast(LPARAM, @rcParent))) Then SysErrMsgBox(hWnd, GetLastError())
            
            Return(Cast(LRESULT, TRUE))
            
        Case Else           ''otherwise
            
            ''use the default window procedure to return a value
            Return(DefWindowProc(hWnd, uMsg, wParam, lParam))
            
    End Select
    
    ''return success code (0)
    Return(ERROR_SUCCESS)
    
End Function

''resizes the main dialog's child windows
Private Function ResizeMainChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL
    
    ''get parent rect from lParam
    Dim lprcParent As LPRECT = Cast(LPRECT, lParam)
    If Not(lprcParent) Then
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
        If Not(MoveWindow(hWnd, .left, .top, .right, .bottom, TRUE)) Then Return(FALSE)
        
    End With
    
    ''return
    Return(TRUE)
    
End Function

''starts the open dialog to browse for a file
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
    Dim hHeap As HANDLE = HeapCreate(NULL, SizeOf(OPENFILENAME), NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"hHeap\t= 0x"; Hex(hheap)
    #EndIf
    
    ''lock the local heap
    If Not(HeapLock(hHeap)) Then Return(FALSE)
    
    ''allocate file filter
    Dim lpszFilt As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_FILTER))
    If Not(lpszFilt) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpszFilt\t= 0x"; Hex(lpszFilt)
    #EndIf
    
    ''load the file filter
    If (LoadString(hInst, IDS_FILTER, lpszFilt, CCH_FILTER) = 0) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"*lpszFilt\t= "; *lpszFilt
    #EndIf
    
    ''allocate ofn
    Dim lpOfn As LPOPENFILENAME = Cast(LPOPENFILENAME, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(OPENFILENAME)))
    If Not(lpOfn) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpOfn\t= 0x"; Hex(lpOfn)
    #EndIf
    
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
    If Not(HeapFree(hHeap, NULL, Cast(LPVOID, lpOfn))) Then Return(FALSE)
    If Not(HeapFree(hHeap, NULL, Cast(LPVOID, lpszFilt))) Then Return(FALSE)
    
    ''unlock the heap
    If Not(HeapUnlock(hHeap)) Then Return(FALSE)
    
    ''destroy the local heap
    If Not(HeapDestroy(hHeap)) Then Return(FALSE)
    
    ''restore old cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''updates the main dialog's title bar
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
    #If __FB_DEBUG__
        ? !"hHeap\t= 0x"; Hex(hHeap)
    #EndIf
    
    ''get a lock on the heap
    If Not(HeapLock(hHeap)) Then Return(FALSE)
    
    ''allocate space for app name
    Dim lpszAppName As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME))
    If Not(lpszAppName) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpszAppName\t= 0x"; Hex(lpszAppName, 8)
    #EndIf
    
    ''load the app name
    If (LoadString(hInst, IDS_APPNAME, lpszAppName, CCH_APPNAME) = 0) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"*lpszAppName\t= "; *lpszAppName
    #EndIf
        
    ''calculate number of chars to allocate
    Dim cchTitle As ULONG32
    If (lpszFile) Then
        cchTitle = (CCH_APPNAME + MAX_PATH + 5)
    Else
        cchTitle = (CCH_APPNAME)
    End If
    #If __FB_DEBUG__
        ? !"cchTitle\t= "; cchTitle
    #EndIf
    
    ''allocate space for new window title
    Dim lpszTitle As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (cchTitle * SizeOf(TCHAR)))))
    If Not(lpszTitle) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpszTitle\t= 0x"; Hex(lpszTitle, 8)
    #EndIf
    
    *lpszTitle = (*lpszAppName + " - [" + *lpszFile + "]")
    #If __FB_DEBUG__
        ? !"*lpszTitle\t= "; *lpszTitle
    #EndIf
    
    ''update the window title
    If Not(SetWindowText(hDlg, Cast(LPCTSTR, lpszTitle))) Then Return(FALSE)
    
    ''free allocated memory
    If Not(HeapFree(hHeap, NULL, Cast(LPVOID, lpszAppName))) Then Return(FALSE)
    If Not(HeapFree(hHeap, NULL, Cast(LPVOID, lpszTitle))) Then Return(FALSE)
    
    ''unlock & destroy the heap
    If Not(HeapUnlock(hHeap)) Then Return(FALSE)
    If Not(HeapDestroy(hHeap)) Then Return(FALSE)
    
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
    Dim hHeap As HANDLE = HeapCreate(NULL, NULL, NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''get a lock on the heap
    If Not(HeapLock(hHeap)) Then Return(FALSE)
    
    ''allocate space for the unformatted strings
    Dim plpszUnformatted As LPTSTR Ptr
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''load unformatted strings
    SetLastError(Cast(DWORD32, LoadStringRange(hInst, plpszUnformatted, IDS_APPNAME, CCH_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''allocate space for the formatted string
    Dim lpszFormatted As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (C_ABT * CB_ABT))))
    If Not(lpszFormatted) Then Return(FALSE)
    
    ''format string
    #Ifdef __FB_64BIT__
        *lpszFormatted = (*plpszUnformatted[ABT_ABOUT] + *plpszUnformatted[ABT_VER64BIT] + *plpszUnformatted[ABT_BUILDDATE] + __DATE__ + Space(1) + __TIME__ + *plpszUnformatted[ABT_COMPILER] + *plpszUnformatted[ABT_SIGNATURE] + __FB_SIGNATURE__ + *plpszUnformatted[ABT_BUILDDATE] + __FB_BUILD_DATE__)
    #Else
        *lpszFormatted = (*plpszUnformatted[ABT_ABOUT] + *plpszUnformatted[ABT_VER32BIT] + *plpszUnformatted[ABT_BUILDDATE] + __DATE__ + Space(1) + __TIME__ + *plpszUnformatted[ABT_COMPILER] + *plpszUnformatted[ABT_SIGNATURE] + __FB_SIGNATURE__ + *plpszUnformatted[ABT_BUILDDATE] + __FB_BUILD_DATE__)
    #EndIf
    
    ''allocate space for message box parameters
    Dim lpMbp As LPMSGBOXPARAMS = Cast(LPMSGBOXPARAMS, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(MSGBOXPARAMS))))
    If Not(lpMbp) Then Return(FALSE)
    
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
    If (MessageBoxIndirect(lpMbp) <> IDOK) Then Return(FALSE)
    
    ''set loading cursor
    hCursorPrev = SetCursor(hCursorPrev)
    
    ''free memory
    If Not(HeapFree(hHeap, NULL, Cast(LPVOID, lpMbp))) Then Return(FALSE)
    If Not(HeapFree(hHeap, NULL, Cast(LPVOID, lpszFormatted))) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''unlock & destroy the local heap
    If Not(HeapUnlock(hHeap)) Then Return(FALSE)
    If Not(HeapDestroy(hHeap)) Then Return(FALSE)
    
    ''restore previous cursor
    SetCursor(hCursorPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
