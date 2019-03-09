/'
    
    vgmhead.bas
    
    Lines 1270-1382 of VGMPlay's VGMPlay.c translated to FB by Lisa
    
    Compile with:
        fbc -c ".\Mod\vgmhead.bas"
    
'/

#Include "header.bi"

Public Function ReadVGMHeader (ByVal hFile As HANDLE, ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hFile\t= 0x"; Hex(hFile)
        ? !"pVGMHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    ''make sure file begins with "Vgm " indent
    If (LockFile(hFile, 0, NULL, 4, NULL) = FALSE) Then Return(GetLastError())
    Dim dwRead As DWORD32
    If (ReadFile(hFile, Cast(LPVOID, @pVgmHead->fccVGM), SizeOf(DWORD32), @dwRead, NULL) = FALSE) Then Return(GetLastError())
    If (pVgmHead->fccVGM <> FCC_VGM) Then Return(ERROR_BAD_FORMAT)
    If (UnlockFile(hFile, 0, NULL, 4, NULL) = FALSE) Then Return(GetLastError())
    
    ''restore file pointer to beginning of file
    If (SetFilePointer(hFile, 0, NULL, FILE_BEGIN) = INVALID_SET_FILE_POINTER) Then Return(GetLastError())
    
    ''read the file
    If (LockFile(hFile, 0, NULL, SizeOf(VGM_HEADER), NULL) = FALSE) Then Return(GetLastError())
    If (ReadFile(hFile, Cast(LPVOID, pVgmHead), SizeOf(VGM_HEADER), @dwRead, NULL) = FALSE) Then Return(GetLastError())
    If (UnlockFile(hFile, 0, NULL, SizeOf(VGM_HEADER), NULL) = FALSE) Then Return(GetLastError())
    
    ''prepare the header for usage
    If (PrepareHeader(pVgmHead) = FALSE) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Private Function PrepareHeader (ByVal pVgmHead As VGM_HEADER Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"pVGMHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    ''clear fields not used by version
    With *pVgmHead
        If (.dwVersion < VGM_VER_101) Then .dwRate = NULL
        If (.dwVersion < VGM_VER_110) Then
            .wPSGFeedback   = NULL
            .PSGSRWidth     = NULL
            .dwHzYM2612     = .dwHzYM2413
            .dwHzYM2151     = .dwHzYM2413
        End If
        If (.dwVersion < VGM_VER_150) Then
            .dwDataOffset   = NULL
            .PSGFlags       = NULL
            .dwHzSPCM       = NULL
            .dwSPCMIntf     = NULL
        End If
    End With
    
    ''convert the relative offsets into absolute addresses
    SetLastError(MakeVgmOffsAddrs(pVgmHead))
    If (GetLastError()) Then Return(FALSE)
    
    ''clear the rest of the unused fields
    With *pVgmHead
        Dim dwCurPos As DWORD32 = .dwDataOffset
        If (.dwVersion < VGM_VER_150) Then dwCurPos = &h40
        If (dwCurPos = NULL) Then dwCurPos          = &h40
        
        If (SizeOf(VGM_HEADER) > dwCurPos) Then ZeroMemory((Cast(PUINT_PTR, (pVgmHead + dwCurPos))), (SizeOf(VGM_HEADER) - dwCurPos))
        
        If (.LoopModifier = NULL) Then .LoopModifier = VGM_DEF_LOOPMOD
        
        If (.dwExtraOffset) Then
            dwCurPos = .dwExtraOffset
            If (dwCurPos < SizeOf(VGM_HEADER)) Then ZeroMemory((Cast(PUINT_PTR, (pVgmHead + dwCurPos))), (SizeOf(VGM_HEADER) - dwCurPos))
        End If
    End With
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Public Function MakeVgmOffsAddrs (ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"pVGMHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    If (pVgmHead = NULL) Then Return(ERROR_INVALID_PARAMETER)
    
    ''make the relative offsets into absolute addresses
    With *pVgmHead
        If (.dwEOFOffset) Then .dwEofOffset += VGM_OFF_EOF
        If (.dwGD3Offset) Then .dwGD3Offset += VGM_OFF_GD3
        If (.dwLoopOffset) Then .dwLoopOffset += VGM_OFF_LOOP
        If (.dwVersion < VGM_VER_150) Then .dwDataOffset = &h0000000C
        If (.dwDataOffset) Then .dwDataOffset += VGM_OFF_DATA
        If (.dwExtraOffset) Then .dwExtraOffset += VGM_OFF_EXTRA
    End With
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Public Function MakeVgmAddrsOffs (ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"pVGMHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    If (pVgmHead = NULL) Then Return(ERROR_INVALID_PARAMETER)
    
    ''make the relative offsets into absolute addresses 
    With *pVgmHead
        If (.dwEOFOffset) Then .dwEofOffset -= VGM_OFF_EOF
        If (.dwGD3Offset) Then .dwGD3Offset -= VGM_OFF_GD3
        If (.dwLoopOffset) Then .dwLoopOffset -= VGM_OFF_LOOP
        If (.dwVersion < VGM_VER_150) Then .dwDataOffset = &h0000000C
        If (.dwDataOffset) Then .dwDataOffset -= VGM_OFF_DATA
        If (.dwExtraOffset) Then .dwExtraOffset -= VGM_OFF_EXTRA
    End With
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Public Function TranslateBcdCodeVer (ByVal dwBcdCode As DWORD32, ByVal lpszVer As LPTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"dwBcdCode\t= 0x"; Hex(dwBcdCode)
        ? !"lpszVer\t= 0x"; Hex(lpszVer)
    #EndIf
    
    ''create a local heap
    Dim hHeap As HANDLE = HeapCreate(NULL, (4 * SizeOf(UByte)), (4 * SizeOf(UByte)))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''get sub version numbers
    Dim pubSubVer As UByte Ptr = Cast(UByte Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (4 * SizeOf(UByte))))
    If (pubSubVer = NULL) Then Return(FALSE)
    pubSubVer[0] = HiWord(HiByte(dwBcdCode))
    pubSubVer[1] = HiWord(LoByte(dwBcdCode))
    pubSubVer[2] = LoWord(HiByte(dwBcdCode))
    pubSubVer[3] = LoWord(LoByte(dwBcdCode))
    
    ''figure out how large the version number should be
    Dim cSubVer As UINT_PTR    ''number of sub version numbers
    For iSubVer As UINT_PTR = 3 To 0 Step -1
        
        ''add up sub version numbers that are non-zero
        If (pubSubVer[iSubVer] > 0) Then
            cSubVer += 1
        Else
            Exit For
        End If
    Next iSubVer
    
    ''format output string
    For iSubVer As UINT_PTR = 3 To cSubVer Step -1
        
        ''exclude the "." separator on the last sub version number
        If (iSubVer = cSubVer) Then
            *lpszVer = (Hex(pubSubVer[iSubVer]) + *lpszVer)
        Else
            *lpszVer = ("." + Hex(pubSubVer[iSubVer]) + *lpszVer)
        End If
    Next iSubVer
    
    ''return
    If (HeapFree(hHeap, NULL, Cast(LPVOID, pubSubVer)) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
