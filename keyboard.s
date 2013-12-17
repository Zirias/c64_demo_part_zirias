;
; keyboard hardware driver
;
; Felix Palmen <felix@palmen-it.de> -- 2013-12-14
;
; this driver delivers 1-byte scancodes in the following scheme:
;
; bit    7: CONTROL
; bit    6: SHIFT
; bits 5-3: keyboard matrix row
; bits 2-0: keyboard matrix column
;
; design considerations:
; - make scancodes only one byte, for efficiency
;   this means there are only 2 bits left, the matrix position takes 6 bits
; - use the 2 spare bits for modifiers (CTRL and SHIFT) because modifiers
;   are of greater value to simple CLIs than e.g. "key released" events
; - key repeat has to be implemented here, because calling code has no way to
;   determine whether a key is hold .. for now done with fixed values
;
; up to 15 scancodes are buffered in a ring buffer
;
; call kb_check periodically (e.g. from raster IRQ) to poll keyboard
; call kb_get to get next buffered scancode (carry indicates empty buffer)
; call kb_peek to know if there are scancodes waiting
; call kb_clear to empty scancode buffer

.export kb_get
.export kb_peek
.export kb_clear
.export kb_check

.segment "KSBSS"

buffer:         .res 16

tmp1:           .res 1
tmp2:           .res 1
tmp3:           .res 1

repeatwait:     .res 1
repeatfreq:     .res 1

modmask:        .res 1

.segment "KSDATA"
bufrd:          .byte $f
bufwr:          .byte $f

.segment "KICKSTART"

kb_get:
                ldx     bufrd
                cpx     bufwr
                beq     kbg_out
                lda     buffer,x
                dex
                bpl     kbg_done
                ldx     #$f
kbg_done:       stx     bufrd
                clc
kbg_out:        rts

kb_peek:
                clc
                lda     bufrd
                sbc     bufwr
                rts

kb_clear:
                lda     bufwr
                sta     bufrd
                rts

kb_check:
                lda     #0
                sta     modmask
                sta     tmp1
                sta     tmp3
kbc_row7:       lda     #%01111111
                sta     $dc00
                lda     $dc01
                eor     #$ff
                beq     kbc_row6
                ; check for control:
                tax
                and     #%00000100
                beq     kbc_noctrl
                lda     modmask
                ora     #%10000000
                sta     modmask
kbc_noctrl:     txa
                and     #%11111011
                beq     kbc_row6
                inc     tmp3
                jsr     kbc_col
                adc     #7<<3
                sta     tmp1
kbc_row6:       lda     #%10111111
                sta     $dc00
                lda     $dc01
                eor     #$ff
                beq     kbc_row5
                ; check for right shift:
                tax
                and     #%00010000
                beq     kbc_norsh
                lda     modmask
                ora     #%01000000
                sta     modmask
kbc_norsh:      txa
                and     #%11101111
                beq     kbc_row5
                inc     tmp3
                jsr     kbc_col
                adc     #6<<3
                sta     tmp1
kbc_row5:       lda     #%11011111
                sta     $dc00
                lda     $dc01
                eor     #$ff
                beq     kbc_row4
                inc     tmp3
                jsr     kbc_col
                adc     #5<<3
                sta     tmp1
kbc_row4:       lda     #%11101111
                sta     $dc00
                lda     $dc01
                eor     #$ff
                beq     kbc_row3
                inc     tmp3
                jsr     kbc_col
                adc     #4<<3
                sta     tmp1
kbc_row3:       lda     #%11110111
                sta     $dc00
                lda     $dc01
                eor     #$ff
                beq     kbc_row2
                inc     tmp3
                jsr     kbc_col
                adc     #3<<3
                sta     tmp1
kbc_row2:       lda     #%11111011
                sta     $dc00
                lda     $dc01
                eor     #$ff
                beq     kbc_row1
                inc     tmp3
                jsr     kbc_col
                adc     #2<<3
                sta     tmp1
kbc_row1:       lda     #%11111101
                sta     $dc00
                lda     $dc01
                eor     #$ff
                beq     kbc_row0
                ; check for left shift:
                tax
                and     #%10000000
                beq     kbc_nolsh
                lda     modmask
                ora     #%01000000
                sta     modmask
kbc_nolsh:      txa
                and     #%01111111
                beq     kbc_row0
                inc     tmp3
                jsr     kbc_col
                adc     #1<<3
                sta     tmp1
kbc_row0:       lda     #%11111110
                sta     $dc00
                lda     $dc01
                eor     #$ff
                beq     kbc_buffer
                inc     tmp3
                jsr     kbc_col
                sta     tmp1
kbc_buffer:     lda     tmp3
                bne     kbc_checknew
                lda     #$80
                sta     tmp2
                rts
kbc_checknew:   lda     tmp1
                cmp     tmp2
                beq     kbc_checkrepeat
                sta     tmp2
                ldx     #40
                stx     repeatwait
                ldx     #2
                stx     repeatfreq
kbc_repeatok:   ora     modmask
                ldx     bufwr
                sta     buffer,x
                dex
                bpl     kbc_checkov
                ldx     #$f
kbc_checkov:    stx     bufwr
                cpx     bufrd
                bne     kbc_done
                dex
                bpl     kbc_dropoldest
                ldx     #$f
kbc_dropoldest: stx     bufrd
kbc_done:       rts

kbc_col:        ldx     #7
kbc_colloop:    lsr     a
                bcs     kbc_havekey
                dex
                bpl     kbc_colloop
                rts
kbc_havekey:    txa
                clc
                rts

kbc_checkrepeat:
                ldx     repeatwait
                beq     kbc_dorepeat
                dex
                stx     repeatwait
                rts
kbc_dorepeat:   ldx     repeatfreq
                beq     kbcr_next
                dex
                stx     repeatfreq
                rts
kbcr_next:      ldx     #2
                stx     repeatfreq
                jmp     kbc_repeatok

; vim: et:si:ts=8:sts=8:sw=8
