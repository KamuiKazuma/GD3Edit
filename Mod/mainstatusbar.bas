
#Include "header.bi"

Public Function InitMainStatusBar (ByVal hWnd As HWND) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, (C_SBR_PART * SizeOf(ULONG32)), (C_SBR_PART * SizeOf(LONG32)))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    ''setup parts information
    Dim pnPart As PLONG32 = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (C_SBR_PART * SizeOf(LONG32)))
    If (pnPart = NULL) Then Return(GetLastError())
    pnPart[0] = SBR_PART_POS_VER
    pnPart[1] = SBR_PART_POS_READONLY
    pnPart[2] = SBR_PART_POS_END
    
    ''set parts
    If (SendMessage(hWnd, SB_SETPARTS, C_SBR_PART_POS, Cast(LPARAM, pnPart)) = FALSE) Then Return(-1)
    
    ''return
    If (HeapFree(hHeap, NULL, Cast(LPVOID, pnPart)) = FALSE) Then Return(GetLastError())
    If (HeapDestroy(hHeap) = FALSE) Then Return(GetLastError())
    Return(ERROR_SUCCESS)
    
End Function

Public Function SetSbrItemTextId (ByVal hWnd As HWND, ByVal hInst As HINSTANCE, ByVal dwPartId As DWORD32, ByVal wTextId As WORD, ByVal cchText As ULONG32) As BOOL
    
    ''validate parameters
    If ((hWnd = INVALID_HANDLE_VALUE) Or (hInst = INVALID_HANDLE_VALUE)) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    If ((cchText = 0) Or (dwPartId > C_SBR_PART)) Then
        SetLastError(ERROR_INVALID_PARAMETER)
        Return(FALSE)
    End If
    
    ''load the string
    Dim lpszText As LPTSTR = LocalAlloc(LPTR, (cchText * SizeOf(TCHAR)))
    If (lpszText = NULL) Then Return(FALSE)
    If (LoadString(hInst, wTextId, lpszText, cchText) = 0) Then Return(FALSE)
    
    ''set the text
    If (SendMessage(hWnd, SB_SETTEXT, dwPartId, Cast(LPARAM, lpszText)) = FALSE) Then Return(FALSE)
    
    ''return
    LocalFree(Cast(HLOCAL, lpszText))
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
