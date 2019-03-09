/'
    
    filenameinfo.bas
    
    FileNameInfo Module
    
    Compile with:
        fbc -c ".\Inc\filenameinfo.bas"
    
'/

#Include "header.bi"

Public Function InitFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"pFni\t= 0x"; Hex(pFni)
    #EndIf
    
    If (pFni = NULL) Then Return(ERROR_INVALID_PARAMETER)
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''allocate items
    With *pFni
        .lpszFile = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
        If (.lpszFile = NULL) Then Return(GetLastError())
        .lpszFileTitle = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
        If (.lpszFileTitle = NULL) Then Return(GetLastError())
    End With
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    Return(ERROR_SUCCESS)
    
End Function

Public Function FreeFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"pFni\t= 0x"; Hex(pFni)
    #EndIf
    
    If (pFni = NULL) Then Return(ERROR_INVALID_PARAMETER)
    
    ''get a lock on the heap, this also verifies its existence
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''free items
    With *pFni
        If (HeapFree(hHeap, NULL, Cast(LPVOID, .lpszFile)) = FALSE) Then Return(GetLastError())
        If (HeapFree(hHeap, NULL, Cast(LPVOID, .lpszFileTitle)) = FALSE) Then Return(GetLastError())
    End With
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    Return(ERROR_SUCCESS)
    
End Function

Public Function ClearFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"pFni\t= 0x"; Hex(pFni)
    #EndIf
    
    If (pFni = NULL) Then Return(ERROR_INVALID_PARAMETER)
    
    ''get a lock on the heap, this also verifies its existence
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''re-init fni
    ZeroMemory(@pFni->lpszFile, FNI_CBFILE)
    ZeroMemory(@pFni->lpszFileTitle, FNI_CBFILE)
    ZeroMemory(@pFni->cchFileOffset, ((2 * SizeOf(ULONG32)) + SizeOf(BOOL)))
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    Return(ERROR_SUCCESS) 
    
End Function

''EOF
