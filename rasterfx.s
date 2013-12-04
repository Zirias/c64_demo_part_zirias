;
; routines in raster IRQ
;
; - background colors
; - sprites: zone switching, moving and flashing effect
; - music
;

.include "vic.inc"
.include "gfx.inc"
.include "snd.inc"
.include "spritezone.inc"

.export raster_on
.export raster_off
.export raster_phase1
.export key_pressed

SAVE_A          = $22
SAVE_X          = $23
SAVE_Y          = $24
TBL_OFFSET      = $25

.bss

bg_save:        .res    1
flash_offset:   .res    1
flash_counter:  .res    1
key_pressed:    .res    1
raster_table:   .res    255
tbl_base = key_pressed

.code

; common entry code for every IRQ
; avoid any branching before payload
raster_top:
                sta     SAVE_A
                stx     SAVE_X
                ldx     TBL_OFFSET
                dex
                lda     tbl_base,x
                sta     raster_payload
                dex
                lda     tbl_base,x
                sta     raster_payload+1
raster_payload = *+1
                jmp     raster_bottom

; payload for changing background and border color
raster_col:
                nop
                nop
                nop
                dex
                lda     tbl_base,x
                sta     BG_COLOR_0
                nop
                sta     BORDER_COLOR
                jmp     raster_bottom

; payload for switching to 24 rows text mode
raster_24row:
                nop
                nop
                nop
                lda     VIC_CTL1
                and     #%11010111
                sta     VIC_CTL1
                jmp     raster_bottom

; payload for switching to 25 rows hires mode
raster_25row:
                lda     VIC_CTL1
                ora     #%00101000
                sta     VIC_CTL1
                jmp     raster_bottom

; payload for switching to sprite zone 0
raster_zone0:
                sty     SAVE_Y
                stx     TBL_OFFSET
                jsr     sprite_zone0
                ldx     TBL_OFFSET
                ldy     SAVE_Y
                jmp     raster_bottom

; payload for switching to sprite zone 1
raster_zone1:
                sty     SAVE_Y
                stx     TBL_OFFSET
                jsr     sprite_zone1
                ldx     TBL_OFFSET
                ldy     SAVE_Y
                jmp     raster_bottom

; payload for playing music
raster_sound:
                sty     SAVE_Y
                stx     TBL_OFFSET
                jsr     snd_play
                ldx     TBL_OFFSET
                ldy     SAVE_Y
                jmp     raster_bottom

; payload for checking the keyboard
raster_keycheck:
                lda     key_pressed
                bne     key_done
                lda     #0
                sta     $dc03
                lda     #$ff
                sta     $dc02
                lda     #0
                sta     $dc00
                lda     #$ff
                cmp     $dc01
                beq     key_done
                sta     key_pressed
key_done:       jmp     raster_bottom

; payload for drawing window resizer
raster_resizer:
                lda     #$ff
                sta     $7f38
                sta     $7f3f
                lda     #$ed
                sta     $7f3c
                sta     $7f3d
                lda     #$8f
                sta     $7f39
                lda     #$af
                sta     $7f3a
                lda     #$81
                sta     $7f3b
                lda     #$e1
                sta     $7f3e
                jmp     raster_bottom

; payload for animating the marquee
raster_marquee:
                sty     SAVE_Y
                stx     TBL_OFFSET
                ldx     flash_counter
                dex
                stx     flash_counter
                bpl     spmove
                ldx     #1
                stx     flash_counter
                ldx     flash_offset
                lda     #12
                sta     sprite_1_0_col-$f8,x
                inx
                bne     spfok
                ldx     #$f8
spfok:          lda     #1
                sta     sprite_1_0_col-$f8,x
                stx     flash_offset
                ; now move sprites
spmove:         lda     sprite_1_x_h
                ldx     #14
spm_while:      asl
                tay
                bcc     spm_l
                lda     sprite_1_0_x,x
                bne     spm_hd
                lda     #$ff
                sta     sprite_1_0_x,x
                bmi     spm_next
spm_hd:         dec     sprite_1_0_x,x
                iny
                bne     spm_next
spm_l:          lda     sprite_1_0_x,x
                bne     spm_ld
                lda     #$90
                sta     sprite_1_0_x,x
                iny
                bne     spm_next
spm_ld:         dec     sprite_1_0_x,x
spm_next:       tya
                dex
                dex
                bpl     spm_while
                sta     sprite_1_x_h
                ldy     SAVE_Y
                ldx     TBL_OFFSET
                jmp    raster_bottom

; payload for start of the Amiga screen bar
raster_screen:
		lda	#1
		nop
		nop
		nop
		nop
		nop
		sta	BG_COLOR_0
		jmp	raster_bottom

; payload for window border, this has to be stabilized
raster_border:
		stx	TBL_OFFSET
		inc	VIC_RASTER
		lda	#$ff
		sta	VIC_IRR
		lda	#<raster_wintop
		sta	$fffe
		lda	#>raster_wintop
		sta	$ffff
                sty     SAVE_Y
		tsx
		cli
		nop
		nop
		nop
		nop
		nop
		nop

; stabilized top of the window border
raster_wintop:
		txs
		lda	#<raster_top
		sta	$fffe
		lda	#>raster_top
		sta	$ffff
		ldx	TBL_OFFSET
                ldy     #$3
                dey
                bne     *-1
		lda	#6
		sta	BG_COLOR_0
                ldy     #$8
                dey
                bne     *-1
		lda	#1
		sta	BG_COLOR_0
                ldy     #$f
                dey
                bne     *-1
		lda	#6
		sta	BG_COLOR_0
                ldy     #$10
                dey
                bne     *-1
                nop
		lda	#1
		sta	BG_COLOR_0
                ldy     #$10
                dey
                bne     *-1
		nop
		nop
		lda	#6
		sta	BG_COLOR_0
                ldy     #$f
                dey
                bne     *-1
                nop
		lda	#1
		nop
		nop
		sta	BG_COLOR_0
                ldy     #$10
                dey
                bne     *-1
		lda	#6
		sta	BG_COLOR_0
		ldy	SAVE_Y

; common exit code for every IRQ
raster_bottom:
                lda     #$ff
                sta     VIC_IRR
                dex
                bne     tbl_offset_ok
tbl_size = *+1
                ldx     #0
tbl_offset_ok:
                lda     tbl_base,x
                sta     VIC_RASTER
                dex
                lda     tbl_base,x
                eor     VIC_CTL1
                sta     VIC_CTL1
                stx     TBL_OFFSET
                ldx     SAVE_X
                lda     SAVE_A
                rti

; activate raster IRQ using table for phase 0
raster_on:
                lda     #0
                sta     key_pressed

                ; initialize marquee flashing
                lda     #$f8
                sta     flash_offset
                lda     #1
                sta     flash_counter

                ; load table for phase 0
                ldx     #raster_0_tbl_size
                stx     tbl_size
                stx     TBL_OFFSET
                ldy     #0
phase0_loop:    lda     raster_0_tbl,y
                sta     tbl_base,x
                iny
                dex
                bne     phase0_loop

                ; install raster-irq-routine
                lda     BG_COLOR_0
                sta     bg_save
                sei
                lda     #%01111111
                sta     $dc0d
                lda     $dc0d
                lda     #%00000001
                sta     VIC_IRM
                sta     VIC_IRR
                lda     raster_0_tbl
                sta     VIC_RASTER
                lda     VIC_CTL1
                and     #%01111111
                sta     VIC_CTL1
                lda     #$35
                sta     $01

                lda     #<raster_top
                sta     $fffe
                lda     #>raster_top
                sta     $ffff
                dec     TBL_OFFSET
                cli
                rts

; switch to raster table for phase 1
raster_phase1:
                sei
                lda     raster_1_tbl
                sta     VIC_RASTER
                lda     VIC_CTL1
                and     #%01111111
                sta     VIC_CTL1

                ; load table for phase 1
                ldx     #raster_1_tbl_size
                stx     tbl_size
                stx     TBL_OFFSET
                ldy     #0
phase1_loop:    lda     raster_1_tbl,y
                sta     tbl_base,x
                iny
                dex
                bne     phase1_loop

                lda     #<raster_top
                sta     $fffe
                lda     #>raster_top
                sta     $ffff
                dec     TBL_OFFSET
                cli
                rts

; deactivate raster IRQ
raster_off:
                sei
                lda     #0
                sta     VIC_IRM
                sta     VIC_IRR
                lda     #%00111011
                sta     VIC_CTL1
                lda     #$37
                sta     $01
                lda     #%10000011
                sta     $dc0d
                cli
                lda     bg_save
                sta     BG_COLOR_0
                rts

.rodata

; raster tables
; entry format:
;       .byte   [rasterline]
;       .byte   [ctl-eor]               // use $80 to flip bit 9 of rasterline
;       .word   [payload]               // payload address
;       [.byte  [arg1], [arg2], ...]    // arguments for payload

; phase 0

raster_0_tbl:
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

                .byte 250, $00
                .word raster_24row

                .byte 27, $80
                .word raster_zone0

raster_0_tbl_size = *-raster_0_tbl

; phase 1

raster_1_tbl:
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

                .byte 100, $00
                .word raster_marquee

                .byte 120, $00
                .word raster_sound

                .byte 243, $00
                .word raster_resizer

                .byte 250, $00
                .word raster_24row

                .byte 252, $00
                .word raster_col
                .byte 10

                .byte 254, $00
                .word raster_col
                .byte 14

                .byte 23, $80
                .word raster_col
                .byte 10

                .byte 25, $00
                .word raster_col
                .byte 6

                .byte 27, $00
                .word raster_zone0

raster_1_tbl_size = *-raster_1_tbl

; vim: et:si:ts=8:sts=8:sw=8
