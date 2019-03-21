/'
    
    mainstatusbar.bas
    
'/

#Include "inc/mainstatusbar.bas"
'#Include "inc/vgmhead.bi" ''for TranslateBcdCodeVer
#Include "inc/translatevgmver.bi"

Extern hInstance As HINSTANCE

Public Function InitMainStatusBar (ByVal hWnd As HWND) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    ''setup parts information
    Dim pnPart As PLONG32 = Cast(PLONG32, LocalAlloc(LPTR, (C_SBR_PART_POS * SizeOf(LONG32))))
    If (pnPart = NULL) Then Return(GetLastError())
    pnPart[0] = SBR_PART_POS_VER
    pnPart[1] = SBR_PART_POS_READONLY
    pnPart[2] = SBR_PART_POS_END
    
    ''set parts
    If (SendMessage(hWnd, SB_SETPARTS, C_SBR_PART_POS, Cast(LPARAM, pnPart)) = FALSE) Then Return(-1)
    
    ''return
    If (LocalFree(Cast(HLOCAL, pnPart)) = NULL) Then Return(GetLastError())
    Return(ERROR_SUCCESS)
    
End Function

Public Function UpdateMainStatusBar (ByVal hWnd As HWND, ByVal dwBcdCode As DWORD32, ByVal bReadOnly As BOOL) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
        ? !"dwBcdCode\t= 0x"; Hex(dwBcdCode)
        ? !"bReadOnly\t= "; bReadOnly
    #EndIf
    
    ''setup items
    Dim hHeap As HANDLE = HeapCreate(NULL, (36 * SizeOf(TCHAR)), (36 * SizeOf(TCHAR)))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    Dim lpszVer As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (12 * SizeOf(TCHAR))
    If (lpszVer = NULL) Then Return(GetLastError())
    Dim (lpszReadOnly As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (24 * SizeOf(TCHAR))
    If (lpszReadOnly = NULL) Then Return(GetLastError())
    If (TranslateBcdCodeVer(dwBcdCode, lpszVer) = FALSE) Then Return(GetLastError())
    If (LoadString(hInstance, IDS_READONLY, lpszReadOnly, 24) = 0) Then Return(GetLastError())
    
    ''update statusbar
    SendMessage(hWnd, SB_SETTEXT, SBR_PART_VER, Cast(LPARAM, lpszVer))
    If (bReadOnly) Then
        SendMessage(hWnd, SB_SETTEXT, SBR_PART_READONLY, Cast(LPARAM, lpszReadOnly))
    End If
    
    ''return
    If (HeapFree(hHeap, NULL, lpszVer) = FALSE) Then Return(GetLastError())
    If (HeapFree(hHeap, NULL, lpszReadOnly) = FALSE) Then Return(GetLastError())
    If (HeapDestroy(hHeap) = FALSE) Then Return(GetLastError())
    Return(ERROR_SUCCESS)
    
End Function

''EOF
