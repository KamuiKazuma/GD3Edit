
#Include "header.bi"

Public Function InitConfig (ByVal hHeap As HANDLE, ByVal pCfg As CONFIG Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap, 8)
        ? !"pCfg\t= 0x"; Hex(pCfg, 8)
    #EndIf
    
    If (hHeap) Then Return(ERROR_INVALID_PARAMETER)
    If (pCfg) Then Return(ERROR_INVALID_PARAMETER)
    
    hHeap = HeapCreate(NULL, SizeOf(CONFIG), (SizeOf(CONFIG) + CB_CUSTFILT))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    pCfg = Cast(CONFIG Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(CONFIG)))
    If (pCfg = NULL) Then Return(GetLastError())
    
    pCfg->lpszCustFilt = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_CUSTFILT))
    If (pCfg->lpszCustFilt = NULL) Then Return(GetLastError())
    
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    
    Return(ERROR_SUCCESS)
    
End Function
