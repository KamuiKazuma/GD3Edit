/'
    
    options.bas
    
'/

#Include "header.bi"
#Include "mod/heapptrlist/heapptrlist.bi"
#Include "mod/errmsgbox/errmsgbox.bi"

Public Function StartOptionsMenu (ByVal hDlg As HWND, ByVal nStartPage As LONG32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInstance\t= 0x"; Hex(hInstance)
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
    If (LoadString(hInstance, IDS_OPTIONS, lpszCaption, OPT_CCH_CAPTION) = 0) Then Return(GetLastError())
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
        .hInstance      = hInstance
        .pszTemplate    = MAKEINTRESOURCE(IDD_GENOPTS)
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pfnDlgProc     = @GenOptsProc
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
        .hInstance      = hInstance
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pszCaption     = Cast(LPCTSTR, lpszCaption)
        .nPages         = OPT_C_PAGES
        .nStartPage     = nStartPage
        .ppsp           = Cast(LPCPROPSHEETPAGE, lpPsp)
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
    Static genOpts As OPTS_GEN
    
    Select Case uMsg
        Case WM_INITDIALOG
            
            Dim opts As OPTIONS
            If (LoadConfig(@opts, CFG_GENERAL) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError))
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

Public Function LoadConfig (ByVal pOpts As OPTIONS Ptr, ByVal dwMask As DWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"pOpts\t= 0x"; Hex(pOpts)
        ? !"dwMask\t= 0x"; Hex(dwMask)
    #EndIf
    
    ''create a local heap
    Dim cSubKey As ULONG32
    If (GetSubKeyCount(dwMask, @cSubKey) = FALSE) Then Return(GetLastError())
    Dim hHeap As HANDLE = HeapCreate(NULL, OPT_CB_SUBKEY, (OPT_CB_SUBKEY * cSubKey))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    ''open app registry key
    Dim hkProg As HKEY
    Dim dwDisp As DWORD32
    If (OpenProgHKey(@hkProg, IDS_APPNAME, KEY_READ, @dwDisp) = FALSE) Then Return(GetLastError())
    
    If (dwDisp = REG_OPENED_EXISTING_KEY) Then
        
        ''load information from the registry
        If (dwMask And CFG_GENERAL) Then
            If (LoadCfg_GenOpts(hHeap, hkProg, @pOpts->general) = FALSE) Then Return(GetLastError())
        End If
        
    Else
        
        ''todo: write routine that sets defaults
        
    End If
    
    ''close the registry key
    SetLastError(RegCloseKey(hkProg))
    If (GetLastError()) Then Return(GetLastError())
    
    ''destroy the local heap
    If (HeapDestroy(hHeap) = FALSE) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Private Function LoadCfg_GenOpts (ByVal hHeap As HANDLE, ByVal hkProg As HKEY, ByVal pGenOpts As OPTS_GEN Ptr) As BOOL
    
    ''lock the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate a buffer for the sub-key names
    Dim plpszSubKey As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszSubKey), OPT_CB_SUBKEY, OPT_C_SUBKEY_GEN))
    If (GetLastError()) Then Return(FALSE)
    
    ''load the sub-key names
    SetLastError(LoadStringRange(hInstance, plpszSubKey, IDS_REG_SHOWFULLPATH, OPT_CCH_SUBKEY, OPT_C_SUBKEY_GEN))
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
    If (dwMask And CFG_GENERAL) Then *pcSubKey += OPT_C_SUBKEY_GEN
    If (dwMask And CFG_LVHEAD) Then *pcSubKey += OPT_C_SUBKEY_LVHEAD
    
    #If __FB_DEBUG__
        ? !"*pcSubKey\t= "; *pcSubKey
    #EndIf
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function OpenProgHKey (ByVal phkOut As PHKEY, ByVal wAppName As WORD, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"phkOut\t= 0x"; Hex(phkOut)
        ? !"wAppName\t= 0x"; Hex(wAppName)
        ? !"samDesired\t= 0x"; Hex(samDesired)
        ? !"pdwDisp\t= 0x"; Hex(pdwDisp)
    #EndIf
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, CB_APPNAME, CB_APPNAME)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''allocate a buffer for the app name
    Dim lpszAppName As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME))
    If (lpszAppName = NULL) Then Return(FALSE)
    
    ''load the app name
    If (LoadString(hInstance, wAppName, lpszAppName, CCH_APPNAME) = 0) Then Return(FALSE)
    
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
