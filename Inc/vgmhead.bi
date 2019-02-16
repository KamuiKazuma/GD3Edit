/'
    
    vgmhead.bi
    
    VGMPlay's VGMFile.h translated to FB by Lisa.
    
    
'/

#Pragma Once

#Define FCC_VGM             &h206D6756 '' "Vgm "
#Define FCC_GD3             &h20336447 '' "Gd3 "
#Define VOLUME_MODIF_WRAP   &hC0


Type VGM_HEADER Field = 1
    fccVGM As DWORD32
    dwEOFOffset As DWORD32
    dwVersion As DWORD32
    dwHzPSG As DWORD32
    dwHzYM2413 As DWORD32
    dwGD3Offset As DWORD32
    dwTotalSamples As DWORD32
    dwLoopOffset As DWORD32
    dwLoopSamples As DWORD32
    dwRate As DWORD32
    wPSGFeedback As WORD
    PSGSRWidth As UByte
    PSGFlags As UByte
    dwHzYM2612 As DWORD32
    dwHzYM2151 As DWORD32
    dwDataOffset As DWORD32
    dwHzSPCM As DWORD32
    dwSPCMIntf As DWORD32
    dwHzRF5C68 As DWORD32
    dwHzYM2203 As DWORD32
    dwHzYM2608 As DWORD32
    dwHzYM3812 As DWORD32
    dwHzYM3526 As DWORD32
    dwHzY8950 As DWORD32
    dwHzYMF262 As DWORD32
    dwHzYMF278B As DWORD32
    dwHzYMF271 As DWORD32
    dwHzYMZ280B As DWORD32
    dwHzRF5C164 As DWORD32
    dwHzPWM As DWORD32
    dwHzAY8910 As DWORD32
    AYType As UByte
    AYFlag As UByte
    AYFlagYM2203 As UByte
    AYFlagYM2608 As UByte
    VolumeModifier As UByte
    Reserved2 As UByte
    LoopBase As Byte
    LoopModifier As Byte
    dwHzGBDMG As DWORD32
    dwHzNESAPU As DWORD32
    dwHzMultiPCM As DWORD32
    dwHzUPD7759 As DWORD32
    dwHzOKIM6258 As DWORD32
    OKI6258Flags As UByte
    K054539Flags As UByte
    C140Type As UByte
    ReservedFlags As UByte
    dwHzOKIM6295 As DWORD32
    dwHzK051649 As DWORD32
    dwHzK054539 As DWORD32
    dwHzHuC6280 As DWORD32
    dwHzC140 As DWORD32
    dwHzK053260 As DWORD32
    dwHzPokey As DWORD32
    dwHzQSound As DWORD32
    dwHzSCSP As DWORD32
    dwExtraOffset As DWORD32
    dwHzWSwan As DWORD32
End Type

Type VGM_HDR_EXTRA Field = 1
    cbDataSize As SIZE_T
    dwChp2ClkOffset As DWORD32
    dwChpVolOffset As DWORD32
End Type

Type VGMX_CHIP_DATA32 Field = 1
    uType As UByte
    dwData As DWORD32
End Type

Type VGMX_CHIP_DATA16 Field = 1
    uType As UByte
    uFlags As UByte
    wData As WORD
End Type

Type VGMX_CHIP_EXTRA32 Field = 1
    cChip As UByte
    ecdData As VGMX_CHIP_DATA32
End Type

Type VGMX_CHIP_EXTRA16 Field = 1
    cChip As UByte
    ecdData As VGMX_CHIP_DATA16
End Type

Type VGM_PCM_DATA Field = 1
    cbData As SIZE_T
    lpData As LPBYTE
    dwDataStart As DWORD32
End Type

Type VGM_PCM_BANK Field = 1
    cBank As ULONG32
    lpBank As VGM_PCM_DATA Ptr
    cbData As SIZE_T
    pData As LPBYTE
    dwDataPos As DWORD32
    dwBankPos As DWORD32
End Type
