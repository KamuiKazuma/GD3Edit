
#Include "header.bi"

Public Function InitFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap, 8)
        ? !"pFni\t= 0x"; Hex(pFni, 8)
    #EndIf
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    /'
    ''allocate file name
    pFni->lpszFile = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
    If (pFni->lpszFile = NULL) Then Return(GetLastError())
    
    
    ''allocate file title
    pFni->lpszFileTitle = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
    If (pFni->lpszFileTitle = NULL) Then Return(GetLastError())
    '/
    
    With *pFni
        .lpszFile = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
        If (.lpszFile = NULL) Then Return(GetLastError())
        #If __FB_DEBUG__
            ? !"lpszFile\t= 0x"; Hex(.lpszFile, 8)
        #EndIf
        
        .lpszFileTitle = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
        If (pFni->lpszFileTitle = NULL) Then Return(GetLastError())
        #If __FB_DEBUG__
            ? !"lpszFileTitle\t= 0x"; Hex(.lpszFileTitle, 8)
        #EndIf
    End With
    
    ''unlock the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Public Function FreeFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap, 8)
        ? !"pFni\t= 0x"; Hex(pFni, 8)
    #EndIf
    
    ''get a lock on the heap, this also verifies its existence
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''free sub items
    With *pFni
        If (HeapFree(hHeap, NULL, Cast(LPVOID, .lpszFile)) = FALSE) Then Return(GetLastError())
        If (HeapFree(hHeap, NULL, Cast(LPVOID, .lpszFileTitle)) = FALSE) Then Return(GetLastError())
    End With
    
    ''unlock & destroy the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

''EOF
