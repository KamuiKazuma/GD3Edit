
#Include "header.bi"
#Include "mod/heapptrlist/heapptrlist.bi"

''private function declarations
Declare Function InitHeadListViewColumns (ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL
Declare Function InitHeadListViewItemNames (ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL

Declare Function ConvHeadItemsDec (ByVal hHeap As HANDLE, ByVal plpszDec As LPTSTR Ptr, ByVal pVgmHead As VGM_HEADER Ptr) As BOOL
Declare Function ConvHeadItemsHex (ByVal hHeap As HANDLE, ByVal plpszHex As LPTSTR Ptr, ByVal pVgmHead As VGM_HEADER Ptr) As BOOL

Declare Function UpdateHeadItemsDec (ByVal hWnd As HWND, ByVal hHeap As HANDLE, ByVal plpszDec As LPTSTR Ptr) As BOOL
Declare Function UpdateHeadItemsHex (ByVal hWnd As HWND, ByVal hHeap As HANDLE, ByVal plpszHex As LPTSTR Ptr) As BOOL


Public Function InitHeadListView (ByVal hWnd As HWND) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, NULL, CB_IHLV_MAX)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    ''initialize the listview
    If (InitHeadListViewColumns(hHeap, hWnd) = FALSE) Then Return(GetLastError())
    If (InitHeadListViewItemNames(hHeap, hWnd) = FALSE) Then Return(GetLastError())
    
    ''return
    If (HeapDestroy(hHeap) = FALSE) Then Return(GetLastError())
    Return(ERROR_SUCCESS)
    
End Function

Private Function InitHeadListViewColumns (ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''initialize column info structures
    Dim lpLvc As LPLVCOLUMN = Cast(LPLVCOLUMN, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (C_LVH_HEAD * SizeOf(LVCOLUMN))))
    If (lpLvc = NULL) Then Return(FALSE)
    For iCol As UINT32 = 0 To (C_LVH_HEAD - 1)
        With lpLvc[iCol]
            .mask       = (LVCF_WIDTH Or LVCF_SUBITEM)
            .cx         = 110 ''eventually this value should be loaded from the registry
            .iSubItem   = iCol
        End With
    Next iCol
    
    ''create the columns
    SendMessage(hWnd, WM_SETREDRAW, FALSE, NULL)
    For iCol As UINT32 = 0 To (C_LVH_HEAD - 1)
        If (SendMessage(hWnd, LVM_INSERTCOLUMN, iCol, Cast(LPARAM, @lpLvc[iCol])) = -1) Then Return(FALSE)
    Next iCol
    SendMessage(hWnd, WM_SETREDRAW, TRUE, NULL)
    
    ''load the column headings
    Dim plpszHead As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszHead), CB_LVH_HEAD, C_LVH_HEAD))
    If (GetLastError()) Then Return(FALSE)
    SetLastError(LoadStringRange(hInstance, plpszHead, IDS_LVH_HEAD_NAME, CCH_LVH_HEAD, C_LVH_HEAD))
    If (GetLastError()) Then Return(FALSE)
    
    ''re-init the column info structure
    ZeroMemory(lpLvc, (C_LVH_HEAD * SizeOf(LVCOLUMN)))
    For iCol As UINT32 = 0 To (C_LVH_HEAD - 1)
        With lpLvc[iCol]
            .mask       = (LVCF_FMT Or LVCF_TEXT Or LVCF_SUBITEM)
            .iSubItem   = iCol
            .pszText    = plpszHead[iCol]
            If (iCol = 0) Then
                .fmt    = LVCFMT_LEFT
            Else
                .fmt    = LVCFMT_RIGHT
            End If
        End With
    Next iCol
    
    ''set the column items
    SendMessage(hWnd, WM_SETREDRAW, FALSE, NULL)
    For iCol As UINT32 = 0 To (C_LVH_HEAD - 1)
        If (SendMessage(hWnd, LVM_SETCOLUMN, iCol, Cast(LPARAM, @lpLvc[iCol])) = FALSE) Then Return(FALSE)
    Next iCol
    SendMessage(hWnd, WM_SETREDRAW, TRUE, NULL)
    
    ''free the column structure & headings
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpLvc)) = FALSE) Then Return(FALSE)
    SetLastError(HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszHead), CB_LVH_HEAD, C_LVH_HEAD))
    If (GetLastError()) Then Return(FALSE)
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function InitHeadListViewItemNames (ByVal hHeap As HANDLE, ByVal hWnd As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''init listview item info structures
    Dim lpLvi As LPLVITEM = Cast(LPLVITEM, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(LVITEM)))
    If (lpLvi = NULL) Then Return(FALSE)
    
    ''load listview item names
    Dim plpszItem As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszItem), CB_LVI_HEAD, C_LVI_HEAD))
    If (GetLastError()) Then Return(FALSE)
    SetLastError(LoadStringRange(hInstance, plpszItem, IDS_LVI_HEAD_VGMVER, CCH_LVI_HEAD, C_LVI_HEAD))
    If (GetLastError()) Then Return(FALSE)
    
    lpLvi->mask = LVIF_TEXT
    SendMessage(hWnd, WM_SETREDRAW, FALSE, NULL)
    For iItem As INT32 = 0 To (C_LVI_HEAD - 1)
        lpLvi->iItem     = iItem
        lpLvi->pszText   = plpszItem[iItem]
        If (SendMessage(hWnd, LVM_INSERTITEM, NULL, Cast(LPARAM, lpLvi)) = -1) Then Return(FALSE)
        SendMessage(hWnd, LVM_ENSUREVISIBLE, iItem, TRUE)
    Next iItem
    SendMessage(hWnd, WM_SETREDRAW, TRUE, NULL)
    
    ''free listview item names and the item structure
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpLvi)) = FALSE) Then Return(FALSE)
    SetLastError(HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszItem), CB_LVI_HEAD, C_LVI_HEAD))
    If (GetLastError()) Then Return(FALSE)
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Public Function UpdateHeadListView (ByVal hWnd As HWND, ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
        ? !"pVgmHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    ''set a loading cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    If (hCurPrev = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, (SizeOf(LVITEM) + (C_LVI_HEAD * CB_LVIVALDEC) + (C_LVI_HEAD * CB_LVIVALHEX)), ((2 * (C_LVI_HEAD * SizeOf(LVITEM))) + (C_LVI_HEAD * CB_LVIVALDEC) + (C_LVI_HEAD * CB_LVIVALHEX)))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    ''allocate strings
    Dim plpszDec As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszDec), CB_LVIVALDEC, C_LVI_HEAD))
    If (GetLastError()) Then Return(GetLastError())
    Dim plpszHex As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszHex), CB_LVIVALHEX, C_LVI_HEAD))
    If (GetLastError()) Then Return(GetLastError())
    
    ''translate items into decimal & hex
    If (ConvHeadItemsDec(hHeap, plpszDec, pVgmHead) = FALSE) Then Return(FALSE)
    If (ConvHeadItemsHex(hHeap, plpszHex, pVgmHead) = FALSE) Then Return(FALSE)
    
    ''update listview
    If (UpdateHeadItemsDec(hWnd, hHeap, plpszDec) = FALSE) Then Return(FALSE)
    If (UpdateHeadItemsHex(hWnd, hHeap, plpszHex) = FALSE) Then Return(FALSE)
    
    ''free strings
    SetLastError(HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszDec), CB_LVIVALDEC, C_LVI_HEAD))
    If (GetLastError()) Then Return(GetLastError())
    SetLastError(HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszHex), CB_LVIVALHEX, C_LVI_HEAD))
    If (GetLastError()) Then Return(GetLastError())
    
    ''return
    If (HeapDestroy(hHeap) = FALSE) Then Return(GetLastError())
    Return(ERROR_SUCCESS)
    
End Function

Private Function ConvHeadItemsDec (ByVal hHeap As HANDLE, ByVal plpszDec As LPTSTR Ptr, ByVal pVgmHead As VGM_HEADER Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"plpszDec\t= 0x"; Hex(plpszDec)
        ? !"pVgmHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    ''lock the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''translate the items
    *plpszDec[LVI_HEAD_VGMVER] = Str(pVgmHead->dwVersion)
    *plpszDec[LVI_HEAD_LOOPBASE] = Str(pVgmHead->LoopBase)
    *plpszDec[LVI_HEAD_LOOPMOD] = Str(pVgmHead->LoopModifier)
    *plpszDec[LVI_HEAD_LOOPSAMP] = Str(pVgmHead->dwLoopSamples)
    *plpszDec[LVI_HEAD_TOTALSAMP] = Str(pVgmHead->dwTotalSamples)
    *plpszDec[LVI_HEAD_VOLMOD] = Str(pVgmHead->VolumeModifier)
    *plpszDec[LVI_HEAD_RATE] = Str(pVgmHead->dwRate)
    *plpszDec[LVI_HEAD_EOFOFF] = Str(pVgmHead->dwEOFOffset)
    *plpszDec[LVI_HEAD_GD3OFF] = Str(pVgmHead->dwGD3Offset)
    *plpszDec[LVI_HEAD_LOOPOFF] = Str(pVgmHead->dwLoopOffset)
    *plpszDec[LVI_HEAD_EXTOFF] = Str(pVgmHead->dwExtraOffset)
    
    ''unlock the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function ConvHeadItemsHex (ByVal hHeap As HANDLE, ByVal plpszHex As LPTSTR Ptr, ByVal pVgmHead As VGM_HEADER Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"plpszHex\t= 0x"; Hex(plpszHex)
        ? !"pVgmHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    ''lock the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''translate items into hex
    *plpszHex[LVI_HEAD_VGMVER] = Hex(pVgmHead->dwVersion, 8)
    *plpszHex[LVI_HEAD_LOOPBASE] = Hex(pVgmHead->LoopBase, 2)
    *plpszHex[LVI_HEAD_LOOPMOD] = Hex(pVgmHead->LoopModifier, 2)
    *plpszHex[LVI_HEAD_LOOPSAMP] = Hex(pVgmHead->dwLoopSamples, 8)
    *plpszHex[LVI_HEAD_TOTALSAMP] = Hex(pVgmHead->dwTotalSamples, 8)
    *plpszHex[LVI_HEAD_VOLMOD] = Hex(pVgmHead->VolumeModifier, 2)
    *plpszHex[LVI_HEAD_RATE] = Hex(pVgmHead->dwRate, 8)
    *plpszHex[LVI_HEAD_EOFOFF] = Hex(pVgmHead->dwEofOffset, 8)
    *plpszHex[LVI_HEAD_GD3OFF] = Hex(pVgmHead->dwGD3Offset, 8)
    *plpszHex[LVI_HEAD_LOOPOFF] = Hex(pVgmHead->dwLoopOffset, 8)
    *plpszHex[LVI_HEAD_EXTOFF] = Hex(pVgmHead->dwExtraOffset, 8)
    
    ''add leading "0x" characters
    For iStr As UINT32 = 0 To (C_LVI_HEAD - 1)
        *plpszHex[iStr] = ("0x" + *plpszHex[iStr])
    Next iStr
    
    ''unlock the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function UpdateHeadItemsDec (ByVal hWnd As HWND, ByVal hHeap As HANDLE, ByVal plpszDec As LPTSTR Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"plpszDec\t= 0x"; Hex(plpszDec)
    #EndIf
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''init items
    Dim lpLvi As LPLVITEM = Cast(LPLVITEM, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (C_LVI_HEAD * SizeOf(LVITEM))))
    If (lpLvi = NULL) Then Return(FALSE)
    For iItem As UINT32 = 0 To (C_LVI_HEAD - 1)
        With lpLvi[iItem]
            .mask = LVIF_TEXT
            .iSubItem = 1 ''value for the dec column
            .iItem = iItem
            .pszText = plpszDec[iItem]
        End With
    Next iItem
    
    ''update the list
    SendMessage(hWnd, WM_SETREDRAW, FALSE, NULL)
    For iItem As UINT32 = 0 To (C_LVI_HEAD - 1)
        If (SendMessage(hWnd, LVM_SETITEM, NULL, Cast(LPARAM, @lpLvi[iItem])) = FALSE) Then Return(FALSE)
    Next iItem
    SendMessage(hWnd, WM_SETREDRAW, TRUE, NULL)
    
    ''free items
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpLvi)) = FALSE) Then Return(FALSE)
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function UpdateHeadItemsHex (ByVal hWnd As HWND, ByVal hHeap As HANDLE, ByVal plpszHex As LPTSTR Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"plpszHex\t= 0x"; Hex(plpszHex)
    #EndIf
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''init items
    Dim lpLvi As LPLVITEM = Cast(LPLVITEM, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (C_LVI_HEAD * SizeOf(LVITEM))))
    If (lpLvi = NULL) Then Return(FALSE)
    For iItem As UINT32 = 0 To (C_LVI_HEAD - 1)
        With lpLvi[iItem]
            .mask = LVIF_TEXT
            .iSubItem = 2 ''value for the hex column
            .iItem = iItem
            .pszText = plpszHex[iItem]
        End With
    Next iItem
    
    ''update the list
    SendMessage(hWnd, WM_SETREDRAW, FALSE, NULL)
    For iItem As UINT32 = 0 To (C_LVI_HEAD - 1)
        If (SendMessage(hWnd, LVM_SETITEM, NULL, Cast(LPARAM, @lpLvi[iItem])) = FALSE) Then Return(FALSE)
    Next iItem
    SendMessage(hWnd, WM_SETREDRAW, TRUE, NULL)
    
    ''free items
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpLvi)) = FALSE) Then Return(FALSE)
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function 

''EOF
