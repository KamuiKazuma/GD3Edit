/'
    
    main.bas - main module
    
    GD3Edit
    
    Created with Kazusoft's Dialog App Template v2.4
    
    compile with:
        fbc -s gui "main.bas" "resource.res" -x "GD3Edit.exe"
    
'/

''make sure this is main module
#Ifndef __FB_MAIN__
    #Error "This file must be the main module."
#EndIf

''include header file
#Include "header.bi"

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
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hInstPrev\t= 0x"; Hex(hInstPrev, 8)
        ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine, 8)
        ? !"*lpszCmdLine\t= "; *lpszCmdLine
        ? !"nShowCmd\t= 0x"; hex(nShowCmd, 8)
    #EndIf
    
    ''declare local variables
    Dim msg As MSG                  ''message structure
    Dim wcxMainClass As WNDCLASSEX  ''class information for MainClass
    
    ''setup class information and register classes
    ZeroMemory(@wcxMainClass, SizeOf(WNDCLASSEX)) ''init memory for wcxMainClass
    With wcxMainClass                               ''setup class information for wcxMainClass
        .cbSize         = SizeOf(wcxMainClass)
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
    RegisterClassEx(@wcxMainClass)                  ''register MainClass
    
    ''get the default heap
    hHeap = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    ''start the main dialog
    StartMainDlg(nShowCmd, NULL)
    
    ''start message loop
    While (GetMessage(@msg, hWin, 0, 0) = TRUE)
        
        ''make sure msg is a valid dialog message
        If (IsDialogMessage(hWin, @msg) = FALSE) Then
            TranslateMessage(@msg)  ''translate msg into a dialog message
            DispatchMessage(@msg)   ''dispatch msg to system
        End If
        
    Wend
    
    ''unregister classes
    UnregisterClass(Cast(LPCTSTR, @MainClass), hInst)  ''unregister MainClass
    
    ''return exit code
    Return(msg.wParam)
    
End Function

''starts the main dialog, to be called only by WinMain, do not call this function.
Private Sub StartMainDlg (ByVal nShowCmd As INT32, ByVal lParam As LPARAM)
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"nShowCmd\t= 0x"; Hex(nShowCmd, 8)
        ? !"lParam\t= 0x"; Hex(lParam, 8)
    #EndIf
    
    ''create, show, and update the main dialog
    DialogBoxParam(hInstance, MAKEINTRESOURCE(IDD_MAIN), NULL, @MainProc, lParam)   ''create the main window
    hWin = FindWindow(Cast(LPCTSTR, @MainClass), NULL)                              ''find the main window
    ShowWindow(hWin, nShowCmd)                                                      ''show the main window
    SetForegroundWindow(hWin)                                                       ''move the main window to the foreground
    SetActiveWindow(hWin)                                                           ''set the main window as active
    UpdateWindow(hWin)                                                              ''update the main window
    
End Sub

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
                            
                        Case IDM_SAVE           ''menu/file/save
                            
                        Case IDM_SAVEAS         ''menu/file/save as
                            
                        Case IDM_EXIT           ''menu/file/exit
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_ABOUT          ''menu/about
                            
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
            If (GetClientRect(GetDlgItem(hWnd, IDC_SBR_MAIN), @rcSbr) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
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

''display the about message box
Private Function AboutMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
    #EndIf
    
    ''set loading cursor
    Dim hCursorPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
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
        .cbSize = SizeOf(MSGBOXPARAMS)
        .hwndOwner = hDlg
        .hInstance = hInst
        .lpszText = lpszFormatted
        .lpszCaption = plpszUnformatted[ABT_APPNAME]
        .dwStyle = MB_USERICON
        .lpszIcon = MAKEINTRESOURCE(IDI_KAZUSOFT)
        .dwLanguageId = MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US)
    End With
    
    ''restore previous cursor
    hCursorPrev = SetCursor(hCursorPrev)
    
    ''display message box
    If (MessageBoxIndirect(lpMbp) = 0) Then Return(FALSE)
    
    ''set loading cursor
    hCursorPrev = SetCursor(hCursorPrev)
    
    ''free memory
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpMbp)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszFormatted)) = FALSE) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszUnformatted), CB_ABT, C_ABT)))
    If (GetLastError()) Then Return(FALSE)
    
    ''restore previous cursor
    SetCursor(hCursorPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
