
#Pragma Once

''size of header listview headings
#Define CCH_LVH_HEAD            &h00000100
#Define CB_LVH_HEAD             Cast(SIZE_T, (CCH_LVH_HEAD * SizeOf(TCHAR)))
#Define C_LVH_HEAD              &h00000003

''header listview item IDs
#Define LVH_HEAD_NAME           &h00000000
#Define LVH_HEAD_VALUE          &h00000001
#Define LVH_HEAD_VALUEHEX       &h00000002

''size of header listview items
#Define CCH_LVI_HEAD            &h00000100
#Define CB_LVI_HEAD             Cast(SIZE_T, (CCH_LVI_HEAD * SizeOf(TCHAR)))
#Define C_LVI_HEAD              &h0000000B

''header listview item IDs
#Define LVI_HEAD_VGMVER         &h00000000
#Define LVI_HEAD_LOOPBASE       &h00000001
#Define LVI_HEAD_LOOPMOD        &h00000002
#Define LVI_HEAD_LOOPSAMP       &h00000003
#Define LVI_HEAD_TOTALSAMP      &h00000004
#Define LVI_HEAD_VOLMOD         &h00000005
#Define LVI_HEAD_RATE           &h00000006
#Define LVI_HEAD_EOFOFF         &h00000007
#Define LVI_HEAD_GD3OFF         &h00000008
#Define LVI_HEAD_LOOPOFF        &h00000009
#Define LVI_HEAD_EXTOFF         &h0000000A

''sizes of decimal strings
#Define CCH_LVIVALDEC           &h0000000A
#Define CB_LVIVALDEC            Cast(SIZE_T, (CCH_LVIVALDEC * SizeOf(TCHAR)))

''sizes of hex strings
#Define CCH_LVIVALHEX           &h0000000A
#Define CB_LVIVALHEX            Cast(SIZE_T, (CCH_LVIVALHEX * SizeOf(TCHAR)))

''heap sizes for InitHeadListView
#Define CB_IHLV_COLUMNS         Cast(SIZE_T, ((C_LVH_HEAD * CB_LVH_HEAD) + (C_LVH_HEAD * SizeOf(LVCOLUMN))))
#Define CB_IHLV_ITEMS           Cast(SIZE_T, ((C_LVI_HEAD * CB_LVI_HEAD) + (C_LVI_HEAD * SizeOf(LVITEM))))
#Define CB_IHLV_MAX             Cast(SIZE_T, (CB_IHLV_COLUMNS + CB_IHLV_ITEMS))

/'Initializes the main listbox control
    hWnd:HWND   -   Handle to the listbox contorl.
'/
Declare Function InitHeadListView (ByVal hWnd As HWND) As LRESULT

Declare Function UpdateHeadListView (ByVal hWnd As HWND, ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT

''EOF
