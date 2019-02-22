/'
    
    vgmhead.bas
    
    Lines 1270-1382 of VGMPlay's VGMPlay.c translated to FB by Lisa
    
    Compile with:
        fbc -c ".\Mod\vgmhead.bas"
    
'/

#Include "header.bi"

Public Function ReadVGMHeader (ByVal hFile As HANDLE, ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hFile\t= 0x"; Hex(hFile)
        ? !"pVGMHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    
    ''make sure file begins with "Vgm " indent
    If (LockFile(hFile, 0, 0, 4, 0) = FALSE) Then Return(GetLastError())
    Dim dwRead As DWORD32
    If (ReadFile(hFile, Cast(LPVOID, @pVgmHead->fccVGM), SizeOf(DWORD32), @dwRead, NULL) = FALSE) Then Return(GetLastError())
    If (pVgmHead->fccVGM <> FCC_VGM) Then Return(ERROR_BAD_FORMAT)
    If (UnlockFile(hFile, 0, 0, 4, 0) = FALSE) Then Return(GetLastError())
    
    ''restore file pointer to beginning of file
    If (SetFilePointer(hFile, 0, NULL, FILE_BEGIN) = INVALID_SET_FILE_POINTER) Then Return(GetLastError())
    
    ''read the file
    If (LockFile(hFile, 0, 0, SizeOf(VGM_HEADER), 0) = FALSE) Then Return(GetLastError())
    If (ReadFile(hFile, Cast(LPVOID, pVgmHead), SizeOf(VGM_HEADER), @dwRead, NULL) = FALSE) Then Return(GetLastError())
    If (UnlockFile(hFile, 0, 0, SizeOf(VGM_HEADER), 0) = FALSE) Then Return(GetLastError())
    
    ''prepare the header for usage
    If (PrepareHeader(pVgmHead) = FALSE) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Private Function PrepareHeader (ByVal pVgmHead As VGM_HEADER Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"pVGMHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
    ''clear fields not used by version
    With *pVgmHead
        If (.dwVersion < VGM_VER_101) Then .dwRate = NULL
        If (.dwVersion < VGM_VER_110) Then
            .wPSGFeedback = NULL
            .PSGSRWidth = NULL
            .dwHzYM2612 = .dwHzYM2413
            .dwHzYM2151 = .dwHzYM2413
        End If
        If (.dwVersion < VGM_VER_150) Then
            .dwDataOffset = NULL
            .PSGFlags = NULL
            .dwHzSPCM = NULL
            .dwSPCMIntf = NULL
        End If
    End With
    
    ''convert the relative offsets into absolute addresses
    SetLastError(MakeOffsetsAddresses(pVgmHead))
    If (GetLastError()) Then Return(FALSE)
    
    ''clear the rest of the unused fields
    With *pVgmHead
        Dim dwCurPos As DWORD32 = .dwDataOffset
        If (.dwVersion < VGM_VER_150) Then dwCurPos = &h40
        If (dwCurPos = NULL) Then dwCurPos = &h40
        
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

Private Function MakeOffsetsAddresses (ByVal pVgmHead As VGM_HEADER Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"pVGMHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
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

Private Function MakeAddressesOffsets (ByVal pVgmHead As VGM_HEADER Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"pVGMHead\t= 0x"; Hex(pVgmHead)
    #EndIf
    
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

''EOF
