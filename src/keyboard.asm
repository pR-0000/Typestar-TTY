; CODE is a modifier for control characters and three local commands.
; Remove its matrix bit while scanning the companion key. KBDFAST still
; supplies the existing two-sample debounce and regional plain-key mapping.
TTYSCAN CLR CODEHELD
        LDAA #$7F
        STAA $31
        LDAA $30
        ORAA $30
        BITA #8
        BNE TSCANSTART
        INC CODEHELD
TSCANSTART LDAA #56
        STAA KBASE
        LDAA #$7F
        STAA KROW
TSCANROW STAA $31
        ; A full matrix sweep exceeds one frame at 31250 baud. Poll between
        ; rows; KBDFAST already saves B/X and the row loop reloads both.
        PSHA
        JSR TTYSERVICE
        PULA
        LDAA $30
        ORAA $30
        LDAB KBASE
        CMPB #56
        BNE TSCANBITS
        ORAA #8
TSCANBITS CMPA #$FF
        BNE TSCANFOUND
        LDAA KBASE
        BEQ TSCANNONE
        SUBA #8
        STAA KBASE
        LDAA KROW
        LSRA
        ORAA #$80
        STAA KROW
        BRA TSCANROW
TSCANFOUND LDAB KBASE
TSCANBIT LSRA
        BCC TSCANVALUE
        INCB
        BRA TSCANBIT
TSCANVALUE TBA
        TST CODEHELD
        BEQ TSCANRETURN
        ORAA #$80
TSCANRETURN PSHA
        LDAA #$FF
        STAA $31
        JSR TTYSERVICE           ; stable-key decoding follows this return
        PULA
        RTS
TSCANNONE LDAA #$FF
        STAA $31
        RTS

; KBDFAST enters with its A/B/X frame intact. Synthetic CODE events skip
; regional translation. Plain keys continue to the packed BASIC key map.
TTYTRANSLATE TSTA
        BMI TCODEKEY
        CMPA #44
        BCC TTRANSLATENONE
TTYMAPENTRY JSR TTYSERVICE
        JMP KDENTRY
TTRANSLATENONE JMP KBDNONE
TCODEKEY ANDA #$7F
        CMPA #44
        BCC TCODESPECIAL
        ; Translate the printed key through the configured regional map.
        ; KDENTRY returns through KBDRETURN, so supply its usual B/X frame.
        STAA KRAW
        JSR TCODEMAP
        LDAB KRAW
        ORAB #$80
        STAB KRAW
        ANDA #$5F
        CMPA #'A'
        BCS TTRANSLATENONE
        CMPA #'Z'
        BHI TTRANSLATENONE
        ANDA #$1F
        JMP KBDRETURN
TCODEMAP PSHB
        PSHX
        JMP TTYMAPENTRY
TCODESPECIAL CMPA #$2C
        BNE TCODERETURN
        LDAA #$80                ; CODE+SPACE opens setup
        JMP KBDRETURN
TCODERETURN CMPA #$2D
        BNE TCODEFLUSH
        LDAA #$81                ; CODE+RETURN advances the local paper
        JMP KBDRETURN
TCODEFLUSH CMPA #$2F
        BNE TCODEESC
        LDAA #$82                ; CODE+BACKSPACE flushes the pending fragment
        JMP KBDRETURN
TCODEESC CMPA #$36
        BNE TTRANSLATENONE
        LDAA #27
        JMP KBDRETURN

TTYKEY PSHB
        PSHX
        JSR KBDFAST
        PSHA
        JSR TTYSERVICE           ; regional translation + TX enqueue need a poll
        PULA
        TSTA
        BEQ TKEYEARLY
        TST MENUACTIVE
        BEQ TKEYONLINE
        JSR TTYMENUKEY
TKEYEARLY PULX
        PULB
        RTS
TKEYONLINE CMPA #$80
        BNE TKEYFEED
        LDAB #3
        BRA TKEYLOCAL
TKEYFEED CMPA #$81
        BNE TKEYFLUSH
        LDAB #1
        BRA TKEYLOCAL
TKEYFLUSH CMPA #$82
        BNE TKEYCHAR
        LDAB #2
TKEYLOCAL TST LOCALCMD
        BNE TKEYEARLY
        STAB LOCALCMD
        BRA TKEYEARLY
TKEYCHAR CMPA #3
        BEQ TKEYACCEPT
        CMPA #8
        BEQ TKEYACCEPT
        CMPA #13
        BEQ TKEYACCEPT
        CMPA #31
        BHI TKEYASCII
        LDAB KRAW
        BMI TKEYACCEPT
        BRA TKEYEND
TKEYASCII EQU *
        CMPA #32
        BCS TKEYEND
        CMPA #126
        BHI TKEYEND
TKEYACCEPT STAA TMPKEY
        ; Reserve two TX slots before queuing CRLF. No partial key packet.
        LDAA TXTAIL
        SUBA TXHEAD
        DECA
        ANDA #31
        BEQ TKEYFULL
        LDAB TMPKEY
        CMPB #13
        BNE TKEYONE
        TST RETURNSEL
        BEQ TKEYONE
        CMPA #2
        BCS TKEYFULL
        LDAA #13
        JSR TKEYPUT
        LDAA #10
        BRA TKEYQUEUED
TKEYONE LDAA TMPKEY
TKEYQUEUED JSR TKEYPUT
        TST ECHOSEL
        BEQ TKEYEND
        LDAB EHEAD
        INCB
        ANDB #31
        CMPB ETAIL
        BEQ TECHOOVERFLOW
        PSHB
        LDAB EHEAD
        LDX #ECHOQUEUE
        ABX
        LDAA TMPKEY
        STAA ,X
        PULB
        STAB EHEAD
        BRA TKEYEND
TECHOOVERFLOW LDAA UIERROR
        ORAA #16
        BRA TKEYERROR
TKEYFULL LDAA UIERROR
        ORAA #8
        INC TXLOSS
TKEYERROR STAA UIERROR
        LDAA #1
        STAA UIUPDATE
TKEYEND JSR TTYSERVICE
        PULX
        PULB
        RTS
TKEYPUT PSHA
        JSR TTYSERVICE
        PULA
        LDAB TXHEAD
        LDX #TXBUF
        ABX
        STAA ,X
        INCB
        ANDB #31
        STAB TXHEAD
        RTS

; The regional key map may scan several packed pairs before a match. Keep
; the original LDAA/BMI behavior while servicing RX on every lookup step.
TTYMAPREAD PSHB
        PSHX
        JSR TTYSERVICE
        PULX
        PULB
        LDAA ,X
        BMI TMAPDEFAULT
        JMP $4D5B
TMAPDEFAULT JMP $4D78
TTYKEYEND EQU *
