; Typestar TTY for BASIC 0.4.100-dev on HD6301Y/NH7-0815.
; State is outside Canon printer scratch, the cache and the CPU stack.
BAUDCOUNT EQU 5
RXBUF   EQU $3600               ; 255 usable entries, indexed modulo 256
TXBUF   EQU $3700               ; 31 usable keyboard entries
TEXTBUF EQU $3720               ; 24 glyphs per thermal transaction
RXHEAD  EQU $3750
RXTAIL  EQU $3751
TXHEAD  EQU $3752
TXTAIL  EQU $3753
FLOW    EQU $3754               ; 0=ready, 1=stop
FLOWTX  EQU $3755               ; pending software flow byte (0=none)
TXSTOP  EQU $3756               ; remote XOFF (software-flow profile only)
RXLOSS  EQU $3757               ; 1=new error, 2=reported
TXLOSS  EQU $3758
TCOUNT  EQU $3759
TCOL    EQU $375A               ; printed + uncommitted columns
TCR     EQU $375B               ; previous end of line was CR
ESCSTATE EQU $375C              ; ESC, CSI, control string, ESC in string
TABS    EQU $375D
TIDLE   EQU $375E
TCLOCK  EQU $375F               ; Timer 1 free-running counter snapshot
TPRINTBUSY EQU $3761
TWIRETIME EQU $3762
BAUDSEL EQU $3764
FRAMESEL EQU $3765
FLOWSEL EQU $3766
RETURNSEL EQU $3767
ECHOSEL EQU $3768
PREVIEWSEL EQU $3769
MENUACTIVE EQU $376A
MENUITEM EQU $376B
LOCALCMD EQU $376C
EHEAD   EQU $376D
ETAIL   EQU $376E
UIERROR EQU $376F
UIRX    EQU $3770
UITX    EQU $3771
UIUPDATE EQU $3772
UITIMER EQU $3773
UIPERIOD EQU $3775
UIWRITEPTR EQU $3776
TMPKEY  EQU $3778
CODEHELD EQU $3779
UIRXLAST EQU $377A
UITXLAST EQU $377B
UITMP   EQU $377C
UINUM   EQU $377D
RXDETAIL EQU $377E
UITMPPTR EQU $37B6
ECHOQUEUE EQU $3780
PREVIEWBUF EQU $37A0
MENUEDIT EQU $37B0
LCDTEXT EQU $37C0
TSTATEEND EQU $37E0
