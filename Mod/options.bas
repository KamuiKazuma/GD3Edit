/'
    
    options.bas
    
'/

#Include "header.bi"
#Include "mod/errmsgbox/errmsgbox.bi"
'#Include "mod/openproghkey/openproghkey.bi"

Extern hInstance As HINSTANCE

Public Function StartOptionsMenu (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal nStartPage As LONG32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"nStartPage\t= "; nStartPage
    #EndIf
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, OPT_CB_HEAPMIN, OPT_CB_HEAPMAX)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    #If __FB_DEBUG__
        ? !"hHeap\t= 0x"; Hex(hHeap)
    #EndIf
    
    ''allocate space for the property sheet caption
    Dim lpszCaption As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, OPT_CB_CAPTION))
    If (lpszCaption = NULL) Then Return(GetLastError())
    #If __FB_DEBUG__
        ? !"lpszCaption\t= 0x"; Hex(lpszCaption)
    #EndIf
    
    ''load the property sheet caption
    If (LoadString(hInst, IDS_OPTIONS, lpszCaption, OPT_CCH_CAPTION) = 0) Then Return(GetLastError())
    #If __FB_DEBUG__
        ? !"*lpszCaption\t= "; *lpszCaption
    #EndIf
    
    ''allocate space for the property sheet pages
    Dim lpPsp As LPPROPSHEETPAGE = Cast(LPPROPSHEETPAGE, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, OPT_CB_PAGES))
    If (lpPsp = NULL) Then Return(GetLastError())
    ZeroMemory(lpPsp, OPT_CB_PAGES)
    #If __FB_DEBUG__
        ? !"lpPsp\t= 0x"; Hex(lpPsp)
    #EndIf
    
    ''setup general options page
    With lpPsp[OPT_PG_GENOPTS]
        .dwSize         = SizeOf(PROPSHEETPAGE)
        .dwFlags        = PSP_USEICONID
        .hInstance      = hInst
        .pszTemplate    = MAKEINTRESOURCE(IDD_GENOPTS)
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        '.pszTitle       = NULL
        .pfnDlgProc     = @GenOptsProc
        '.lParam         = NULL
        '.pfnCallback    = NULL
    End With
    
    ''allocate space for the property sheet header
    Dim lpPsh As LPPROPSHEETHEADER = Cast(LPPROPSHEETHEADER, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(PROPSHEETHEADER)))
    If (lpPsh = NULL) Then Return(GetLastError())
    #If __FB_DEBUG__
        ? !"lpPsh\t= 0x"; Hex(lpPsh)
    #EndIf
    
    ''setup the property sheet header
    nStartPage += 1
    With *lpPsh
        .dwSize         = SizeOf(PROPSHEETHEADER)
        .dwFlags        = (PSH_USEICONID Or PSH_PROPSHEETPAGE Or PSH_NOCONTEXTHELP Or PSH_HASHELP)
        .hwndParent     = hDlg
        .hInstance      = hInst
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pszCaption     = Cast(LPCTSTR, lpszCaption)
        .nPages         = OPT_C_PAGES
        .nStartPage     = nStartPage
        .ppsp           = Cast(LPCPROPSHEETPAGE, lpPsp)
        '.pfnCallback    = NULL
    End With
    
    ''start the property sheet
    PropertySheet(Cast(LPCPROPSHEETHEADER, lpPsh))
    
    ''free memory
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpPsh)) = FALSE) Then Return(GetLastError())
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpPsp)) = FALSE) Then Return(GetLastError())
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszCaption)) = FALSE) Then Return(GetLastError())
    
    ''destroy the local heap
    If (HeapDestroy(hHeap) = FALSE) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Private Function GenOptsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    Static hwndPrsht As HWND
    'Static bShowFullPaths As BOOL
    Static genOpts As GEN_OPTS
    
    Select Case uMsg
        Case WM_INITDIALOG
            
            Dim opts As OPTIONS
            If (LoadConfig(hInstance, @opts, CFG_GENOPTS) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError))
            genOpts = opts.general
            
        Case WM_COMMAND
            
            Select Case HiWord(wParam)
                
                Case BN_CLICKED
                    
                    Select Case LoWord(wParam)
                        
                        Case IDC_CHK_SHOWFULLPATH
                            
                            If (IsDlgButtonChecked(hWnd, LoWord(wParam)) = BST_CHECKED) Then
                                #If __FB_DEBUG__
                                    ? !"Checked button:\t0x"; Hex(LoWord(wParam), 4)
                                #EndIf
                                genOpts.bShowFullPath = TRUE
                            Else
                                #If __FB_DEBUG__
                                    ? !"Unchecked button:\t0x"; Hex(LoWord(wParam), 4)
                                #EndIf
                                genOpts.bShowFullPath = FALSE
                            End If
                            
                            SendMessage(hWnd, PSM_CHANGED, Cast(WPARAM, hwndPrsht), NULL)
                            
                    End Select
                    
            End Select
            
        Case WM_NOTIFY
            
            Select Case (Cast(LPNMHDR, lParam)->code)
                
                Case PSN_SETACTIVE
                    
                    ''get page handle
                    ''todo: use PSM_GETCURRENTPAGEHWND to get hwndPrsht
                    'hwndPrsht = Cast(HWND, Cast(LPNMHDR, lParam)->hwndFrom)
                    hwndPrsht = Cast(HWND, SendMessage(hWnd, PSM_GETCURRENTPAGEHWND, NULL, NULL))
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                    
                Case PSN_KILLACTIVE
                    
                    ''let page become inactive
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    
                Case PSN_APPLY
                    
                    
                    
                Case PSN_QUERYCANCEL
                    
                    ''let the property sheet close
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    
            End Select
            
        Case Else
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

Public Function LoadConfig (ByVal hInst As HINSTANCE, ByVal pOpts As OPTIONS Ptr, ByVal dwMask As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"pOpts\t= 0x"; Hex(pOpts)
        ? !"dwMask\t= 0x"; Hex(dwMask)
    #EndIf
    
    ''create a local heap
    Dim cSubKey As ULONG32
    If (GetSubKeyCount(dwMask, @cSubKey) = FALSE) Then Return(FALSE)
    Dim hHeap As HANDLE = HeapCreate(NULL, OPT_CB_SUBKEY, (OPT_CB_SUBKEY * cSubKey))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''open app registry key
    Dim hkProg As HKEY
    Dim dwDisp As DWORD32
    If (OpenProgHKey(hInst, @hkProg, IDS_APPNAME, KEY_READ, @dwDisp) = FALSE) Then Return(FALSE)
    
    If (dwDisp = REG_OPENED_EXISTING_KEY) Then
        
        ''load information from the registry
        If (dwMask And CFG_GENOPTS) Then
            If (LoadCfg_GenOpts(hInst, hHeap, hkProg, @pOpts->general) = FALSE) Then Return(FALSE)
        End If
        
    Else
        
        ''todo: write routine that sets defaults
        
    End If
    
    ''close the registry key
    SetLastError(RegCloseKey(hkProg))
    If (GetLastError()) Then Return(FALSE)
    
    ''destroy the local heap
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function LoadCfg_GenOpts (ByVal hInst As HINSTANCE, ByVal hHeap As HANDLE, ByVal hkProg As HKEY, ByVal pGenOpts As GEN_OPTS Ptr) As BOOL
    
    ''lock the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate a buffer for the sub-key names
    Dim plpszSubKey As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszSubKey), OPT_CB_SUBKEY, OPT_C_SUBKEY_GEN))
    If (GetLastError()) Then Return(FALSE)
    
    ''load the sub-key names
    SetLastError(LoadStringRange(hInst, plpszSubKey, IDS_REG_SHOWFULLPATH, OPT_CCH_SUBKEY, OPT_C_SUBKEY_GEN))
    If (GetLastError()) Then Return(FALSE)
    
    ''read from the registry
    Dim cbSize As DWORD32
    
    cbSize = SizeOf(pGenOpts->bShowFullPath)
    SetLastError(RegQueryValueEx(hkProg, plpszSubKey[0], NULL, NULL, Cast(LPBYTE, @pGenOpts->bShowFullPath), @cbSize))
    If (GetLastError()) Then Return(FALSE)
    
    ''free the buffer used for the sub-key names
    SetLastError(HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszSubKey), OPT_CB_SUBKEY, OPT_C_SUBKEY_GEN))
    If (GetLastError()) Then Return(FALSE)
    
    ''unlock the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function GetSubKeyCount (ByVal dwMask As DWORD32, ByVal pcSubKey As PULONG32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"dwMask\t= 0x"; Hex(dwMask)
        ? !"pcSubKey\t= 0x"; Hex(pcSubKey)
    #EndIf
    
    ''make sure pcSubKey is a valid pointer
    If (pcSubKey = NULL) Then
        SetLastError(ERROR_INVALID_PARAMETER)
        Return(FALSE)
    End If
    
    ''initialize value at pcSubKey if necessary
    If (*pcSubKey <> 0) Then ZeroMemory(pcSubKey, SizeOf(ULONG32))
    
    ''add up sub-keys
    If (dwMask And CFG_GENOPTS) Then *pcSubKey += OPT_C_SUBKEY_GEN
    If (dwMask And CFG_LVOPTS) Then *pcSubKey += OPT_C_SUBKEY_LV
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

/'Private Function LoadAppName (ByVal hInst As HINSTANCE, ByVal hHeap As HANDLE, ByVal lpszAppName As LPTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"lpszAppName\t= 0x"; Hex(lpszAppName)
    #EndIf
    
    ''lock the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate the app name
    lpszAppName = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME))
    If (lpszAppName = NULL) Then Return(FALSE)
    
    ''load the app name
    If (LoadString(hInst, IDS_APPNAME, lpszAppName, CCH_APPNAME) = 0) Then Return(FALSE)
    
    ''unlock the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function'/

Private Function OpenProgHKey (ByVal hInst As HINSTANCE, ByVal phkOut As PHKEY, ByVal wAppName As WORD, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"phkOut\t= 0x"; Hex(phkOut)
        ? !"wAppName\t= 0x"; Hex(wAppName)
        /'? !"lpszAppName\t= 0x"; Hex(lpszAppName)
        ? !"*lpszAppName\t= "; *lpszAppName
        ? !"lpszClass\t= 0x"; Hex(lpszClass)
        ? !"*lpszClass\t= "; *lpszClass'/
        ? !"samDesired\t= 0x"; Hex(samDesired)
        ? !"pdwDisp\t= 0x"; Hex(pdwDisp)
    #EndIf
    
    /' old version:
    ''declare local variables
    Dim hkSoftware As HKEY  ''hkey to HKEY_CURRENT_USER\"Software"
    
    ''open HKEY_CURRENT_USER\Software
    SetLastError(Cast(DWORD32, RegOpenKeyEx(HKEY_CURRENT_USER, "Software", NULL, samDesired, @hkSoftware)))
    If (GetLastError()) Then Return(FALSE)
    
    ''open/create HKEY_CURRENT_USER\"Software"\*lpszAppName
    SetLastError(Cast(DWORD32, RegCreateKeyEx(hkSoftware, lpszAppName, NULL, NULL, NULL, samDesired, NULL, phkOut, pdwDisp)))
    If (GetLastError()) Then Return(FALSE)
    
    ''close hkSoftware
    SetLastError(Cast(DWORD32, RegCloseKey(hkSoftware)))
    If (GetLastError()) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)'/
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, CB_APPNAME, CB_APPNAME)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''allocate a buffer for the app name
    Dim lpszAppName As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME))
    If (lpszAppName = NULL) Then Return(FALSE)
    
    ''load the app name
    If (LoadString(hInst, wAppName, lpszAppName, CCH_APPNAME) = 0) Then Return(FALSE)
    
    ''open hkey to HKEY_CURRENT_USER\Software
    Dim hkSoftware As HKEY
    SetLastError(RegOpenKeyEx(HKEY_CURRENT_USER, "Software", NULL, samDesired, @hkSoftware))
    If (GetLastError()) Then Return(FALSE)
    
    ''open the app's registry key
    SetLastError(RegCreateKeyEx(hkSoftware, Cast(LPCTSTR, lpszAppName), NULL, NULL, NULL, samDesired, NULL, phkOut, pdwDisp))
    If (GetLastError()) Then Return(FALSE)
    
    ''close app's parent registry key
    SetLastError(RegCloseKey(hkSoftware))
    If (GetLastError()) Then Return(FALSE)
    
    ''destroy the local heap
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
