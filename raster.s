;
; raster IRQ handling
;
; - framework for loading and using raster tables
; - keyboard checking

.include "vic.inc"
.include "keyboard.inc"

.export raster_on
.export raster_off
.export raster_install

.exportzp RASTER_SAVE_A
.exportzp RASTER_SAVE_X
.exportzp RASTER_SAVE_Y
.exportzp RASTER_TBL_OFFSET
.export raster_bottom
.export raster_tbl_base
.export raster_top

.export raster_keycheck

.segment "ZPSYS": zeropage
RASTER_SAVE_A:          .res 1
RASTER_SAVE_X:          .res 1
RASTER_SAVE_Y:          .res 1
RASTER_TBL_OFFSET:      .res 1

.segment "KSBSS"
raster_table:   .res    255
raster_tbl_base = raster_table - 1

.segment "KICKSTART"

; common entry code for every IRQ
; avoid any branching before payload
raster_top:
                sta     RASTER_SAVE_A
                stx     RASTER_SAVE_X
                ldx     RASTER_TBL_OFFSET
                dex
                lda     raster_tbl_base,x
                sta     raster_payload
                dex
                lda     raster_tbl_base,x
                sta     raster_payload+1
raster_payload = *+1
                jmp     raster_bottom

; payload for checking the keyboard
raster_keycheck:
                stx     RASTER_TBL_OFFSET
                jsr     kb_check
                ldx     RASTER_TBL_OFFSET

; common exit code for every IRQ
raster_bottom:
                lda     #$ff
                sta     VIC_IRR
                dex
                bne     tbl_offset_ok
tbl_size = *+1
                ldx     #0
tbl_offset_ok:
                lda     raster_tbl_base,x
                sta     VIC_RASTER
                dex
                lda     raster_tbl_base,x
                eor     VIC_CTL1
                sta     VIC_CTL1
                stx     RASTER_TBL_OFFSET
                ldx     RASTER_SAVE_X
                lda     RASTER_SAVE_A
                rti

; install raster table given in A (hb) / X (lb) / Y (size)
raster_install:
                stx     r_installload
                sta     r_installload+1
                sei
                sty     tbl_size
                sty     RASTER_TBL_OFFSET
                ldx     #0
r_installload   = *+1
r_installloop:  lda     $ffff,x
                sta     raster_tbl_base,y
                inx
                dey
                bne     r_installloop
                ldy     tbl_size
                lda     raster_tbl_base,y
                sta     VIC_RASTER
                lda     VIC_CTL1
                and     #%01111111
                sta     VIC_CTL1
                lda     #<raster_top
                sta     $fffe
                lda     #>raster_top
                sta     $ffff
                dec     RASTER_TBL_OFFSET
                cli
                rts

; activate raster IRQ using table for phase 0
raster_on:
                lda     #%01111111
                sta     $dc0d
                lda     $dc0d
                lda     #%00000001
                sta     VIC_IRM
                sta     VIC_IRR
                lda     #$35
                sta     $01

                ; load default table
                lda     #>raster_def_tbl
                ldx     #<raster_def_tbl
                ldy     #raster_def_tbl_len
                jmp     raster_install

; deactivate raster IRQ
raster_off:
                sei
                lda     #0
                sta     VIC_IRM
                sta     VIC_IRR
                lda     #$37
                sta     $01
                lda     #%10000011
                sta     $dc0d
                cli
                rts

.segment "KSDATA"

; default raster table
; entry format:
;       .byte   [rasterline]
;       .byte   [ctl-eor]               // use $80 to flip bit 9 of rasterline
;       .word   [payload]               // payload address
;       [.byte  [arg1], [arg2], ...]    // arguments for payload

raster_def_tbl:
                .byte 80, $00
                .word raster_keycheck

raster_def_tbl_len = *-raster_def_tbl

; vim: et:si:ts=8:sts=8:sw=8
