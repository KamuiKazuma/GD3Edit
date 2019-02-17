/'
    
    filenameinfo.bi
    
    Header for FileNameInfo module.
    
'/

#Pragma Once


''defines
#Define FNI_CCHFILE     MAX_PATH
#Define FNI_CBFILE      Cast(SIZE_T, (FNI_CCHFILE * SizeOf(TCHAR)))
#Define FNI_CFILE       &h00000003 /'3'/

''FNI structure definition
Type FILENAMEINFO
    lpszFile As LPTSTR          ''pointer to buffer containing full file name (ex. "C:\Folder\Example.txt")
    lpszFileTitle As LPTSTR     ''pointer to file name (ex. "Example.txt")
    cchFileOffset As ULONG32    ''char offset of file name
    cchExtOffset As ULONG32     ''char offset of file extention
    bReadOnly As BOOL           ''file is to be opened as read only
End Type

/'  InitFileNameInfo/FreeFileNameInfo
    ByVal hHeap As HANDLE           -   Handle to the heap to load.
    ByVal pFni As FILENAMEINFO Ptr  -   Pointer to a FILENAMEINFO structure
                                        to create/free.
    Return Value:
    Type: LRESULT
    
        Returns a system error code.
'/
Declare Function InitFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT
Declare Function FreeFileNameInfo (ByVal hHeap As HANDLE, ByVal pFni As FILENAMEINFO Ptr) As LRESULT

''EOF
