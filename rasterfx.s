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

SAVE_A		= $22
SAVE_X		= $23
SAVE_Y		= $24
TBL_OFFSET	= $25

.bss

bg_save:	.res	1
flash_offset:	.res	1
flash_counter:	.res	1
key_pressed:	.res	1

.segment "ALGNCODE"
.align $100

raster_main:
		sta	SAVE_A
		stx	SAVE_X
		sty	SAVE_Y
		lda	#<raster_stable
		sta	$fffe
		inc	VIC_RASTER
		sta	VIC_IRR
		ldy	TBL_OFFSET		; 3
		dey				; 2
		bpl	offset_ok		; 2
rstart		= *+1
		ldy	#raster_start_0		; 2
rswitch		= *+1
offset_ok:	lda	raster_switch_0,y
		eor	VIC_CTL1
		sta	VIC_CTL1
		tsx
		cli
		nop
		nop
		nop
		nop
		nop
		nop
raster_stable:	txs
		sty	TBL_OFFSET
raction		= *+1
		lda	raster_action_0,y
		sta	branch_act+1
rdata		= *+1
		lda	raster_data_0,y	; 4
rlines		= *+1
		ldx	raster_lines_0,y
		stx	VIC_RASTER
		ldy	SAVE_Y
		inc	VIC_IRR
		ldx	#<raster_main	; #0, aligned
		stx	$fffe
		nop
branch_act:	beq	actions		; bra
actions:
setcolor:	sta	BG_COLOR_0
		sta	BORDER_COLOR
raster_done:	ldx	SAVE_X
		lda	SAVE_A
		rti
setbg:		sta	BG_COLOR_0
		ldx	SAVE_X
		lda	SAVE_A
		rti
linebg:		ldx	BG_COLOR_0
		sta	BG_COLOR_0
		txa
		ldx	#$a
		dex
		bne	*-1
		ldx	SAVE_X
		sta	BG_COLOR_0
		lda	SAVE_A
		rti
setborder:	sta	BORDER_COLOR
		ldx	SAVE_X
		lda	SAVE_A
		rti
setparm:	sta	VIC_CTL1
		ldx	SAVE_X
		lda	SAVE_A
		rti
zone0:		jsr	sprite_zone0
		ldy	SAVE_Y
		ldx	SAVE_X
		lda	SAVE_A
		rti
zone1:		jsr	sprite_zone1
		ldy	SAVE_Y
		ldx	SAVE_X
		lda	SAVE_A
		rti
sound_step:	jsr	snd_play
		ldy	SAVE_Y
		ldx	SAVE_X
		lda	SAVE_A
		rti
keycheck:	lda	#>keycheck_task
		pha
		lda	#<keycheck_task
		pha
		lda	#0
		pha
		rti
resizer:	lda	#>resizer_task
		pha
		lda	#<resizer_task
		pha
		lda	#0
		pha
		rti
movesprites:	lda	#>sprites_task
		pha
		lda	#<sprites_task
		pha
		lda	#0
		pha
		rti

raster_on:
		ldx	#0
		stx	TBL_OFFSET
		stx	key_pressed

		; initialize marquee flashing
		lda	#$f8
		sta	flash_offset
		lda	#1
		sta	flash_counter

		; install raster-irq-routine
		lda	BG_COLOR_0
		sta	bg_save
		lda	raster_done-actions
		sta	branch_act+1
		sei
		lda	#%01111111
		sta	$dc0d
		lda	$dc0d
		lda	#%00000001
		sta	VIC_IRM
		sta	VIC_IRR
		lda	#30
		sta	VIC_RASTER
		lda	VIC_CTL1
		and	#%01111111
		sta	VIC_CTL1
		lda	#$35
		sta	$01
		lda	#<raster_main
		ldx	#>raster_main
		sta	$fffe
		stx	$ffff

		; set pointers to phase 0
		lda	#raster_start_0
		sta	rstart
		lda	#<raster_switch_0
		sta	rswitch
		lda	#>raster_switch_0
		sta	rswitch+1
		lda	#<raster_action_0
		sta	raction
		lda	#>raster_action_0
		sta	raction+1
		lda	#<raster_data_0
		sta	rdata
		lda	#>raster_data_0
		sta	rdata+1
		lda	#<raster_lines_0
		sta	rlines
		lda	#>raster_lines_0
		sta	rlines+1
		cli
		rts

raster_phase1:
		sei
		ldx	#0
		stx	TBL_OFFSET
		lda	#30
		sta	VIC_RASTER
		lda	VIC_CTL1
		and	#%01111111
		sta	VIC_CTL1
		lda	#raster_start_1
		sta	rstart
		lda	#<raster_switch_1
		sta	rswitch
		lda	#>raster_switch_1
		sta	rswitch+1
		lda	#<raster_action_1
		sta	raction
		lda	#>raster_action_1
		sta	raction+1
		lda	#<raster_data_1
		sta	rdata
		lda	#>raster_data_1
		sta	rdata+1
		lda	#<raster_lines_1
		sta	rlines
		lda	#>raster_lines_1
		sta	rlines+1
		cli
		rts
raster_off:
		sei
		lda	#0
		sta	VIC_IRM
		sta	VIC_IRR
		lda	#%00111011
		sta	VIC_CTL1
		lda	#$37
		sta	$01
		lda	#%10000011
		sta	$dc0d
		cli
		lda	bg_save
		sta	BG_COLOR_0
		rts

keycheck_task:
		lda	key_pressed
		bne	key_done
		lda	#0
		sta	$dc03
		lda	#$ff
		sta	$dc02
		lda	#0
		sta	$dc00
		lda	#$ff
		cmp	$dc01
		beq	key_done
		sta	key_pressed
key_done:	ldx	SAVE_X
		lda	SAVE_A
		rti

resizer_task:
		lda	#$ff
		sta	$7f38
		sta	$7f3f
		lda	#$ed
		sta	$7f3c
		sta	$7f3d
		lda	#$8f
		sta	$7f39
		lda	#$af
		sta	$7f3a
		lda	#$81
		sta	$7f3b
		lda	#$e1
		sta	$7f3e
		ldx	SAVE_X
		lda	SAVE_A
		rti

sprites_task:	; do flashing first
		ldx	flash_counter
		dex
		stx	flash_counter
		bpl	spmove
		ldx	#1
		stx	flash_counter
		ldx	flash_offset
		lda	#12
		sta	sprite_1_0_col-$f8,x
		inx
		bne	spfok
		ldx	#$f8
spfok:		lda	#1
		sta	sprite_1_0_col-$f8,x
		stx	flash_offset
		; now move sprites
spmove:		lda	sprite_1_x_h
		ldx	#14
spm_while:	asl
		tay
		bcc	spm_l
		lda	sprite_1_0_x,x
		bne	spm_hd
		lda	#$ff
		sta	sprite_1_0_x,x
		bmi	spm_next
spm_hd:		dec	sprite_1_0_x,x
		iny
		bne	spm_next
spm_l:		lda	sprite_1_0_x,x
		bne	spm_ld
		lda	#$90
		sta	sprite_1_0_x,x
		iny
		bne	spm_next
spm_ld:		dec	sprite_1_0_x,x
spm_next:	tya
		dex
		dex
		bpl	spm_while
		sta	sprite_1_x_h
		ldy	SAVE_Y
		ldx	SAVE_X
		lda	SAVE_A
		rti

.rodata

raster_data_0:
		.byte %00010011
		.byte 0
		.byte 0
		.byte %00111011
		.byte 6
		.byte 1
		.byte 6
		.byte 1
		.byte 6
		.byte 6
		.byte 1
raster_start_0 = *-raster_data_0-1

raster_lines_0:
		.byte 26
		.byte 249
		.byte 246
		.byte 80
		.byte 49
		.byte 47
		.byte 45
		.byte 43
		.byte 41
		.byte 39
		.byte 36

raster_switch_0:
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00

raster_action_0:
		.byte setparm-actions
		.byte resizer-actions
		.byte keycheck-actions
		.byte setparm-actions
		.byte setbg-actions
		.byte setbg-actions
		.byte setbg-actions
		.byte setbg-actions
		.byte setbg-actions
		.byte linebg-actions
		.byte setbg-actions

raster_data_1:
		.byte $ff
		.byte 6
		.byte 10
		.byte 14
		.byte 10
		.byte %00010011
		.byte 0
		.byte 0
		.byte 0
		.byte $ff
		.byte %00111011
		.byte 6
		.byte 1
		.byte 6
		.byte 1
		.byte 6
		.byte 6
		.byte 1
		.byte 0
raster_start_1 = *-raster_data_1-1

raster_lines_1:
		.byte 31
		.byte 26
		.byte 23
		.byte 21
		.byte 253
		.byte 251
		.byte 249
		.byte 246
		.byte 100
		.byte 80
		.byte 70
		.byte 49
		.byte 47
		.byte 45
		.byte 43
		.byte 41
		.byte 39
		.byte 36
		.byte 26

raster_switch_1:
		.byte $00
		.byte $00
		.byte $00
		.byte $80
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $00
		.byte $80

raster_action_1:
		.byte zone0-actions
		.byte setcolor-actions
		.byte setcolor-actions
		.byte setcolor-actions
		.byte setcolor-actions
		.byte setparm-actions
		.byte resizer-actions
		.byte movesprites-actions
		.byte keycheck-actions
		.byte zone1-actions
		.byte setparm-actions
		.byte setbg-actions
		.byte setbg-actions
		.byte setbg-actions
		.byte setbg-actions
		.byte setbg-actions
		.byte linebg-actions
		.byte setbg-actions
		.byte sound_step-actions

