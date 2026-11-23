; Foreground actions are deferred from the keyboard/motor callbacks. This
; prevents re-entering the printer when a shortcut is pressed during a job.
TTYACTIONS LDAB LOCALCMD
        BNE TACTIONBEGIN
        RTS
TACTIONBEGIN EQU *
        CLR LOCALCMD
        CMPB #1
        BNE TACTIONFLUSH
        CLR TCR
        JSR TTYNEWLINE
        JMP TACTIONDIRTY
TACTIONFLUSH CMPB #2
        BNE TACTIONMENU
        TST TCOUNT
        BEQ TACTIONEARLY
        JSR TTYFLUSH
        JMP TACTIONDIRTY
TACTIONMENU CMPB #3
        BNE TACTIONAPPLY
        TST TCOUNT
        BEQ TMENUSTART
        JSR TTYFLUSH
TMENUSTART LDX #BAUDSEL
        LDAB #6
TMENUCOPY LDAA ,X
        STAA MENUEDIT-BAUDSEL,X
        INX
        DECB
        BNE TMENUCOPY
        LDAA #1
        STAA MENUACTIVE
        CLR MENUITEM
        JSR UIREFRESH
TACTIONEARLY RTS
TACTIONAPPLY CMPB #4
        BNE TACTIONCANCEL
        LDAA TXTAIL
        CMPA TXHEAD
        BNE TMENUTXBUSY
        ; Print bytes already received with the old framing before changing
        ; the UART. The setup menu keeps the host paused throughout this work.
TMENUDRAIN LDAB RXTAIL
        CMPB RXHEAD
        BEQ TMENUDRAINED
        LDX #RXBUF
        ABX
        LDAA ,X
        INC RXTAIL
        JSR TTYINPUT
        BRA TMENUDRAIN
TMENUDRAINED TST TCOUNT
        BEQ TMENUSAVE
        JSR TTYFLUSH
TMENUSAVE TST FLOWSEL
        BEQ TMENUNEWCONFIG
        TST MENUEDIT+2
        BNE TMENUNEWCONFIG
        ; Release a software-paused peer before disabling software flow.
        LDAA #17
        STAA FLOWTX
TMENUXON JSR TTYSERVICE
        TST FLOWTX
        BNE TMENUXON
        LDD $09
        STD TWIRETIME
TMENUWAIT JSR TTYSERVICE
        LDD $09
        SUBD TWIRETIME
        SUBD #20000
        BCS TMENUWAIT
TMENUNEWCONFIG LDX #BAUDSEL
        LDAB #6
TMENUSAVELOOP LDAA MENUEDIT-BAUDSEL,X
        STAA ,X
        INX
        DECB
        BNE TMENUSAVELOOP
        CLR RXLOSS
        CLR TXLOSS
        CLR UIERROR
        CLR TXSTOP
        CLR ESCSTATE
        JSR TTYUART
        BRA TMENUCLOSE
TMENUTXBUSY LDAA UIERROR
        ORAA #32
        STAA UIERROR
        BRA TACTIONDIRTY
TACTIONCANCEL CMPB #5
        BNE TACTIONRET
TMENUCLOSE CLR MENUACTIVE
        JSR UIREFRESH
TACTIONDIRTY LDAA #1
        STAA UIUPDATE
TACTIONRET RTS

; Arrows choose a field/value. RETURN applies all edited values. BREAK,
; ESC or CODE+SPACE closes setup with the active values retained.
TTYMENUKEY CMPA #13
        BEQ TMENUOK
        CMPA #3
        BEQ TMENUCANCEL
        CMPA #27
        BEQ TMENUCANCEL
        CMPA #$80
        BEQ TMENUCANCEL
        CMPA #20
        BEQ TMENUPREV
        CMPA #21
        BEQ TMENUNEXT
        CMPA #18
        BEQ TMENUDEC
        CMPA #19
        BEQ TMENUINC
        RTS
TMENUOK LDAA #4
        BRA TMENUACTION
TMENUCANCEL LDAA #5
TMENUACTION STAA LOCALCMD
        RTS
TMENUPREV TST MENUITEM
        BNE TMENUPREV1
        LDAA #6
        STAA MENUITEM
TMENUPREV1 DEC MENUITEM
        BRA TMENUDIRTY
TMENUNEXT INC MENUITEM
        LDAA MENUITEM
        CMPA #6
        BCS TMENUDIRTY
        CLR MENUITEM
        BRA TMENUDIRTY
TMENUDEC LDAB MENUITEM
        LDX #TMENUCOUNTS
        ABX
        LDAA ,X
        STAA UITMP
        LDX #MENUEDIT
        ABX
        TST ,X
        BNE TMENUDEC1
        STAA ,X
TMENUDEC1 DEC ,X
        BRA TMENUDIRTY
TMENUINC LDAB MENUITEM
        LDX #TMENUCOUNTS
        ABX
        LDAA ,X
        LDX #MENUEDIT
        ABX
        INC ,X
        CMPA ,X
        BNE TMENUDIRTY
        CLR ,X
TMENUDIRTY LDAA #1
        STAA UIUPDATE
        RTS
TMENUCOUNTS FCB BAUDCOUNT,2,3,2,2,2
TTYMENUEND EQU *
