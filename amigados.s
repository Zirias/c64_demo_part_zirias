;
; AmigaDOS main file
;
; - draw window border
; - control console
; - load and execute programs
;

.export clear_window

.export raster_24row
.export raster_zone0
.export raster_zone1
.export raster_resizer
.export raster_screen
.export raster_border

.include        "macros.inc"
.include        "fastload.inc"
.include        "gfx.inc"
.include        "vic.inc"
.include        "vicconfig.inc"
.include        "text80.inc"
.include        "console.inc"
.include        "sprites.inc"
.include        "spritezone.inc"
.include        "petscii_lc.inc"
.include        "raster.inc"
.include        "keyboard.inc"
.include        "cmdline.inc"

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
                lda     #>vic_bitmap
                sta     T80_DRAWPAGE
                lda     #<font_topaz_80col_petscii_western
                sta     T80_FONT_L
                lda     #>font_topaz_80col_petscii_western
                sta     T80_FONT_H
                jsr     con_clrscr

                lda     #<message1
                ldx     #>message1
                jsr     con_print
                jsr     con_newline

                lda     #<message2
                ldx     #>message2
                jsr     con_print
                jsr     con_newline

                lda     #<message3
                ldx     #>message3
                jsr     con_print
                jsr     con_newline

                lda     #<message4
                ldx     #>message4
                jsr     con_print
                jsr     con_newline
                jsr     con_newline
                jsr     con_newline

                lda     #<message5
                ldx     #>message5
                jsr     con_print
                jsr     con_newline

                lda     #<message6
                ldx     #>message6
                jsr     con_print
                jsr     con_newline

                lda     #<message7
                ldx     #>message7
                jsr     con_print
                jsr     con_newline

                lda     #<message8
                ldx     #>message8
                jsr     con_print
                jsr     con_newline

                lda     #<message9
                ldx     #>message9
                jsr     con_print
                jsr     con_newline
                jsr     con_newline

                lda     #<message10
                ldx     #>message10
                jsr     con_print
                jsr     con_newline
                jsr     con_newline

                lda     #<message11
                ldx     #>message11
                jsr     con_print
                jsr     con_newline
                jsr     con_newline

                lda     #<prompt
                ldx     #>prompt
                jsr     con_print
                jsr     cmd_getnext

                lda     #<message12
                ldx     #>message12
                jsr     con_print

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
                ldx     #>message13
                jsr     con_print
                jsr     con_newline
                jsr     con_newline
                jsr     con_newline

                lda     #<message14
                ldx     #>message14
                jsr     con_print
                jsr     con_newline
                jsr     con_newline

                ; clear key
                jsr     kb_clear

waitkey:        jsr     kb_get
                bcs     waitkey
                jsr     con_savecrsr

                ; run demo
                jsr     fl_run

                ; restore console
                lda     #>vic_bitmap
                sta     T80_DRAWPAGE
                lda     #<font_topaz_80col_petscii_western
                sta     T80_FONT_L
                lda     #>font_topaz_80col_petscii_western
                sta     T80_FONT_H
                jsr     sprites_topborder
                jsr     sprites_cursor
                jsr     ad_raster
                jsr     con_redraw

                lda     #<message15
                ldx     #>message15
                jsr     con_print
                jsr     con_newline

                ; clear key
                jsr     kb_clear

waitkey2:       jsr     kb_get
                bcs     waitkey2

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
                lda     VIC_CTL1
                and     #%11110111
                sta     VIC_CTL1
                ldy     #<raster_top
                sty     $fffe
                ldy     #>raster_top
                sty     $ffff
                ldy     RASTER_SAVE_Y
                ldx     RASTER_TBL_OFFSET
                and     #%11011111
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
                ldy     #$e
                dey
                bne     *-1
                lda     #vic_sprite_1_baseptr
                sta     vic_sprite_vectors
                lda     sprite_1_0_x
                sta     SPRITE_0_X
                lda     #10
                sta     SPRITE_0_COL
                lda     sprite_1_0_y
                sta     SPRITE_0_Y
                lda     sprite_1_x_h
                sta     SPRITE_X_HB
                lda     VIC_CTL1
                ora     #%00101000
                sta     VIC_CTL1
                lda     #1
                sta     SPRITE_LAYER
                lda     sprite_1_show
                sta     SPRITE_SHOW
                ldy     RASTER_SAVE_Y
                jmp     raster_bottom

.segment "ADDATA"
prompt:         string "1> "

message1:       string "Copyright &2013 Zirias"
message2:       string "All rights reserved."
message3:       string "C64 Workbench and AmigaBASIC style Demo Disk."
message4:       string "Release 1.09a3, 2013-12-15"

message5:       string "This demo started in 2006 and mimicks the style of the AmigaBASIC"
message6:       string "demo `Music'. The goal was to make it look just like an Amiga."
message7:       string "There are still some minor inaccuracies compared to original Amiga"
message8:       string "Workbench for technical reasons -- Can you spot them? Of course I"
message9:       string "do not mean the low res (3 px wide) `topaz' font ;)"


message10:      string "Any key can be pressed to exit the demo."

message11:      string "Contact: Felix Palmen <felix@palmen-it.de>"

message12:      string "loading demo `Music' ... "
message13:      string "done."


message14:      string "  -- Press any key to start --"

message15:      string "That's it for now ... press any key to go back to BASIC."
raster_tbl:
                .byte 27, $80
                .word raster_screen

                .byte 35, $00
                .word raster_border

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
