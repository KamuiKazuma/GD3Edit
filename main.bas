/'
    
    main.bas - main module
    
    GD3Edit
    
    Created with Kazusoft's Dialog App Template v2.4
    
    compile with:
        fbc -s gui "main.bas" "*.o" "resource.res" -x "GD3Edit.exe"
    
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
#Include "mod/heapptrlist/heapptrlist.bi"

Dim Shared hInstance As HINSTANCE   ''global app instance handle
Dim Shared hWin As HWND             ''global main window handle

Dim lpszCmdLine As LPSTR            ''command line string to pass to WinMain

hInstance = GetModuleHandle(NULL)   ''get a handle to this module's instance
lpszCmdLine = GetCommandLine()      ''get the command-line
InitCommonControls()

''start the application
Dim uExitCode As UINT32 = Cast(UINT32, WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL))

''exit app
#If __FB_DEBUG__
    ? !"uExitCode\t= 0x"; Hex(uExitCode)
#EndIf
ExitProcess(uExitCode)
End(uExitCode)

''main function
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hInstPrev\t= 0x"; Hex(hInstPrev)
        ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine)
        ? !"*lpszCmdLine\t= "; *lpszCmdLine
        ? !"nShowCmd\t= 0x"; hex(nShowCmd)
    #EndIf
    
    If (InitClasses() = FALSE) Then Return(GetLastError())
    
    ''start the main dialog
    If (StartMainDlg(nShowCmd, NULL) = FALSE) Then Return(GetLastError())
    
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
Private Function InitClasses () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    ''make sure hInstance is a valid handle
    If (hInstance = INVALID_HANDLE_VALUE) Then
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
        .hInstance      = hInstance
        .hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_GD3TAG))
        .hCursor        = LoadCursor(NULL, IDC_ARROW)
        .hbrBackground  = Cast(HBRUSH, (COLOR_BTNFACE + 1))
        .lpszMenuName   = MAKEINTRESOURCE(IDR_MENUMAIN)
        .lpszClassName  = Cast(LPCTSTR, @MainClass)
        .hIconSm        = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_GD3TAGSM))
    End With
    
    ''register main class
    RegisterClassEx(@wcxMain)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''starts the main dialog, to be called only by WinMain, do not call this function.
Private Function StartMainDlg (ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
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
            
            If (CreateMainChildren(hWnd) = FALSE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            ''create a heap for the file name info
            hFni = HeapCreate(NULL, SizeOf(FILENAMEINFO), SizeOf(FILENAMEINFO))
            If (hFni = INVALID_HANDLE_VALUE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            ''initialize the file name info structure
            SetLastError(InitFileNameInfo(hFni, @fni))
            If (GetLastError()) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
        Case WM_DESTROY
            
            ''free the file name info structure
            SetLastError(FreeFileNameInfo(hFni, @fni))
            If (GetLastError()) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            ''destroy the local heaps
            If (HeapDestroy(hFni) = FALSE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            ''post quit message
            PostQuitMessage(ERROR_SUCCESS)
            
        Case WM_INITDIALOG
            
            If (InitMainChildren(hWnd) = FALSE) Then
                If (GetLastError() = ERROR_SUCCESS) Then
                    ProgMsgBox(hInstance, hWnd, IDS_MSG_UIINITFAIL, IDS_APPNAME, MB_ICONERROR)
                Else
                    Return(FatalSysErrMsgBox(hWnd, GetLastError()))
                End If
            End If
            
        Case WM_CLOSE
            
            If (DestroyWindow(hWnd) = FALSE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
        Case WM_COMMAND
            Select Case HiWord(wParam)
                Case BN_CLICKED
                    Select Case LoWord(wParam)
                        Case IDM_OPEN
                            
                            ''lock the file name heap
                            If (HeapLock(hFni) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''open browse dialog box
                            If (BrowseForFile(hWnd, @fni) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''open the file
                            Dim As DWORD32 dwAccess, dwShare
                            SetupFileRights(fni.bReadOnly, dwAccess, dwShare)
                            Dim hFile As HANDLE = CreateFile(Cast(LPCTSTR, fni.lpszFile), dwAccess, dwShare, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
                            If (hFile = INVALID_HANDLE_VALUE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''read the VGM file header
                            SetLastError(ReadVGMHeader(hFile, @vgmHead))
                            If (GetLastError()) Then
                                If (GetLastError() = ERROR_BAD_FORMAT) Then
                                    ZeroMemory(@vgmHead, SizeOf(VGM_HEADER))
                                    SetLastError(ClearFileNameInfo(hFni, @fni))
                                    If (GetLastError()) Then SysErrMsgBox(hWnd, GetLastError())
                                    Return(ProgMsgBox(hInstance, hWnd, IDS_MSG_VGMFORMATBAD, IDS_APPNAME, MB_ICONERROR))
                                Else
                                    Return(SysErrMsgBox(hWnd, GetLastError()))
                                End If
                            End If
                            
                            ''close file
                            If (CloseHandle(hFile) = FALSE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
                            
                            ''update UI
                            If (UpdateMainUI(hWnd, @fni, @vgmHead, TRUE) = FALSE) Then
                                If (GetLastError()) Then 
                                    Return(SysErrMsgBox(hWnd, GetLastError()))
                                Else
                                    Return(ProgMsgBox(hInstance, hWnd, IDS_MSG_UIUPFAIL, IDS_APPNAME, MB_ICONERROR))
                                End If
                            End If
                            
                            ''unlock the file name heap
                            If (HeapUnlock(hFni) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_SAVE
                            
                        Case IDM_SAVEAS
                            
                        Case IDM_CLOSE
                            
                            Select Case (ProgMsgBox(hInstance, hWnd, IDS_MSG_UNSAVED, IDS_APPNAME, MB_ICONWARNING Or MB_YESNOCANCEL))
                                Case IDYES
                                    ''save file
                                    ''clear the UI
                                    If (SetMainWndTitle(hWnd, NULL) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                                Case IDNO
                                    ''don't save the file
                                    ''clear the UI
                                    If (SetMainWndTitle(hWnd, NULL) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                                'Case IDCANCEL
                                    ''do nothing
                            End Select
                            
                        Case IDM_EXIT
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_OPTIONS
                            
                            SetLastError(StartOptionsMenu(hWnd, OPT_PG_GENERAL))
                            If (GetLastError()) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDM_ABOUT
                            
                            If (AboutMsgBox(hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
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
Private Function CreateMainChildren (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    Dim icex As InitCommonControlsEx
    icex.dwSize = SizeOf(InitCommonControlsEx)
    
    ''create status bar
    icex.dwICC = ICC_BAR_CLASSES
    InitCommonControlsEx(@icex)
    If (CreateWindowEx(WS_EX_STATICEDGE, STATUSCLASSNAME, NULL, (SBARS_SIZEGRIP Or SBARS_TOOLTIPS Or WS_CHILD Or WS_VISIBLE), CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, hDlg, Cast(HMENU, IDC_SBR_MAIN), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''create main listview
    icex.dwICC = ICC_LISTVIEW_CLASSES
    InitCommonControlsEx(@icex)
    If (CreateWindowEx((LVS_EX_GRIDLINES Or WS_EX_CLIENTEDGE Or WS_EX_CONTROLPARENT Or WS_EX_RIGHT), WC_LISTVIEW, NULL, (LVS_NOSORTHEADER Or LVS_REPORT Or LVS_SINGLESEL Or WS_CHILD Or WS_TABSTOP Or WS_VISIBLE Or WS_VSCROLL), 0, 0, 100, 100, hDlg, Cast(HMENU, IDC_LIV_MAIN), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''return
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
Private Function BrowseForFile (ByVal hDlg As HWND, ByVal pFni As FILENAMEINFO Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"pFni\t= 0x"; Hex(pfni)
    #EndIf
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(hInstance, IDC_WAIT))
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, SizeOf(OPENFILENAME), (SizeOf(OPENFILENAME) + CB_FILTER))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''load file filter
    Dim lpszFilt As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_FILTER))
    If (lpszFilt = NULL) Then Return(FALSE)
    If (LoadString(hInstance, IDS_FILTER, lpszFilt, CCH_FILTER) = 0) Then Return(FALSE)
    
    ''init ofn structure
    Dim lpOfn As LPOPENFILENAME = Cast(LPOPENFILENAME, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(OPENFILENAME)))
    If (lpOfn = NULL) Then Return(FALSE)
    With *lpOfn
        .lStructSize        = SizeOf(OPENFILENAME)
        .hwndOwner          = hDlg
        .lpstrFilter        = Cast(LPCTSTR, lpszFilt)
        .nFilterIndex       = 1
        .lpstrFile          = pFni->lpszFile
        .nMaxFile           = MAX_PATH
        .lpstrFileTitle     = pFni->lpszFileTitle
        .nMaxFileTitle      = MAX_PATH
        .Flags              = (OFN_DONTADDTORECENT Or OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST)
        .nFileOffset        = pFni->cchFileOffset
        .nFileExtension     = pFni->cchExtOffset
    End With
    
    ''restore cursor
    SetCursor(hCurPrev)
    
    If (GetOpenFileName(lpOfn)) Then
        If (lpOfn->Flags And OFN_READONLY) Then
            pFni->bReadOnly = TRUE
        Else
            pFni->bReadOnly = FALSE
        End If
    End If
    
    ''set waiting cursor
    hCurPrev = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''free memory
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpOfn)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszFilt)) = FALSE) Then Return(FALSE)
    
    ''destroy the local heap
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    
    ''restore cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

/'updates the main dialog's title bar
    hDlg:HWND           -   Handle to the main window.
    lpszFile:LPCTSTR    -   File name to use to set the file title to. Uses
                            the form "<app name> - [<file name>]". If this is
                            NULL, then the title is reset.
'/
Private Function SetMainWndTitle (ByVal hDlg As HWND, ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, CB_APPNAME, (CB_APPNAME + (MAX_PATH * SizeOf(TCHAR)) + (5 * SizeOf(TCHAR))))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''load app name
    Dim lpszAppName As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME))
    If (lpszAppName = NULL) Then Return(FALSE)
    If (LoadString(hInstance, IDS_APPNAME, lpszAppName, CCH_APPNAME) = 0) Then Return(FALSE)
    
    ''if no file name is specified, then set the title to the app name
    If (lpszFile = NULL) Then
        If (SetWindowText(hDlg, Cast(LPCTSTR, lpszAppName)) = FALSE) Then Return(FALSE)
        
        ''restore cursor
        SetCursor(hCurPrev)
        
        ''return
        SetLastError(ERROR_SUCCESS)
        Return(TRUE)
    End If
    
    ''format new window title
    Dim cchTitle As ULONG32 = (CCH_APPNAME + MAX_PATH + 5) ''5 is the size of the " - [" & "]" strings in chars
    Dim lpszTitle As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (cchTitle * SizeOf(TCHAR)))))
    If (lpszTitle = NULL) Then Return(FALSE)
    *lpszTitle = (*lpszAppName + " - [" + *lpszFile + "]")
    
    ''update the window title
    If (SetWindowText(hDlg, Cast(LPCTSTR, lpszTitle)) = FALSE) Then Return(FALSE)
    
    ''return
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszAppName)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszTitle)) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetCursor(hCurPrev)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

/'used to set up file access rights by MainProc
    bReadOnly:BOOL      - File is read only?
    dwAccess:DWORD32    - Buffer to fill with access rights.
    dwShare:DWORD32     - Buffer to fill with sharing rights.
'/
Private Sub SetupFileRights (ByVal bReadOnly As BOOL, ByRef dwAccess As DWORD32, ByRef dwShare As DWORD32)
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"bReadOnly\t= "; bReadOnly
        ? !"dwAccess\t= "; dwAccess
        ? !"dwShare\t= "; dwShare
    #EndIf
    
    If (bReadOnly = TRUE) Then
        dwAccess = GENERIC_READ
        dwShare = (FILE_SHARE_WRITE Or FILE_SHARE_READ Or FILE_SHARE_DELETE)
    Else
        dwAccess = (GENERIC_READ Or GENERIC_WRITE)
        dwShare = FILE_SHARE_READ
    End If

End Sub

''display the about message box
Private Function AboutMsgBox (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, CB_ABT, ((C_ABT * CB_ABT) + SizeOf(MSGBOXPARAMS)))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''load unformatted strings
    Dim plpszUnformatted As LPTSTR Ptr
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    SetLastError(Cast(DWORD32, LoadStringRange(hInstance, plpszUnformatted, IDS_APPNAME, CCH_ABT, C_ABT)))
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
    
    ''init message box params
    Dim lpMbp As LPMSGBOXPARAMS = Cast(LPMSGBOXPARAMS, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(MSGBOXPARAMS))))
    If (lpMbp = NULL) Then Return(FALSE)
    With *lpMbp
        .cbSize         = SizeOf(MSGBOXPARAMS)
        .hwndOwner      = hDlg
        .hInstance      = hInstance
        .lpszText       = Cast(LPCTSTR, lpszFormatted)
        .lpszCaption    = Cast(LPCTSTR, plpszUnformatted[ABT_APPNAME])
        .dwStyle        = MB_USERICON
        .lpszIcon       = MAKEINTRESOURCE(IDI_KAZUSOFT)
        .dwLanguageId   = MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US)
    End With
    
    ''restore cursor
    hCurPrev = SetCursor(hCurPrev)
    
    ''display message box
    If (MessageBoxIndirect(lpMbp) <> IDOK) Then Return(FALSE)
    
    ''set waiting cursor
    hCurPrev = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''return
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpMbp)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszFormatted)) = FALSE) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetCursor(hCurPrev)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''Initializes the main dialog's child windows
Private Function InitMainChildren (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''set a loading cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_APPSTARTING))
    
    ''init status bar
    SetLastError(InitMainStatusBar(GetDlgItem(hDlg, IDC_SBR_MAIN)))
    If (GetLastError()) Then Return(FALSE)
    
    ''init Header ListView
    SetLastError(InitHeadListView(GetDlgItem(hDlg, IDC_LIV_MAIN)))
    If (GetLastError()) Then Return(FALSE)
    
    ''restore cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function UpdateMainUI (ByVal hDlg As HWND, ByVal pFni As FILENAMEINFO Ptr, ByVal pVgmHead As VGM_HEADER Ptr, ByVal bShowFullPath As BOOL) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"pFni\t= 0x"; Hex(pFni)
        ? !"pVgmHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    ''update title bar
    If (bShowFullPath) Then
        If (SetMainWndTitle(hDlg, Cast(LPCTSTR, pFni->lpszFile)) = FALSE) Then Return(FALSE)
    Else
        If (SetMainWndTitle(hDlg, Cast(LPCTSTR, pFni->lpszFileTitle)) = FALSE) Then Return(FALSE)
    End If
    
    ''update listview
    SetLastError(UpdateHeadListView(GetDlgItem(hDlg, IDC_LIV_MAIN), pVgmHead))
    If (GetLastError()) Then Return(FALSE)
    
    ''update the statusbar
    SetLastError(UpdateMainStatusBar(GetDlgItem(hDlg, IDC_SBR_MAIN), pVgmHead->dwVersion, pFni->bReadOnly))
    If (GetLastError()) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
