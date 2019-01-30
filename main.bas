/'
    
    main.bas - main module
    
    
    
    Created with Kazusoft's Dialog App Template v2.4
    
    compile with:
        fbc -s gui "main.bas" "resource.rc"
    
'/

''make sure this is main module
#Ifndef __FB_MAIN__
    #Error "This file must be the main module."
#EndIf

''include header file
#Include "header.bi"

hInstance   = GetModuleHandle(NULL) ''get a handle to this module's instance
lpszCmdLine = GetCommandLine()      ''get the command-line parameters
''InitCommonControls()

Dim uExitCode As UINT32 = Cast(UINT32, WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL))

#If __FB_DEBUG__
    ? "uExitCode", "= 0x"; Hex(uExitCode, 8)
#EndIf

ExitProcess(uExitCode)
End (uExitCode)

''main function
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? "hInst", "= 0x"; Hex(hInst, 8)
        ? "hInstPrev", "= 0x"; Hex(hInstPrev, 8)
        ? "lpszCmdLine", "= 0x"; Hex(lpszCmdLine, 8)
        ? "*lpszCmdLine:", *lpszCmdLine
        ? "nShowCmd", "= 0x"; Hex(nShowCmd, 8)
    #EndIf
    
    ''declare local variables
    Dim msg As MSG                  ''message structure
    Dim wcxMainClass As WNDCLASSEX  ''class information for MainClass
    
    ''setup class information and register classes
    ZeroMemory(@wcxMainClass, SizeOf(wcxMainClass)) ''init memory for wcxMainClass
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
        .lpszClassName  = @MainClass
        .hIconSm        = .hIcon
    End With
    RegisterClassEx(@wcxMainClass)                  ''register MainClass
    
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
    UnregisterClass(@MainClass, hInst)  ''unregister MainClass
    
    ''return exit code
    Return(msg.wParam)
    
End Function

''starts the main dialog, to be called only by WinMain, do not call this function.
Private Sub StartMainDlg (ByVal nShowCmd As INT32, ByVal lParam As LPARAM)
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? "nShowCmd", "= 0x"; Hex(nShowCmd, 8)
        ? "lParam", "= 0x"; Hex(lParam, 8)
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
            
        Case WM_DESTROY     ''destroy the dialog
            
            ''post quit message
            PostQuitMessage(ERROR_SUCCESS)
            
        Case WM_INITDIALOG  ''initialize the dialog
            
        Case WM_CLOSE       ''dialog's close button is pressed
            
            ''destroy main window
            DestroyWindow(hWnd)
            
        Case WM_COMMAND     ''command
            Select Case HiWord(lParam)  ''command code
                Case BN_CLICKED         ''button clicked
                    Select Case LoWord(lParam)  ''button id
                        Case IDM_OPEN           ''menu/file/open
                            
                        Case IDM_SAVE           ''menu/file/save
                            
                        Case IDM_SAVEAS         ''menu/file/save as
                            
                        Case IDM_EXIT           ''menu/file/exit
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                    End Select
                    
            End Select
            
        Case Else           ''otherwise
            
            ''use the default window procedure to return a value
            Return(DefWindowProc(hWnd, uMsg, wParam, lParam))
            
    End Select
    
    ''return success code (0)
    Return(ERROR_SUCCESS)
    
End Function

''EOF
