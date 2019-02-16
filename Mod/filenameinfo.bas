/'
    
    filenameinfo.bas
    
    FileNameInfo Module
    
    Compile with:
        fbc -c ".\Inc\filenameinfo.bas"
    
'/

#Include "header.bi"

Public Function InitFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap, 8)
        ? !"pFni\t= 0x"; Hex(pFni, 8)
    #EndIf
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''allocate items
    With *pFni
        ''allocate file
        .lpszFile = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
        If (.lpszFile = NULL) Then Return(GetLastError())
        
        ''allocate file title
        .lpszFileTitle = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
        If (.lpszFileTitle = NULL) Then Return(GetLastError())
        
        ''allocate file extention
        .lpszExt = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, FNI_CBFILE))
        If (.lpszExt = NULL) Then Return(GetLastError())
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
    
    ''free items
    With *pFni
        If (HeapFree(hHeap, NULL, Cast(LPVOID, .lpszFile)) = FALSE) Then Return(GetLastError())
        If (HeapFree(hHeap, NULL, Cast(LPVOID, .lpszFileTitle)) = FALSE) Then Return(GetLastError())
        If (HeapFree(hHeap, NULL, Cast(LPVOID, .lpszExt)) = FALSE) Then Return(GetLastError())
    End With
    
    ''unlock & destroy the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

''EOF
