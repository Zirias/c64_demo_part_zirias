;
; "AmigaDOS" line input for CLI -- Felix Palmen <felix@palmen-it.de> 12/2013
;

.include "console.inc"
.include "kbinput.inc"
.include "text80.inc"

.export cmd_getnext

.segment "ADBSS"

currentline:    .res 256
currentpos:     .res 1
linestartrow:   .res 1
linestartcol:   .res 1

.segment "AMIGADOS"

cmd_getnext:
                lda     #0
                sta     currentline
                sta     currentpos
                lda     T80_ROW
                sta     linestartrow
                lda     T80_COL
                sta     linestartcol

cgn_mainloop:   jsr     kb_in
                bcs     cgn_mainloop
                bvs     cgn_handlectrl
                ldx     currentline
                cpx     #$ff
                beq     cgn_mainloop
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

cgn_right:      lda     currentpos
                cmp     currentline
                beq     cgn_mainloop
                inc     currentpos
                jsr     con_crsrright
                jmp     cgn_mainloop

cgn_left:       lda     currentpos
                beq     cgn_mainloop
                dec     currentpos
                jsr     con_crsrleft
                jmp     cgn_mainloop

cgn_enter:      jsr     con_newline
                lda     #<currentline
                ldx     #>currentline
                rts

cgn_backspace:  lda     currentpos
                beq     cgn_mainloop
                cmp     currentline
                bne     cgn_delmiddle
                jsr     con_crsrleft
                lda     #$20
                jsr     con_setchr
                dec     currentline
                ldx     currentpos
                dex
                sta     currentline+1,x
                stx     currentpos
                jmp     cgn_mainloop

cgn_home:       lda     #0
                sta     currentpos
                lda     linestartrow
                sta     T80_ROW
                lda     linestartcol
                sta     T80_COL
                jsr     con_setcrsr
                jmp     cgn_mainloop

cgn_end:        ldx     linestartrow
                lda     linestartcol
                adc     currentline
cend_checkcol:  cmp     #77
                bcc     cend_ok
                sbc     #77
                inx
                bpl     cend_checkcol
cend_ok:        sta     T80_COL
                stx     T80_ROW
                lda     currentline
                sta     currentpos
                jsr     con_setcrsr
                jmp     cgn_mainloop

cgn_delmiddle:  jmp     cgn_mainloop

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
