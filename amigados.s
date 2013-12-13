;
; AmigaDOS main file
;
; - draw window border
; - control console
; - load and execute programs
;

.export clear_window

.export raster_24row
.export raster_25row
.export raster_zone0
.export raster_zone1
.export raster_resizer
.export raster_screen
.export raster_border

.include        "fastload.inc"
.include        "gfx.inc"
.include        "vic.inc"
.include        "vicconfig.inc"
.include        "text80.inc"
.include        "sprites.inc"
.include        "spritezone.inc"
.include        "petscii_lc.inc"
.include        "raster.inc"
.include        "keyboard.inc"

.import ziri_ambi

.import font_topaz_80col_petscii_western

.import __ADEXE_LOAD__

.segment "ADEXE"
.res 1                  ; dummy byte to define segment

.segment "ADMAIN"
                .word   amigados

.segment "AMIGADOS"
clear_window:
                jsr     gfx_clear
                ; draw "window" border
                ; left
                ldy     #7
                lda     #0
                sta     $9e
                lda     #>vic_bitmap
                sta     $9f
                ldx     #$19
                lda     #$80
bl_loop:        sta     ($9e),y
                dey
                bpl     bl_loop
                ldy     #7
                inc     $9f
                lda     $9e
                clc
                adc     #$40
                bcc     bl_noinc
                inc     $9f
bl_noinc:       sta     $9e
                lda     #$80
                dex
                bne     bl_loop
                ; right
                ldy     #7
                lda     #$38
                sta     $9e
                lda     #>vic_bitmap + 1
                sta     $9f
                ldx     #$19
                lda     #$01
br_loop:        sta     ($9e),y
                dey
                bpl     br_loop
                ldy     #7
                inc     $9f
                lda     $9e
                clc
                adc     #$40
                bcc     br_noinc
                inc     $9f
br_noinc:       sta     $9e
                lda     #$01
                dex
                bne     br_loop
                ; bottom
                dec     $9f
                lda     #$3f
                sta     $9e
                ldx     #$28
                lda     #$ff
                ldy     #0
bb_loop:        sta     ($9e),y
                lda     $9e
                sec
                sbc     #$08
                bcs     bb_nodec
                dec     $9f
bb_nodec:       sta     $9e
                lda     #$ff
                dex
                bne     bb_loop
                rts

ad_raster:
                lda     #>raster_tbl
                ldx     #<raster_tbl
                ldy     #raster_tbl_len
                jmp     raster_install

amigados:
                ; border color, graphics mode, clear screen
                lda     #6
                sta     BORDER_COLOR
                jsr     gfx_on
                lda     #1
                ldx     #6
                jsr     gfx_setcolor

                ; top-border sprites and cursor
                jsr     sprites_topborder
                jsr     sprites_cursor

                ; raster effects:
                jsr     ad_raster

                ; start messages
                jsr     clear_window
                lda     #>vic_bitmap
                sta     T80_DRAWPAGE
                lda     #<font_topaz_80col_petscii_western
                sta     T80_FONT_L
                lda     #>font_topaz_80col_petscii_western
                sta     T80_FONT_H
                lda     #0
                sta     T80_ROW
                lda     #1
                sta     T80_COL

                lda     #<message1
                sta     T80_STRING_L
                lda     #>message1
                sta     T80_STRING_H
                jsr     t80_print
                jsr     t80_crlf

                lda     #<message2
                sta     T80_STRING_L
                lda     #>message2
                sta     T80_STRING_H
                jsr     t80_print
                jsr     t80_crlf

                lda     #<message3
                sta     T80_STRING_L
                lda     #>message3
                sta     T80_STRING_H
                jsr     t80_print
                jsr     t80_crlf

                lda     #<message4
                sta     T80_STRING_L
                lda     #>message4
                sta     T80_STRING_H
                jsr     t80_print
                jsr     t80_crlf

                ; handle cursor from here
                jsr     t80_crlf_cursor
                jsr     t80_crlf_cursor

                jmp     kbtest

                lda     #<message5
                sta     T80_STRING_L
                lda     #>message5
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor

                lda     #<message6
                sta     T80_STRING_L
                lda     #>message6
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor

                lda     #<message7
                sta     T80_STRING_L
                lda     #>message7
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor

                lda     #<message8
                sta     T80_STRING_L
                lda     #>message8
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor

                lda     #<message9
                sta     T80_STRING_L
                lda     #>message9
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor
                jsr     t80_crlf_cursor

                lda     #<message10
                sta     T80_STRING_L
                lda     #>message10
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor
                jsr     t80_crlf_cursor

                lda     #<message11
                sta     T80_STRING_L
                lda     #>message11
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor
                jsr     t80_crlf_cursor

                lda     #<message12
                sta     T80_STRING_L
                lda     #>message12
                sta     T80_STRING_H
                jsr     t80_print_cursor

                lda     #'m'
                sta     fl_filename
                lda     #'u'
                sta     fl_filename+1
                lda     #<__ADEXE_LOAD__
                sta     fl_loadaddr
                lda     #>__ADEXE_LOAD__
                sta     fl_loadaddr+1
                jsr     fastload

                lda     #<message13
                sta     T80_STRING_L
                lda     #>message13
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor
                jsr     t80_crlf_cursor
                jsr     t80_crlf_cursor

                lda     #<message14
                sta     T80_STRING_L
                lda     #>message14
                sta     T80_STRING_H
                jsr     t80_print_cursor
                jsr     t80_crlf_cursor

                ; clear key
                lda     #0
                sta     key_pressed

waitkey:        lda     key_pressed
                beq     waitkey
                jsr     fl_run

                jsr     gfx_off
                lda     #0
                sta     SPRITE_SHOW
                rts

; raster payload for switching to 24 rows text mode
; needs stabilization in music part
raster_24row:
                stx     RASTER_TBL_OFFSET
                inc     VIC_RASTER
                lda     #$ff
                sta     VIC_IRR
                lda     #<raster_24rbt
                sta     $fffe
                lda     #>raster_24rbt
                sta     $ffff
                sty     RASTER_SAVE_Y
                tsx
                cli
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
raster_24rbt:   txs
                lda     #<raster_top
                sta     $fffe
                lda     #>raster_top
                sta     $ffff
                ldy     #1
                dey
                bne     *-1
                nop
                ldx     RASTER_TBL_OFFSET
                lda     VIC_CTL1
                and     #%11110111
                sta     VIC_CTL1
                and     #%11011111
                sta     VIC_CTL1
                ldy     RASTER_SAVE_Y
                jmp     raster_bottom

; raster payload for switching to 25 rows hires mode
raster_25row:
                lda     VIC_CTL1
                ora     #%00101000
                sta     VIC_CTL1
                jmp     raster_bottom

; raster payload for switching to sprite zone 0
raster_zone0:
                sty     RASTER_SAVE_Y
                stx     RASTER_TBL_OFFSET
                jsr     sprite_zone0
                ldx     RASTER_TBL_OFFSET
                ldy     RASTER_SAVE_Y
                jmp     raster_bottom

; raster payload for switching to sprite zone 1
raster_zone1:
                sty     RASTER_SAVE_Y
                stx     RASTER_TBL_OFFSET
                jsr     sprite_zone1
                ldx     RASTER_TBL_OFFSET
                ldy     RASTER_SAVE_Y
                jmp     raster_bottom

; payload for drawing window resizer
raster_resizer:
                lda     #$ff
                sta     vic_bitmap + $1f38
                sta     vic_bitmap + $1f3f
                lda     #$ed
                sta     vic_bitmap + $1f3c
                sta     vic_bitmap + $1f3d
                lda     #$8f
                sta     vic_bitmap + $1f39
                lda     #$af
                sta     vic_bitmap + $1f3a
                lda     #$81
                sta     vic_bitmap + $1f3b
                lda     #$e1
                sta     vic_bitmap + $1f3e
                jmp     raster_bottom

; payload for start of the Amiga screen bar
raster_screen:
                lda     #1
                nop
                nop
                nop
                nop
                nop
                sta     BG_COLOR_0
                jmp     raster_bottom

; payload for window border, this has to be stabilized
raster_border:
                stx     RASTER_TBL_OFFSET
                inc     VIC_RASTER
                lda     #$ff
                sta     VIC_IRR
                lda     #<raster_brbt
                sta     $fffe
                lda     #>raster_brbt
                sta     $ffff
                sty     RASTER_SAVE_Y
                tsx
                cli
                nop
                nop
                nop
                nop
                nop
                nop
raster_brbt:    txs
                lda     #<raster_top
                sta     $fffe
                lda     #>raster_top
                sta     $ffff
                ldx     RASTER_TBL_OFFSET
                ldy     #$3
                dey
                bne     *-1
                lda     #6
                sta     BG_COLOR_0
                ldy     #$8
                dey
                bne     *-1
                lda     #1
                sta     BG_COLOR_0
                ldy     #$f
                dey
                bne     *-1
                lda     #6
                sta     BG_COLOR_0
                ldy     #$10
                dey
                bne     *-1
                nop
                lda     #1
                sta     BG_COLOR_0
                ldy     #$10
                dey
                bne     *-1
                nop
                nop
                lda     #6
                sta     BG_COLOR_0
                ldy     #$f
                dey
                bne     *-1
                nop
                lda     #1
                nop
                nop
                sta     BG_COLOR_0
                ldy     #$10
                dey
                bne     *-1
                lda     #6
                sta     BG_COLOR_0
                ldy     RASTER_SAVE_Y
                jmp     raster_bottom

kbtest:
                jsr     kb_init
kbloop:         jsr     kb_check
                jsr     kb_get
                bcs     kbloop
                sta     plb
                clc
                lsr
                lsr
                lsr
                lsr
                tax
                lda     kbtesthex,x
                jsr     t80_putc
                inc     T80_COL
plb             = *+1
                lda     #0
                and     #$f
                tax
                lda     kbtesthex,x
                jsr     t80_putc
                dec     T80_COL
                jmp     kbloop

.segment "ADDATA"
kbtesthex:      .byte "0123456789abcdef"

message1:       .asciiz "Copyright &2013 Zirias"
message2:       .asciiz "All rights reserved."
message3:       .asciiz "C64 Workbench and AmigaBASIC style Demo Disk."
message4:       .asciiz "Release 1.09a2, 2013-12-13"

message5:       .asciiz "This demo started in 2006 and mimicks the style of the AmigaBASIC"
message6:       .asciiz "demo `Music'. The goal was to make it look just like an Amiga."
message7:       .asciiz "There are still some minor inaccuracies compared to original Amiga"
message8:       .asciiz "Workbench for technical reasons -- Can you spot them? Of course I"
message9:       .asciiz "do not mean the low res (3 px wide) `topaz' font ;)"


message10:      .asciiz "Any key can be pressed to exit the demo."

message11:      .asciiz "Contact: Felix Palmen <felix@palmen-it.de>"

message12:      .asciiz "loading demo `Music' ... "
message13:      .asciiz "done."


message14:      .asciiz "  -- Press any key to start --"

raster_tbl:
                .byte 27, $80
                .word raster_screen

                .byte 35, $00
                .word raster_border

                .byte 50, $00
                .word raster_25row

                .byte 52, $00
                .word raster_zone1

                .byte 80, $00
                .word raster_keycheck

                .byte 243, $00
                .word raster_resizer

                .byte 249, $00
                .word raster_24row

                .byte 27, $80
                .word raster_zone0

raster_tbl_len  = *-raster_tbl


; vim: et:si:ts=8:sts=8:sw=8
