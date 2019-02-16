/'
    
    defines.bi
    
'/

#Pragma Once

''defines
#Define MARGIN_SIZE             &h0000000A
#Define WINDOW_SIZE             &h0000001E

''version information
#Define IDR_VERSIONINFO         &h0001

''icons
#Define IDI_KAZUSOFT            &h0064

''dialogs
#Define IDD_MAIN                &h03E8
#Define IDC_SBR_MAIN            &h03E9

''menus
#Define IDR_MENUMAIN            &h2710
#Define IDM_FILE                &h2711
#Define IDM_NEW                 &h2712
#Define IDM_OPEN                &h2713
#Define IDM_SAVE                &h2714
#Define IDM_SAVEAS              &h2715
#Define IDM_EXIT                &h2716
#Define IDM_ABOUT               &h2717

''strings
#Define IDS_APPNAME             &h0001
#Define IDS_ABOUT               &h0002
#Define IDS_VER32BIT            &h0003
#Define IDS_VER64BIT            &h0004
#Define IDS_BUILDDATE           &h0005
#Define IDS_COMPILER            &h0006
#Define IDS_SIGNATURE           &h0007
#Define IDS_FILTER              &h0008
#Define IDS_REG_SHOWFULLPATH    &h0009
#Define IDS_REG_CUSTFILT        &h000A
#Define IDS_CONFIRMEXIT         &h000B

''HeapPtrList info for about message
#Define CCH_ABT                 &h00000100 /'256'/
#Define CB_ABT                  Cast(SIZE_T, (CCH_ABT * SizeOf(TCHAR)))
#Define C_ABT                   &h00000007
#Define ABT_APPNAME             &h00000000
#Define ABT_ABOUT               &h00000001
#Define ABT_VER32BIT            &h00000002
#Define ABT_VER64BIT            &h00000003
#Define ABT_BUILDDATE           &h00000004
#Define ABT_COMPILER            &h00000005
#Define ABT_SIGNATURE           &h00000006

''sizes of file filter
#Define CCH_FILTER              &h00000100 /'256'/
#Define CB_FILTER               Cast(SIZE_T, (CCH_FILTER * SizeOf(TCHAR)))

''for size of AppName
#Define CCH_APPNAME             &h00000010 /'16'/
#Define CB_APPNAME              Cast(SIZE_T, (CCH_APPNAME * SizeOf(TCHAR)))

''masks for registry I/O functions
#Define CFG_ALL                 &h00000000

''size of registry key names
#Define CCH_REGVAL              &h00000100 /'256'/
#Define CB_REGVAL               Cast(SIZE_T, (CCH_REGVAL * SizeOf(TCHAR)))
#Define C_REGVAL                &h00000002
#Define REGVAL_SHOWFULLPATH     &h00000000
#Define REGVAL_CUSTFILT         &h00000001

#Define CB_VGMHEAD              &h00000100 /'256'/

''EOF
