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
'#Include "mod/createtooltip/createtooltip.bi"
#Include "mod/errmsgbox/errmsgbox.bi"
#Include "mod/heapptrlist/heapptrlist.bi"
'#Include "mod/openproghkey/openproghkey.bi"

Dim Shared hInstance As HINSTANCE
Dim Shared lpszCmdLine As LPSTR
Dim Shared hWin As HWND
hInstance = GetModuleHandle(NULL) ''get a handle to this module's instance
lpszCmdLine = GetCommandLine() ''get the command-line parameters
InitCommonControls()

Dim uExitCode As UINT32 = Cast(UINT32, WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL))

#If __FB_DEBUG__
    ? !"uExitCode\t= 0x"; Hex(uExitCode)
#EndIf

ExitProcess(uExitCode)
End(uExitCode)

''main function
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hInstPrev\t= 0x"; Hex(hInstPrev)
        ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine)
        ? !"*lpszCmdLine\t= "; *lpszCmdLine
        ? !"nShowCmd\t= 0x"; hex(nShowCmd)
    #EndIf
    
    If (InitClasses(hInst) = FALSE) Then Return(GetLastError())
    
    ''start the main dialog
    If (StartMainDlg(hInst, nShowCmd, NULL) = FALSE) Then Return(GetLastError())
    
    ''start message loop
    Dim msg As MSG
    While (GetMessage(@msg, hWin, 0, 0))
        
        ''make sure msg is a valid dialog message
        If (IsDialogMessage(hWin, @msg) = FALSE) Then
            TranslateMessage(@msg)  ''translate msg into a dialog message
            DispatchMessage(@msg)   ''dispatch msg to system
        End If
        
    Wend
    
    ''unregister MainClass
    If (UnregisterClass(Cast(LPCTSTR, @MainClass), hInst) = FALSE) Then Return(GetLastError())
    
    ''return exit code
    Return(msg.wParam)
    
End Function

''initializes classes
Private Function InitClasses (ByVal hInst As HINSTANCE) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
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
        .hIcon          = LoadIcon(hInst, MAKEINTRESOURCE(IDI_GD3TAG))
        .hCursor        = LoadCursor(NULL, IDC_ARROW)
        .hbrBackground  = Cast(HBRUSH, (COLOR_BTNFACE + 1))
        .lpszMenuName   = MAKEINTRESOURCE(IDR_MENUMAIN)
        .lpszClassName  = Cast(LPCTSTR, @MainClass)
        .hIconSm        = LoadIcon(hInst, MAKEINTRESOURCE(IDI_GD3TAGSM))
    End With
    
    ''register main class
    RegisterClassEx(@wcxMain)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''starts the main dialog, to be called only by WinMain, do not call this function.
Private Function StartMainDlg (ByVal hInst As HINSTANCE, ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"nShowCmd\t= 0x"; Hex(nShowCmd)
        ? !"lParam\t= 0x"; Hex(lParam)
    #EndIf
    
    ''create the main dialog
    DialogBoxParam(hInstance, MAKEINTRESOURCE(IDD_MAIN), NULL, @MainProc, lParam)
    
    ''find the main dialog
    hWin = FindWindow(Cast(LPCTSTR, @MainClass), NULL)
    If (hWin = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''show and update the main dialog
    If (ShowWindow(hWin, nShowCmd) = FALSE) Then Return(FALSE)
    If (SetForegroundWindow(hWin) = FALSE) Then Return(FALSE)
    SetActiveWindow(hWin)
    If (UpdateWindow(hWin) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''main dialog procedure
Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    Static hFni As HANDLE
    Static fni As FILENAMEINFO
    Static vgmHead As VGM_HEADER
    
    ''process messages
    Select Case uMsg
        Case WM_CREATE
            
            ''set program's icon
            SendMessage(hWnd, WM_SETICON, NULL, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_GD3TAG))))
            
            If (CreateMainChildren(hInstance, hWnd) = FALSE) Then FatalErrorProc(hWnd, GetLastError())
            
            ''create a heap for the file name info
            hFni = HeapCreate(NULL, SizeOf(FILENAMEINFO), SizeOf(FILENAMEINFO))
            If (hFni = INVALID_HANDLE_VALUE) Then FatalErrorProc(hWnd, GetLastError())
            
            ''initialize the file name info structure
            SetLastError(InitFileNameInfo(hFni, @fni))
            If (GetLastError()) Then FatalErrorProc(hWnd, GetLastError())
            
        Case WM_DESTROY
            
            ''free the file name info structure
            SetLastError(FreeFileNameInfo(hFni, @fni))
            If (GetLastError()) Then FatalErrorProc(hWnd, GetLastError())
            
            ''destroy the local heaps
            If (HeapDestroy(hFni) = FALSE) Then FatalErrorProc(hWnd, GetLastError())
            
            ''post quit message
            PostQuitMessage(ERROR_SUCCESS)
            
        Case WM_INITDIALOG
            
            If (InitMainChildren(hInstance, hWnd) = FALSE) Then FatalErrorProc(hWnd, GetLastError())
            
        Case WM_CLOSE
            
            If (DestroyWindow(hWnd) = FALSE) Then FatalErrorProc(hWnd, GetLastError())
            
        Case WM_COMMAND
            Select Case HiWord(wParam)
                Case BN_CLICKED
                    Select Case LoWord(wParam)
                        Case IDM_OPEN
                            
                            ''lock the file name heap
                            If (HeapLock(hFni) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''open browse dialog box
                            If (BrowseForFile(hInstance, hWnd, @fni) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''update title bar
                            If (SetMainWndTitle(hInstance, hWnd, Cast(LPCTSTR, fni.lpszFileTitle)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''setup access and sharing rights
                            Dim As DWORD32 dwAccess, dwShare
                            SetupFileRights(fni.bReadOnly, dwAccess, dwShare)
                            
                            ''open the file
                            Dim hFile As HANDLE = CreateFile(Cast(LPCTSTR, fni.lpszFile), dwAccess, dwShare, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
                            If (hFile = INVALID_HANDLE_VALUE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''read the VGM file header
                            SetLastError(ReadVGMHeader(hFile, @vgmHead))
                            If (GetLastError()) Then FatalErrorProc(hWnd, GetLastError())
                            
                            ''close file
                            If (CloseHandle(hFile) = FALSE) Then FatalErrorProc(hWnd, GetLastError())
                            
                            ''unlock the file name heap
                            If (HeapUnlock(hFni) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''update UI
                            '#If __FB_DEBUG__
                            '    ? !"fccVGM\t= "; Hex(vgmHead.fccVGM, 8)
                            '    ? !"dwVersion\t= "; Hex(vgmHead.dwVersion, 8)
                            '#EndIf
                            
                        Case IDM_SAVE
                            
                        Case IDM_SAVEAS
                            
                        Case IDM_CLOSE
                            
                        Case IDM_EXIT
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_OPTIONS
                            
                            SetLastError(StartOptionsMenu(hInstance, hWnd, 0))
                            If (GetLastError()) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDM_ABOUT
                            
                            If (AboutMsgBox(hInstance, hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                    End Select
                    
            End Select
            
        Case WM_SIZE
            
            Dim rcSbr As RECT
            Dim rcParent As RECT
            
            ''get rects for statusbar and main dialog, and subtract the statusbar's height from that of the main window
            With rcParent
                .right  = LoWord(lParam)
                .bottom = HiWord(lParam)
            End With
            If (GetClientRect(GetDlgItem(hWnd, IDC_SBR_MAIN), @rcSbr) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            rcParent.bottom -= rcSbr.bottom
            
            If (EnumChildWindows(hWnd, @ResizeMainChildren, Cast(LPARAM, @rcParent)) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
            Return(Cast(LRESULT, TRUE))
            
        Case Else
            
            ''use the default window procedure to return a value
            Return(DefWindowProc(hWnd, uMsg, wParam, lParam))
            
    End Select
    
    ''return success code (0)
    Return(ERROR_SUCCESS)
    
End Function

''creates the main dialog's child windows
Private Function CreateMainChildren (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    Dim icex As InitCommonControlsEx
    icex.dwSize = SizeOf(InitCommonControlsEx)
    
    icex.dwICC = ICC_BAR_CLASSES
    InitCommonControlsEx(@icex)
    If (CreateWindowEx(WS_EX_STATICEDGE, STATUSCLASSNAME, NULL, (SBARS_SIZEGRIP Or SBARS_TOOLTIPS Or WS_CHILD Or WS_VISIBLE), CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, hDlg, Cast(HMENU, IDC_SBR_MAIN), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    icex.dwICC = ICC_LISTVIEW_CLASSES
    InitCommonControlsEx(@icex)
    If (CreateWindowEx((LVS_EX_GRIDLINES Or WS_EX_CLIENTEDGE Or WS_EX_CONTROLPARENT Or WS_EX_RIGHT), WC_LISTVIEW, NULL, (LVS_NOSORTHEADER Or LVS_REPORT Or LVS_SINGLESEL Or WS_CHILD Or WS_TABSTOP Or WS_VISIBLE Or WS_VSCROLL), CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, hDlg, Cast(HMENU, IDC_LIV_MAIN), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''resizes the main dialog's child windows
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
            Case IDC_LIV_MAIN
                .left   = lprcParent->Left
                .top    = lprcParent->top
                .right  = (lprcParent->Right - (2 * MARGIN_SIZE))
                .bottom = (lprcParent->bottom - (2 * MARGIN_SIZE))
        End Select
        
        ''resize the child window
        If (MoveWindow(hWnd, .left, .top, .right, .bottom, TRUE) = FALSE) Then Return(FALSE)
        
    End With
    
    ''return
    Return(TRUE)
    
End Function

''starts the open dialog to browse for a file
Private Function BrowseForFile (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal pFni As FILENAMEINFO Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"pFni\t= 0x"; Hex(pfni)
    #EndIf
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(hInst, IDC_WAIT))
    If (hCurPrev = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, SizeOf(OPENFILENAME), NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"hHeap\t= 0x"; Hex(hHeap)
    #EndIf
    
    ''lock the local heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate file filter
    Dim lpszFilt As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_FILTER))
    If (lpszFilt = NULL) Then Return(FALSE)
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
    If (lpOfn = NULL) Then Return(FALSE)
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
        .nFilterIndex       = 1
        .lpstrFile          = pFni->lpszFile
        .nMaxFile           = MAX_PATH
        .lpstrFileTitle     = pFni->lpszFileTitle
        .nMaxFileTitle      = MAX_PATH
        .lpstrInitialDir    = NULL
        .lpstrTitle         = NULL
        .Flags              = (OFN_DONTADDTORECENT Or OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST)
        .nFileOffset        = pFni->cchFileOffset
        .nFileExtension     = pFni->cchExtOffset
        .lpstrDefExt        = NULL
    End With
    
    If (GetOpenFileName(lpOfn)) Then
        If (lpOfn->Flags And OFN_READONLY) Then
            pFni->bReadOnly = TRUE
        Else
            pFni->bReadOnly = FALSE
        End If
    End If
    
    ''free memory
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpOfn)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszFilt)) = FALSE) Then Return(FALSE)
    
    ''unlock the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''destroy the local heap
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    
    ''restore old cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''updates the main dialog's title bar
Private Function SetMainWndTitle (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, CB_APPNAME, NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"hHeap\t= 0x"; Hex(hHeap)
    #EndIf
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate space for app name
    Dim lpszAppName As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME))
    If (lpszAppName = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpszAppName\t= 0x"; Hex(lpszAppName)
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
    If (lpszTitle = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpszTitle\t= 0x"; Hex(lpszTitle)
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

Private Sub SetupFileRights (ByVal bReadOnly As BOOL, ByRef dwAccess As DWORD32, ByRef dwShare As DWORD32)
    
    If (bReadOnly = TRUE) Then
        dwAccess = GENERIC_READ
        dwShare = (FILE_SHARE_WRITE Or FILE_SHARE_READ Or FILE_SHARE_DELETE)
    Else
        dwAccess = (GENERIC_READ Or GENERIC_WRITE)
        dwShare = FILE_SHARE_READ
    End If

End Sub

''displays a system error message box and posts a quit message
Private Sub FatalErrorProc (ByVal hDlg As HWND, ByVal dwErrCode As DWORD32)
    
    SysErrMsgBox(hDlg, dwErrCode)
    PostQuitMessage(dwErrCode)
    
End Sub

''display the about message box
Private Function AboutMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''set loading cursor
    Dim hCursorPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, NULL, NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate space for the unformatted strings
    Dim plpszUnformatted As LPTSTR Ptr
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''load unformatted strings
    SetLastError(Cast(DWORD32, LoadStringRange(hInst, plpszUnformatted, IDS_APPNAME, CCH_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''allocate space for the formatted string
    Dim lpszFormatted As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (C_ABT * CB_ABT))))
    If (lpszFormatted = NULL) Then Return(FALSE)
    
    ''format string
    #Ifdef __FB_64BIT__
        *lpszFormatted = (*plpszUnformatted[ABT_ABOUT] + *plpszUnformatted[ABT_VER64BIT] + *plpszUnformatted[ABT_BUILDDATE] + __DATE__ + Space(1) + __TIME__ + *plpszUnformatted[ABT_COMPILER] + *plpszUnformatted[ABT_SIGNATURE] + __FB_SIGNATURE__ + *plpszUnformatted[ABT_BUILDDATE] + __FB_BUILD_DATE__)
    #Else
        *lpszFormatted = (*plpszUnformatted[ABT_ABOUT] + *plpszUnformatted[ABT_VER32BIT] + *plpszUnformatted[ABT_BUILDDATE] + __DATE__ + Space(1) + __TIME__ + *plpszUnformatted[ABT_COMPILER] + *plpszUnformatted[ABT_SIGNATURE] + __FB_SIGNATURE__ + *plpszUnformatted[ABT_BUILDDATE] + __FB_BUILD_DATE__)
    #EndIf
    
    ''allocate space for message box parameters
    Dim lpMbp As LPMSGBOXPARAMS = Cast(LPMSGBOXPARAMS, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(MSGBOXPARAMS))))
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
    If (MessageBoxIndirect(lpMbp) <> IDOK) Then Return(FALSE)
    
    ''set loading cursor
    hCursorPrev = SetCursor(hCursorPrev)
    
    ''free memory
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpMbp)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszFormatted)) = FALSE) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''unlock & destroy the local heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    
    ''restore previous cursor
    SetCursor(hCursorPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''Initializes the main dialog's child windows
Private Function InitMainChildren (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''set a loading cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_APPSTARTING))
    
    ''init child windows
    If (InitMainListView(hInst, GetDlgItem(hDlg, IDC_LIV_MAIN)) = FALSE) Then Return(FALSE)
    
    ''restore cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function InitMainListView (ByVal hInst As HINSTANCE, ByVal hWnd As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, NULL, (((CB_LVHD * C_LVHD) + SizeOf(LVCOLUMN)) + ((CB_LVITEM * C_LVITEM) + SizeOf(LVITEM))))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"hHeap\t= 0x"; Hex(hHeap)
    #EndIf
    
    ''initialize the listview
    SendMessage(hWnd, WM_SETREDRAW, FALSE, NULL)
    If (InitMainListViewColumns(hInst, hHeap, hWnd) = FALSE) Then Return(FALSE)
    If (InitMainListViewItemNames(hInst, hHeap, hWnd) = FALSE) Then Return(FALSE)
    SendMessage(hWnd, WM_SETREDRAW, TRUE, NULL)
    
    ''destroy the local heap
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function InitMainListViewColumns (ByVal hInst As HINSTANCE, ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    ''lock the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate space for column headings
    Dim plpszHead As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszHead), CB_LVHD, C_LVHD))
    If (GetLastError()) Then Return(FALSE)
    
    ''load the column headings
    SetLastError(LoadStringRange(hInst, plpszHead, IDS_CHD_NAME, CCH_LVHD, C_LVHD))
    If (GetLastError()) Then Return(FALSE)
    
    ''allocate a column structure
    Dim pLvc As LPLVCOLUMN = Cast(LPLVCOLUMN, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(LVCOLUMN)))
    If (pLvc = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"pLvc\t= 0x"; Hex(pLvc)
    #EndIf
    
    ''setup columns
    pLvc->mask  = (LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM)
    pLvc->cx    = 100 ''this number might need to be changed later
    
    For iCol As INT32 = 0 To (C_LVHD - 1)
        #If __FB_DEBUG__
            ? !"iCol\t= "; iCol
        #EndIf
        
        pLvc->iSubItem = iCol
        If (iCol < 1) Then
            pLvc->fmt = LVCFMT_RIGHT
        Else
            pLvc->fmt = LVCFMT_LEFT
        End If
        
        pLvc->pszText = plpszHead[iCol]
        If (SendMessage(hWnd, LVM_INSERTCOLUMN, iCol, Cast(LPARAM, pLvc)) = -1) Then Return(FALSE)
        
    Next iCol
    
    ''free the column structure & headings
    If (HeapFree(hHeap, NULL, Cast(LPVOID, pLvc)) = FALSE) Then Return(FALSE)
    SetLastError(HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszHead), CB_LVHD, C_LVHD))
    If (GetLastError()) Then Return(FALSE)
    
    ''unlock the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function InitMainListViewItemNames (ByVal hInst As HINSTANCE, ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    ''lock the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate space for listview items
    Dim plpszItem As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszItem), CB_LVITEM, C_LVITEM))
    If (GetLastError()) Then Return(FALSE)
    
    ''load the listview items
    SetLastError(LoadStringRange(hInst, plpszItem, IDS_LVI_VGMVER, CCH_LVITEM, C_LVITEM))
    If (GetLastError()) Then Return(FALSE)
    
    ''allocate space for a listview item
    Dim pLvi As LVITEM Ptr = Cast(LPLVITEM, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(LVITEM)))
    If (pLvi = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"pLvi\t= 0x"; Hex(pLvi)
    #EndIf
    
    pLvi->mask = LVIF_TEXT
    For iItem As INT32 = 0 To (C_LVITEM - 1)
        #If __FB_DEBUG__
            ? !"iItem\t="; iItem
        #EndIf
        pLvi->iItem     = iItem
        pLvi->pszText   = plpszItem[iItem]
        If (SendMessage(hWnd, LVM_INSERTITEM, NULL, Cast(LPARAM, pLvi)) = -1) Then Return(FALSE)
    Next iItem
    
    ''free listview item names and the item structure
    If (HeapFree(hHeap, NULL, Cast(LPVOID, pLvi)) = FALSE) Then Return(FALSE)
    SetLastError(HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszItem), CB_LVITEM, C_LVITEM))
    If (GetLastError()) Then Return(FALSE)
    
    ''unlock the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
