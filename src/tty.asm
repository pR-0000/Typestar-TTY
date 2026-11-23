TTYSTART SEI
        LDS #$1FFF
        JSR CONSOLEATTACH
        JSR UIINIT
        CLR BOOTFLAG
        LDX #RXHEAD
TRESET  CLR ,X
        INX
        CPX #TSTATEEND
        BNE TRESET
        LDD #$20C0
        STD PEND
        INCB
        STD DFLOOR
        LDX #RXBUF
        STX DHEAP
        JSR SPBOOT
        CLR LPCOLUMN
        CLR LPMODE
        LDAA #DEFAULTFRAME
        STAA FRAMESEL
        LDAA #DEFAULTFLOW
        STAA FLOWSEL
        LDX #PREVIEWBUF
        LDAA #32
TPREVIEWINIT STAA ,X
        INX
        CPX #PREVIEWBUF+16
        BNE TPREVIEWINIT
        JSR TTYUART
        JSR UIREFRESH
        JSR TTYACTIVITY

TTYMAIN JSR TTYSERVICE
        JSR TTYKEY
        JSR TTYACTIONS
        JSR TTYSTATUS
        JSR TTYSERVICE           ; bound the gap before parsing the next byte
        TST MENUACTIVE
        BNE TTYMAIN
        LDAB RXTAIL
        CMPB RXHEAD
        BEQ TTYECHO
        LDX #RXBUF
        ABX
        LDAA ,X
        INC RXTAIL
        LDAB #1
        STAB UIUPDATE            ; queue length changes even without new RX
        JSR TTYACTIVITY
        PSHA
        JSR UIPREVIEW
        JSR TTYSERVICE           ; keep the received byte saved across the poll
        PULA
        JSR TTYINPUT
        BRA TTYMAIN

TTYECHO LDAB ETAIL
        CMPB EHEAD
        BEQ TTYIDLE
        LDX #ECHOQUEUE
        ABX
        LDAA ,X
        INCB
        ANDB #31
        STAB ETAIL
        JSR TTYACTIVITY
        JSR TTYPLAIN
        BRA TTYMAIN

; Time an unfinished line with the free-running counter. Unsigned deltas
; handle timer wrap. Four 50,000-clock intervals are about 200 ms at 1 MHz.
TTYIDLE TST TCOUNT
        BEQ TTYMAIN
        LDD $09
        SUBD TCLOCK
        SUBD #50000
        BCS TTYMAIN
        LDD $09
        STD TCLOCK
        INC TIDLE
        LDAA TIDLE
        CMPA #4
        BCS TTYMAIN
        JSR TTYFLUSH
        BRA TTYMAIN
TTYACTIVITY PSHA
        PSHB
        LDD $09
        STD TCLOCK
        CLR TIDLE
        PULB
        PULA
        RTS

TTYINPUT LDAB ESCSTATE
        BNE TTYESC
        CMPA #27
        BEQ TESCFIRST
TTYPLAIN CMPA #13
        BEQ TTYCR
        CMPA #10
        BEQ TTYLF
        CMPA #9
        BEQ TTYTAB
        CMPA #8
        BEQ TTYBS
        CMPA #127
        BEQ TTYBS
        CMPA #32
        BCS TINPUTRET
        CMPA #126
        BLS TTYCHAR
        LDAA #'?'
TTYCHAR CLR TCR
        JMP TTYADD
TTYCR   LDAA #1
        STAA TCR
        JMP TTYNEWLINE
TTYLF   TST TCR
        BNE TCRLF
        JMP TTYNEWLINE
TCRLF   EQU *
        CLR TCR
TINPUTRET RTS
TTYBS   CLR TCR
        TST TCOUNT
        BEQ TINPUTRET
        DEC TCOUNT
        DEC TCOL
        RTS
TTYTAB  CLR TCR
        LDAA TCOL
        ANDA #7
        NEGA
        ADDA #8
        STAA TABS
TTYTABLOOP LDAA #32
        JSR TTYADD
        DEC TABS
        BNE TTYTABLOOP
        RTS

TESCFIRST LDAA #1
TESCSET STAA ESCSTATE
        RTS
TTYESC  CMPA #24                 ; CAN and SUB cancel any escape sequence
        BEQ TESCDONE
        CMPA #26
        BEQ TESCDONE
        CMPB #1
        BEQ TESCHEAD
        CMPB #2
        BEQ TESCCSI
        CMPA #7                  ; BEL terminates OSC
        BEQ TESCDONE
        CMPB #4
        BNE TESCSTRING
        CMPA #$5C                ; ST = ESC followed by backslash
        BEQ TESCDONE
TESCSTRING CMPA #27
        BEQ TESCST
        LDAA #3
        BRA TESCSET
TESCST  LDAA #4
        BRA TESCSET
TESCHEAD CMPA #'['
        BEQ TESCSTARTCSI
        CMPA #']'
        BEQ TESCSTARTSTR
        CMPA #'P'
        BEQ TESCSTARTSTR
        CMPA #'_'
        BEQ TESCSTARTSTR
        CMPA #'^'
        BEQ TESCSTARTSTR
        CMPA #'X'
        BEQ TESCSTARTSTR
        CMPA #$20                ; ESC intermediates, e.g. ESC ( B
        BCS TTYRETURN
        CMPA #$2F
        BLS TTYRETURN
        BRA TESCDONE
TESCSTARTSTR LDAA #3
        BRA TESCSET
TESCSTARTCSI LDAA #2
        BRA TESCSET
TESCCSI CMPA #27
        BEQ TESCFIRST
        CMPA #$40
        BCS TTYRETURN
        CMPA #$7E
        BHI TTYRETURN
TESCDONE CLR ESCSTATE
TTYRETURN RTS

TTYADD  PSHA
        JSR TTYSERVICE           ; TAB can append eight spaces in one call
        PULA
        LDAB TCOL
        CMPB #72
        BCS TTYAPPEND
        PSHA
        JSR TTYNEWLINE
        PULA
TTYAPPEND LDAB TCOUNT
        LDX #TEXTBUF
        ABX
        STAA ,X
        INC TCOL
        INC TCOUNT
        LDAB TCOUNT
        CMPB #24
        BCS TTYRETURN
TTYFLUSH LDAA #1
        STAA LPSUPPRESS
        BRA TTYPRINT
TTYNEWLINE CLR LPSUPPRESS
        CLR TCOL
TTYPRINT JSR TTYQUIET
        LDX #TEXTBUF
        STX LPREAD
        LDAA TCOUNT
        STAA LPREMAIN
        CLR TCOUNT
        JSR LPBUILD              ; common prevalidated BASIC glyph cache
        CLR TPRINTBUSY
        JMP TTYACTIVITY

TTYFAIL SEI                       ; RBJOB has already made the motors safe
        LDS #$1FFF
        JSR $8E4A                ; also stop head/motors after a native abort
        JSR TTYSTOP
        JSR UICLEAR
        LDX #PAPERERROR
        JSR PUTS
THALT   JSR TTYFAULTTX           ; allow a pending XOFF to leave the UART
        BRA THALT
PAPERERROR FCC "TTY PAPER ERROR - RESTART"
        FCB 0
TTYMAINEND EQU *
