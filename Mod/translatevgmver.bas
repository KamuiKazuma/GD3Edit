/'
    
    translatevgmver.bas
    
'/

#Include "windows.bi"

Declare Function GetSubVerCount (ByVal pubSubVer As UByte Ptr) As UINT32

Public Function TranslateVgmVer (ByVal dwBcdCode As DWORD32, ByVal lpszVer As LPTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"dwBcdCode\t= 0x"; Hex(dwBcdCode)
        ? !"lpszVer\t= 0x"; Hex(lpszVer)
    #EndIf
    
    ''get sub version numbers
    Dim pubSubVer As UByte Ptr = LocalAlloc(LPTR, (4 * SizeOf(UByte)))
    If (pubSubVer = NULL) Then Return(FALSE)
    pubSubVer[0] = HiWord(HiByte(dwBcdCode))
    pubSubVer[1] = HiWord(LoByte(dwBcdCode))
    pubSubVer[2] = LoWord(HiByte(dwBcdCode))
    pubSubVer[3] = LoWord(LoByte(dwBcdCode))
    
    ''figure out how large the version number should be
    Dim cSubVer As UINT32 = GetSubVerCount(pubSubVer)
    /'For iSubVer As UINT32 = 3 To 0 Step -1
        If (pubSubVer[iSubVer] > 0) Then
            cSubVer += 1
        Else
            Exit For
        End If
    Next iSubVer'/
    
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
    If (LocalFree(pubSubVer) = NULL) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function GetSubVerCount (ByVal pubSubVer As UByte Ptr) As UINT32
    
    Dim cSubVer As UINT32
    For iSubVer As UINT32 = 3 To 0 Step -1
        If (pubSubVer[iSubVer] > 0) Then
            cSubVer += 1
        Else
            Exit For
        End If
    Next iSubVer
    
    Return(cSubVer)
    
End Function

''EOF
