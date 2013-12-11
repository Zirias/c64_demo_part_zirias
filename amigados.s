;
; demo inspired by AmigaBASIC demo
;

GETKB           = $F142

tbllen          = 195

.export clear_window

.include        "fastload.inc"
.include        "gfx.inc"
.include        "vic.inc"
.include        "vicconfig.inc"
.include        "snd.inc"
.include        "text80.inc"
.include        "sprites.inc"
.include        "petscii_lc.inc"

.import ziri_ambi

.import font_topaz_80col_petscii_western

.import raster_on
.import raster_off
.import raster_phase1
.import key_pressed

.import __ADEXE_LOAD__

.segment "ADEXE"
.res 1                  ; dummy byte to define segment

.segment "ADBSS"
border:         .res    1

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

amigados:
                ; border color, graphics mode, clear screen
                lda     BORDER_COLOR
                sta     border
                lda     #6
                sta     BORDER_COLOR
                jsr     gfx_init
                lda     #1
                ldx     #6
                jsr     gfx_setcolor

                ; top-border sprites and cursor
                jsr     sprites_topborder
                jsr     sprites_cursor

                ; raster effects:
                jsr     raster_on

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

loadname        = *+1
                lda     #'m'
                beq     noload
                sta     fl_filename
                lda     #'u'
                sta     fl_filename+1
                lda     #<__ADEXE_LOAD__
                sta     fl_loadaddr
                lda     #>__ADEXE_LOAD__
                sta     fl_loadaddr+1
                lda     #0
                sta     loadname
                jsr     fastload

noload:         lda     #<message13
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

                jsr     raster_off
                jsr     gfx_done
                jsr     snd_stop
                lda     #0
                sta     SPRITE_SHOW
                lda     border
                sta     BORDER_COLOR
eat_keys:       jsr     GETKB
                bne     eat_keys
                rts

.segment "ADDATA"
message1:       .asciiz "Copyright &2013 Zirias"
message2:       .asciiz "All rights reserved."
message3:       .asciiz "C64 Workbench and AmigaBASIC style Demo Disk."
message4:       .asciiz "Release 1.01, 2013-12-07"

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

; vim: et:si:ts=8:sts=8:sw=8
