/'
    
    options.bi
    
'/

#Pragma Once

#Define OPT_CCH_CAPTION     &h00000040
#Define OPT_CB_CAPTION      Cast(SIZE_T, (SizeOf(TCHAR) * OPT_CCH_CAPTION))

''prop. sheet page sizes
#Define OPT_C_PAGES         &h00000001
#Define OPT_CB_PAGES        Cast(SIZE_T, (SizeOf(PROPSHEETPAGE) * OPT_C_PAGES))

''max & min heap sizes for StartOptionsMenu
#Define OPT_CB_HEAPMIN      OPT_CB_CAPTION
#Define OPT_CB_HEAPMAX      Cast(SIZE_T, (SizeOf(PROPSHEETHEADER) + OPT_CB_PAGES + OPT_CB_CAPTION))

''prop. sheet page IDs
#Define OPT_PG_GENOPTS      &h00000000

#Define OPT_CCH_SUBKEY      &h00000100
#Define OPT_CB_SUBKEY       Cast(SIZE_T, (SizeOf(TCHAR) * OPT_CCH_SUBKEY))
#Define OPT_C_SUBKEY_GEN    &h00000001
#Define OPT_C_SUBKEY_LVHEAD &h00000003

#Define CFG_GENERAL         &h00000001
#Define CFG_LVHEAD          &h00000002

Type OPTS_GEN
    bShowFullPath As BOOL
End Type

Type OPTS_LVHEAD
    dwView As DWORD32
    puColumn As PULONG_PTR
End Type

Type OPTIONS
    general As OPTS_GEN
    lvHead As OPTS_LVHEAD
End Type

Declare Function StartOptionsMenu (ByVal hDlg As HWND, ByVal nStartPage As LONG32) As LRESULT

Declare Function GenOptsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

/'  Loads the configuration from the registry.
    pOpts:OPTIONS Ptr   -   Pointer to an OPTIONS structure, the value in
                            dwMask determines which fields are filled.
    dwMask:DWORD32      -   A mask providing telling the function which
                            values to load. This can be a combonation of
                            any of the following values:
                            CFG_GENERAL - general field is valid.
                            CFG_LVHEAD  - lvHead field is valid.
'/
Declare Function LoadConfig (ByVal pOpts As OPTIONS Ptr, ByVal dwMask As DWORD32) As LRESULT
Declare Function LoadCfg_GenOpts (ByVal hHeap As HANDLE, ByVal hkProg As HKEY, ByVal pGenOpts As OPTS_GEN Ptr) As BOOL


Declare Function GetSubKeyCount (ByVal dwMask As DWORD32, ByVal pcSubKey As PULONG32) As BOOL
Declare Function OpenProgHKey (ByVal phkOut As PHKEY, ByVal wAppName As WORD, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As BOOL

''EOF
