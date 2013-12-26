;
; "AmigaDOS" console -- Felix Palmen <felix@palmen-it.de> 12/2013
;
; This module provides the basic console functionality:
;
; - clear screen
; - scroll upwards
; - get/put character to given position
; - redraw screen
; - output character
; - print (pascal) string to console
; - turn on/off cursor sprite
; - update cursor position
;
; T80_ROW / T80_COL from text80 module is used as the cursor position
;

.include "spritezone.inc"
.include "text80.inc"
.include "amigados.inc"
.include "vicconfig.inc"
.include "kickstart.inc"

.export con_clrscr
.export con_redraw
.export con_getchr
.export con_setchr
.export con_chrout
.export con_newline
.export con_print
.export con_savecrsr
.export con_restorecrsr
.export con_showcrsr
.export con_hidecrsr
.export con_crsrleft
.export con_crsrright
.export con_setcrsr

TMP             = TMP_5

.segment "ADBSS"

con_screen:     .res    77 * 24
cursor_savex:   .res    1
cursor_savey:   .res    1

.segment "AMIGADOS"

; scroll screen upwards one row -- preserves X
scrollscr:
                stx     TMP

                ; move 32 rows upwards by one
                ldy     #92
cs_outer:       lda     rowoffsets-1,y
                sta     cs_read1base+1
                lda     rowoffsets+3,y
                sta     cs_write1base+1
                dey
                lda     rowoffsets-1,y
                sta     cs_read1base
                lda     rowoffsets+3,y
                sta     cs_write1base
                dey
                lda     rowoffsets-1,y
                sta     cs_read2base+1
                lda     rowoffsets+3,y
                sta     cs_write2base+1
                dey
                lda     rowoffsets-1,y
                sta     cs_read2base
                lda     rowoffsets+3,y
                sta     cs_write2base
                ldx     #0
cs_read1base    = *+1
cs_inner:       lda     $ffff,x
cs_write1base   = *+1
                sta     $ffff,x
cs_read2base    = *+1
                lda     $ffff,x
cs_write2base   = *+1
                sta     $ffff,x
                inx
                cpx     #$a0
                bne     cs_inner
                dey
                bne     cs_outer

                ; empty left frame part in row #24 (right frame untouched)
                ldx     #$7
                lda     #$80
cs_frame:       sta     vic_bitmap + $1cc0,x
                dex
                bpl     cs_frame

                ; empty row #24 (#25 stays always empty)
                ldx     #$98
                lda     #0
cs_clear:       sta     vic_bitmap + $1cc7,x
                sta     vic_bitmap + $1d5f,x
                dex
                bne     cs_clear

                ; scroll screen memory
                ldy     #0
css_outer:      lda     screenrows,y
                sta     css_sta
                lda     screenrows+2,y
                sta     css_lda
                iny
                lda     screenrows,y
                sta     css_sta+1
                lda     screenrows+2,y
                sta     css_lda+1
                ldx     #0
css_lda         = *+1
css_inner:      lda     $ffff,x
css_sta         = *+1
                sta     $ffff,x
                inx
                cpx     #77
                bne     css_inner
                iny
                cpy     #46
                bne     css_outer
                ldx     #0
                lda     #$20
ccs_space:      sta     con_screen + 1771,x
                inx
                cpx     #77
                bne     ccs_space

                dec     T80_ROW
                ldx     TMP
                rts

; clear the screen
con_clrscr:
                lda     #$20
                ldx     #$37
ccs_loopextra:  sta     con_screen + $700,x
                dex
                bpl     ccs_loopextra
                ldy     #7
                ldx     #0
ccs_stapage     = *+2
ccs_loop:       sta     con_screen, x
                inx
                bne     ccs_loop
                dey
                beq     ccs_done
                inc     ccs_stapage
                jmp     ccs_loop
ccs_done:       lda     #>con_screen
                sta     ccs_stapage
                jsr     clear_window
                lda     #0
                sta     T80_ROW
                sta     T80_COL
                jsr     con_setcrsr
                rts

; save cursor position
; should be called before running any application with direct screen access
con_savecrsr:
                lda     T80_ROW
                sta     cursor_savey
                lda     T80_COL
                sta     cursor_savex
                rts

; redraw console screen contents
; uses saved cursor position, so save it timely
con_redraw:
                jsr     clear_window
                ldy     #23
crd_outer:      sty     T80_ROW
                tya
                asl     a
                tay
                lda     screenrows,y
                sta     crd_lda
                lda     screenrows+1,y
                sta     crd_lda+1
                ldx     #0
crd_inner:      stx     T80_COL
crd_lda         = *+1
                lda     $ffff,x
                jsr     t80_putc
                inx
                cpx     #77
                bne     crd_inner
                ldy     T80_ROW
                dey
                bpl     crd_outer

; restore saved cursor position
con_restorecrsr:
                lda     cursor_savey
                sta     T80_ROW
                lda     cursor_savex
                sta     T80_COL

; update cursor position to T80_ROW/T80_COL
; preserves X, Y
con_setcrsr:
                lda     sprite_1_show
                beq     nocrsr
                lda     T80_ROW
                asl     a
                asl     a
                asl     a
                adc     #$32
                sta     sprite_1_0_y
                lda     #0
                sta     sprite_1_x_h
                lda     T80_COL
                asl     a
                asl     a
                bcc     uc_noh1
                inc     sprite_1_x_h
uc_noh1:        adc     #$1c
                bcc     uc_noh2
                inc     sprite_1_x_h
uc_noh2:        sta     sprite_1_0_x
nocrsr:         rts        

; show cursor
con_showcrsr:
                lda     #1
                sta     sprite_1_show
                rts

; hide cursor
con_hidecrsr:
                lda     #0
                sta     sprite_1_show
                rts

; set character at position T80_ROW/T80_COL
; preserves X
con_setchr:
                sta     TMP
                jsr     t80_putc
                lda     T80_ROW
                asl     a
                tay
                lda     screenrows,y
                sta     csc_sta
                lda     screenrows+1,y
                sta     csc_sta+1
                lda     TMP
                ldy     T80_COL
csc_sta         = *+1
                sta     $ffff,y
                rts

; get character at position T80_ROW/T80_COL
; preserves X
con_getchr:
                lda     T80_ROW
                asl     a
                tay
                lda     screenrows,y
                sta     cgc_lda
                lda     screenrows+1,y
                sta     cgc_lda+1
                ldy     T80_COL
cgc_lda         = *+1
                lda     $ffff,y
                rts

; move cursor to the left
con_crsrleft:
                lda     T80_COL
                beq     ccl_lineup
                dec     T80_COL
                jmp     con_setcrsr
ccl_lineup:     lda     T80_ROW
                bne     ccl_setline
                rts
ccl_setline:    dec     T80_ROW
                lda     #76
                sta     T80_COL
                jmp     con_setcrsr
                
; print character at position T80_ROW/T80_COL
; updates T80_ROW/T80_COL and cursor position accordingly
; line wrapping and screen scrolling is handled
; preserves X
con_chrout:
                jsr     con_setchr

; move cursor to the right -- this is exactly the same
; routing as con_chrout except it doesn't actually print anything
con_crsrright:
                lda     #76
                cmp     T80_COL
                beq     con_newline
                inc     T80_COL
                jmp     con_setcrsr

; start new line in console window, scrolling handled automatically
; preserves X
con_newline:
                lda     #0
                sta     T80_COL
                ldy     T80_ROW
                iny
                sty     T80_ROW
                cpy     #24
                bne     cnl_noscroll
                jsr     scrollscr
cnl_noscroll:   jmp     con_setcrsr

; print pascal string given in A/X starting at T80_ROW/T80_COL
con_print:
                sta     cp_read
                sta     cp_cmp
                stx     cp_read+1
                stx     cp_cmp+1
                ldx     #0
cp_loop:        inx
cp_read         = *+1
                lda     $ffff,x
                jsr     con_chrout
cp_cmp          = *+1
                cpx     $ffff
                bne     cp_loop
                rts

.segment "ADDATA"

screenrows:
                .word   con_screen
                .word   con_screen + 77
                .word   con_screen + 154
                .word   con_screen + 231
                .word   con_screen + 308
                .word   con_screen + 385
                .word   con_screen + 462
                .word   con_screen + 539
                .word   con_screen + 616
                .word   con_screen + 693
                .word   con_screen + 770
                .word   con_screen + 847
                .word   con_screen + 924
                .word   con_screen + 1001
                .word   con_screen + 1078
                .word   con_screen + 1155
                .word   con_screen + 1232
                .word   con_screen + 1309
                .word   con_screen + 1386
                .word   con_screen + 1463
                .word   con_screen + 1540
                .word   con_screen + 1617
                .word   con_screen + 1694
                .word   con_screen + 1771
rowoffsets:
                .word   vic_bitmap + $1d60, vic_bitmap + $1cc0
                .word   vic_bitmap + $1c20, vic_bitmap + $1b80
                .word   vic_bitmap + $1ae0, vic_bitmap + $1a40
                .word   vic_bitmap + $19a0, vic_bitmap + $1900
                .word   vic_bitmap + $1860, vic_bitmap + $17c0
                .word   vic_bitmap + $1720, vic_bitmap + $1680
                .word   vic_bitmap + $15e0, vic_bitmap + $1540
                .word   vic_bitmap + $14a0, vic_bitmap + $1400
                .word   vic_bitmap + $1360, vic_bitmap + $12c0
                .word   vic_bitmap + $1220, vic_bitmap + $1180
                .word   vic_bitmap + $10e0, vic_bitmap + $1040
                .word   vic_bitmap + $fa0, vic_bitmap + $f00
                .word   vic_bitmap + $e60, vic_bitmap + $dc0
                .word   vic_bitmap + $d20, vic_bitmap + $c80
                .word   vic_bitmap + $be0, vic_bitmap + $b40
                .word   vic_bitmap + $aa0, vic_bitmap + $a00
                .word   vic_bitmap + $960, vic_bitmap + $8c0
                .word   vic_bitmap + $820, vic_bitmap + $780
                .word   vic_bitmap + $6e0, vic_bitmap + $640
                .word   vic_bitmap + $5a0, vic_bitmap + $500
                .word   vic_bitmap + $460, vic_bitmap + $3c0
                .word   vic_bitmap + $320, vic_bitmap + $280
                .word   vic_bitmap + $1e0, vic_bitmap + $140
                .word   vic_bitmap + $a0, vic_bitmap

; vim: et:si:ts=8:sts=8:sw=8
