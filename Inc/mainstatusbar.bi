/'
    
    mainstatusbar.bi
    
'/

#Pragma Once

''statusbar part IDs
#Define C_SBR_PART              &h00000002
#Define SBR_PART_VER            &h00000000
#Define SBR_PART_READONLY       &h00000001

''statusbar part positions
#Define C_SBR_PART_POS          (C_SBR_PART + 1)
#Define SBR_PART_POS_VER        80
#Define SBR_PART_POS_READONLY   180
#Define SBR_PART_POS_END        -1

/'  InitMainStatusBar:
    /'  Description:
        Initializes the main dialog's status bar.
    '/
    /'  Parameters:
        /'  ByVal hWnd As HWND:
            Handle to the statusbar window.
        '/
    '/
    /'  Return Value:
        Returns a system error code.
    '/
'/
Declare Function InitMainStatusBar (ByVal hWnd As HWND) As LRESULT

Declare Function UpdateMainStatusBar (ByVal hWnd As HWND, ByVal dwBcdCode As DWORD32, ByVal bReadOnly As BOOL) As LRESULT

/'  SetSbrItemTextId:
    /'  Description:
        Sets a statusbar item's text from a string resource.
    '/
    /'  Parameters:
        /'  ByVal hWnd As HWND
            Handle to the statusbar window.
        '/
        /'  ByVal hInst As HINSTANCE
            Handle to the module containing the string resource.
        '/
        /'  ByVal dwPartId As DWORD32
            The ID of the statusbar part to set the text to.
        '/
        /'  ByVal wTextId As WORD
            The ID of the string resource to use.
        '/
        /'  ByVal cchText As ULONG32
            Size of the string in TCHARs.
        '/
    '/
    /'  Return Value:
        Returns TRUE on success, and FALSE on failure. Call GetLastError
        for more detailed information.
    '/
'/
'Declare Function SetSbrItemTextId (ByVal hWnd As HWND, ByVal hInst As HINSTANCE, ByVal dwPartId As DWORD32, ByVal wTextId As WORD, ByVal cchText As ULONG32) As BOOL

''EOF
