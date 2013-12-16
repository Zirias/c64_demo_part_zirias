;
; "AmigaDOS" line input for CLI -- Felix Palmen <felix@palmen-it.de> 12/2013
;

.include "console.inc"
.include "kbinput.inc"

.export cmd_getnext

.segment "ADBSS"

currentline:    .res 256
currentpos:     .res 1

.segment "AMIGADOS"

cmd_getnext:
                lda     #0
                sta     currentline
                sta     currentpos

cgn_mainloop:   jsr     kb_in
                bcs     cgn_mainloop
                bvs     cgn_handlectrl
                ldx     currentline
                cpx     currentpos
                bne     cgn_insert
                sta     currentline+1,x
                inx
                stx     currentline
                stx     currentpos
                jsr     con_chrout
                jmp     cgn_mainloop

cgn_insert:     jmp     cgn_mainloop

cgn_handlectrl: bmi     cgn_mainloop    ; keys with CTRL-modifier not handled
                asl     a
                cmp     #ctrltablesize+2
                bcc     cgn_jumptocmd
                jmp     cgn_mainloop
cgn_jumptocmd:  tax
                lda     ctrltable-2,x
                sta     cgn_cmdjump
                lda     ctrltable-1,x
                sta     cgn_cmdjump+1
cgn_cmdjump     = *+1
                jmp     $ffff

cgn_right:      jmp     cgn_mainloop

cgn_left:       jmp     cgn_mainloop

cgn_enter:      jsr     con_newline
                lda     #<currentline
                ldx     #>currentline
                rts

cgn_home:       jmp     cgn_mainloop

cgn_end:        jmp     cgn_mainloop

cgn_backspace:  jmp     cgn_mainloop

cgn_cancel:     jsr     con_newline
                lda     #0
                tax
                rts

.segment "ADDATA"

ctrltable:
                .word   cgn_mainloop    ; KBC_F1
                .word   cgn_mainloop    ; KBC_F2
                .word   cgn_mainloop    ; KBC_F3
                .word   cgn_mainloop    ; KBC_F4
                .word   cgn_mainloop    ; KBC_F5
                .word   cgn_mainloop    ; KBC_F6
                .word   cgn_mainloop    ; KBC_F7
                .word   cgn_mainloop    ; KBC_F8
                .word   cgn_mainloop    ; KBC_DOWN
                .word   cgn_mainloop    ; KBC_UP
                .word   cgn_right       ; KBC_RIGHT
                .word   cgn_left        ; KBC_LEFT
                .word   cgn_enter       ; KBC_ENTER
                .word   cgn_mainloop    ; KBC_ENTER1
                .word   cgn_home        ; KBC_HOME
                .word   cgn_end         ; KBC_CLEAR
                .word   cgn_backspace   ; KBC_BACKSPACE
                .word   cgn_mainloop    ; KBC_INSERT
                .word   cgn_mainloop    ; KBC_CBM
                .word   cgn_mainloop    ; KBC_CBM1
                .word   cgn_cancel      ; KBC_STOP
                .word   cgn_mainloop    ; KBC_RUN
ctrltablesize   = *-ctrltable

; vim: et:si:ts=8:sts=8:sw=8
