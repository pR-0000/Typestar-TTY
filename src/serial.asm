TTYUART CLR $11
        CLR $1E
        CLR $1B
        LDAA #$24
        STAA $10
        LDAB BAUDSEL
        LDX #TDIVIDERS
        ABX
        LDAA ,X
        STAA $1C
        LDAA #$10
        STAA $1B
        LDAA #$24
        TST FRAMESEL
        BEQ TUARTMODE
        ORAA #$10
TUARTMODE EQU *
        STAA $10
        CLRA
        TST FRAMESEL
        BEQ TUARTPARITY
        LDAA #4
TUARTPARITY EQU *
        STAA $1E
        LDX #$1000
TSETTLE DEX
        BNE TSETTLE
        ; TRCSR1: RIE=$10, RE=$08, TE=$02. Global SEI keeps polling exclusive.
        ; Match the control value validated by BASIC and the Canon driver.
        LDAA #$1A
        STAA $11
        NOP
        LDAA $1E
        LDAA $12
        TST MENUACTIVE
        BEQ TUARTGO
        JMP TTYSTOP
TUARTGO JMP TTYGO
; Same hardware rates as BASIC / Studio. Zero is a valid divider: 31250.
TDIVIDERS FCB 25,12,3,1,0

; One service call returns immediately. Only this path touches ring pointers.
; Check TRCSR2 before RDR so it also reports and clears parity errors.
TTYSERVICE LDAA $1E
        BITA #$D0
        BEQ TTYSEND
        LDAB $12
        BITA #$50
        BNE THARDERROR
        TST FLOWSEL
        BEQ TQUEUE
        CMPB #19
        BNE TTESTXON
        LDAA #1
        STAA TXSTOP
        BRA TTYSEND
TTESTXON CMPB #17
        BNE TQUEUE
        CLR TXSTOP
        BRA TTYSEND
TQUEUE  TBA
        LDAB RXHEAD
        INCB
        CMPB RXTAIL
        BEQ TLOSTRX
        DECB
        LDX #RXBUF
        ABX
        STAA ,X
        INCB
        STAB RXHEAD
        INC UIRX
        LDAA #1
        STAA UIUPDATE
        BRA TTYSEND
TLOSTRX LDAA UIERROR
        ORAA #4
        BRA TRXERROR
THARDERROR BITA #$10
        BEQ TFRAMEERROR
        LDAA UIERROR
        ORAA #1
        BRA TRXERROR
TFRAMEERROR LDAA UIERROR
        ORAA #2
TRXERROR STAA UIERROR
        LDAA #1
        STAA UIUPDATE
        TST RXLOSS
        BNE TTYSEND
        INC RXLOSS

TTYSEND LDAA $11
        BITA #$20
        BEQ TSDONE
        TST FLOWSEL
        BEQ TSKEY
        LDAA FLOWTX
        BEQ TSKEY
        CLR FLOWTX
        BRA TSFLOWWRITE
TSKEY   TST FLOWSEL
        BEQ TSDEQUEUE
        TST TXSTOP
        BNE TSDONE
TSDEQUEUE LDAB TXTAIL
        CMPB TXHEAD
        BEQ TSDONE
        LDX #TXBUF
        ABX
        INCB
        ANDB #31
        STAB TXTAIL
        LDAA ,X
TSWRITE STAA $13
        INC UITX
        LDAA #1
        STAA UIUPDATE
        BRA TSDONE
        ; Flow bytes must not schedule another LCD refresh: that refresh
        ; would itself send XOFF/XON and create a permanent idle loop.
TSFLOWWRITE STAA $13
TSDONE  LDAA RXHEAD
        SUBA RXTAIL
        TST FLOW
        BNE TRESUME
        CMPA #128
        BCC TTYSTOP
        ; A second frame can finish while TX and flow checks run. Drain it
        ; before returning to keyboard/text work at the fastest rates.
        LDAA $1E
        BITA #$D0
        BEQ TSRETURN
        JMP TTYSERVICE
TSRETURN RTS
TRESUME TST TPRINTBUSY
        BNE TPORTRET
        TST MENUACTIVE
        BNE TPORTRET
        CMPA #32
        BHI TPORTRET
TTYGO   CLR FLOW
        TST FLOWSEL
        BEQ TGOHARD
        LDAA #17
        STAA FLOWTX
TGOHARD LDAA $69
        ANDA #$7D
        BRA TPORT
TTYSTOP LDAA #1
        STAA FLOW
        TST FLOWSEL
        BEQ TSTOPHARD
        LDAA #19
        STAA FLOWTX
TSTOPHARD LDAA $69
        ORAA #2
TPORT   STAA $69
        STAA $03
TPORTRET RTS

; Some native thermal phases can take longer than a frame with no poll point.
; Ask the host to pause ahead of them and collect any in-flight bytes first.
TTYQUIET INC TPRINTBUSY
        TST FLOW
        BNE TQUIETCLOCK
        JSR TTYSTOP
TQUIETCLOCK LDD $09
        STD TWIRETIME
TQUIETWAIT JSR TTYSERVICE
        JSR TTYKEY
        LDD $09
        SUBD TWIRETIME
        SUBD #50000              ; about 50 ms at the 1 MHz E clock
        BCS TQUIETWAIT
        RTS

; Keep the physical printer wait bounded while servicing the UART. Preserve
; the original Timer 1 ready test and tail branches with the same X budget.
TTYWAIT LDAA $08
        BITA #$40
        BNE TWAITREADY
        PSHX
        JSR TTYSERVICE
        PULX
        DEX
        BNE TTYWAIT
        JMP GPTIMEOUT
TWAITREADY JMP GPTICK

; Called where LPRINT checks BREAK between native operations. KBDFAST cannot
; run inside the native motor phase. Always return NZ: Margin Release is ^C.
TTYPAPERKEY PSHB
        PSHX
        JSR TTYSERVICE
        PULX
        PULB
        JSR TTYKEY
        LDAA #1
        RTS
; Fault loop sends only the final flow byte and never reopens CTS.
TTYFAULTTX LDAA $11
        BITA #$20
        BEQ TFAULTRET
        LDAA FLOWTX
        BEQ TFAULTRET
        CLR FLOWTX
        STAA $13
TFAULTRET RTS
TTYHELPEND EQU *
