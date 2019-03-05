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
#Define IDI_GD3TAG              &h0064
#Define IDI_GD3TAGSM            &h0065
#Define IDI_KAZUSOFT            &h0066
#Define IDI_WRENCH              &h0067

''dialogs
#Define IDD_MAIN                &h03E8
#Define IDC_SBR_MAIN            &h03E9
#Define IDC_LIV_MAIN            &h03E8

#Define IDD_GENOPTS             &h07D0
#Define IDC_CHK_SHOWFULLPATH    &h07D1

''menus
#Define IDR_MENUMAIN            &h2710
#Define IDM_FILE                &h2711
#Define IDM_OPEN                &h2712
#Define IDM_SAVE                &h2713
#Define IDM_SAVEAS              &h2714
#Define IDM_CLOSE               &h2715
#Define IDM_EXIT                &h2716
#Define IDM_OPTIONS             &h2717
#Define IDM_ABOUT               &h2718

''strings
/'  String ID Ranges
    /'  0x0001-0x00FF   -   General/misc. items.
        0x0001-0x0007   -   About message text.
        0x0008          -   Options menu caption.
    '/
    /'  0x0100-0x01FF   -   Listview items.
        0x0100-0x0108   -   VGM header view items.
    '/
    /'  0x0200-0x02FF   -   Listview column headings.
        0x0200-0x0202   -   VGM header view headings.
    '/
    /'  0x0300-0x03FF   -   Messages.
        0x0300          -   Unsaved file message.
        0x0301          -   UI update failed message.
        0x0302          -   UI init failed message.
        0x0303          -   VGM format bad message.
    '/
    /'  0x0400-0x04FF   -   Registry key names.
        0x0400-0x0401   -   OPTS_GEN structure key names.
        0x0402-0x0405   -   OPTS_LVHEAD structure key names.
    '/
    /'  0x0500-0x05FF   -   File filters.
        0x0500          -   Standard file filter.
    '/
'/
#Define IDS_APPNAME             &h0001
#Define IDS_ABOUT               &h0002
#Define IDS_VER32BIT            &h0003
#Define IDS_VER64BIT            &h0004
#Define IDS_BUILDDATE           &h0005
#Define IDS_COMPILER            &h0006
#Define IDS_SIGNATURE           &h0007
#Define IDS_OPTIONS             &h0008

#Define IDS_LVI_HEAD_VGMVER     &h0100
#Define IDS_LVI_HEAD_LOOPBASE   &h0101
#Define IDS_LVI_HEAD_LOOPMOD    &h0102
#Define IDS_LVI_HEAD_LOOPSAMP   &h0103
#Define IDS_LVI_HEAD_TOTALSAMP  &h0104
#Define IDS_LVI_HEAD_VOLMOD     &h0105
#Define IDS_LVI_HEAD_RATE       &h0106
#Define IDS_LVI_HEAD_EOFOFF     &h0107
#Define IDS_LVI_HEAD_GD3OFF     &h0108
#Define IDS_LVI_HEAD_LOOPOFF    &h0109
#Define IDS_LVI_HEAD_EXTOFF     &h010A

#Define IDS_LVH_HEAD_NAME       &h0200
#Define IDS_LVH_HEAD_VALUE      &h0201
#Define IDS_LVH_HEAD_VALUEHEX   &h0202

#Define IDS_MSG_UNSAVED         &h0300
#Define IDS_MSG_UIUPFAIL        &h0301
#Define IDS_MSG_UIINITFAIL      &h0302
#Define IDS_MSG_VGMFORMATBAD    &h0303

#Define IDS_REG_SHOWFULLPATH    &h0400
#Define IDS_REG_CUSTFILT        &h0401
#Define IDS_REG_LVHEAD          &h0402
#Define IDS_REG_LVHEAD_COL1     &h0403
#Define IDS_REG_LVHEAD_COL2     &h0404
#Define IDS_REG_LVHEAD_COL3     &h0405

#Define IDS_FILTER              &h0500

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

''sizes of AppName
#Define CCH_APPNAME             &h00000010 /'16'/
#Define CB_APPNAME              Cast(SIZE_T, (CCH_APPNAME * SizeOf(TCHAR)))

''EOF
