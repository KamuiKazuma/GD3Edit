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

Declare Function InitMainStatusBar (ByVal hWnd As HWND) As LRESULT
Declare Function SetSbrItemTextId (ByVal hWnd As HWND, ByVal hInst As HINSTANCE, ByVal dwPartId As DWORD32, ByVal wTextId As WORD, ByVal cchText As ULONG32) As BOOL

''EOF
