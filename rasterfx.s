;
; some raster-IRQ eye-candy
;

.include "vic.inc"
.include "gfx.inc"
.include "snd.inc"

.export raster_on
.export raster_off


.bss

action:		.res	2

tbl_offset:	.res	1
bg_save:	.res	1
flash_offset:	.res	1
flash_counter:	.res	1


.code

raster_on:
		; copy sprite data:
		ldx	#0
		stx	tbl_offset
sp_copy1:	lda	header,x
		sta	$5000,x
		inx
		bne	sp_copy1
sp_copy2:	lda	header+$0100,x
		sta	$5100,x
		inx
		bne	sp_copy2

		; set sprite-data vectors
		ldy	#$47
		tya
		ldx	#7
sp_pointer:	sta	$5ff8,x
		dey
		tya
		dex
		bpl	sp_pointer

		; configure sprites in VIC
		lda	#$70
		sta	SPRITE_0_X
		lda	#$88
		sta	SPRITE_1_X
		lda	#$a0
		sta	SPRITE_2_X
		lda	#$b8
		sta	SPRITE_3_X
		lda	#$d0
		sta	SPRITE_4_X
		lda	#$e8
		sta	SPRITE_5_X
		lda	#$00
		sta	SPRITE_6_X
		lda	#$18
		sta	SPRITE_7_X
		lda	#$c0
		sta	SPRITE_X_HB
		lda	#0
		sta	SPRITE_MCOL_1
		sta	SPRITE_DBL_X
		sta	SPRITE_DBL_Y
		lda	#7
		sta	SPRITE_MCOL_2
		lda	#12
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		sta	SPRITE_7_COL
		lda	#4
		sta	SPRITE_0_Y
		sta	SPRITE_1_Y
		sta	SPRITE_2_Y
		sta	SPRITE_3_Y
		sta	SPRITE_4_Y
		sta	SPRITE_5_Y
		sta	SPRITE_6_Y
		sta	SPRITE_7_Y
		lda	#$ff
		sta	SPRITE_MULTI
		lda	#$f8
		sta	flash_offset
		lda	#1
		sta	flash_counter

		; install raster-irq-routine
		lda	BG_COLOR_0
		sta	bg_save
		lda	#<raster_done
		ldx	#>raster_done
		sta	action
		stx	action+1
		sei
		lda	#%01111111
		sta	$dc0d
		sta	$dd0d
		lda	$dc0d
		lda	$dd0d
		lda	#%00000001
		sta	VIC_IRM
		sta	VIC_IRR
		lda	#30
		sta	VIC_RASTER
		lda	VIC_CTL1
		ora	#%10000000
;		and	#%01111111
		sta	VIC_CTL1
		lda	#$35
		sta	$01
		lda	#<raster_main
		ldx	#>raster_main
		sta	$fffe
		stx	$ffff
		cli
		rts

raster_main:
		pha
		txa
		pha
		tya
		pha
		lda	#<raster_stable
		ldx	#>raster_stable
		sta	$fffe
		stx	$ffff
		inc	VIC_RASTER
		lda	#$ff
		sta	VIC_IRR
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
raster_stable:	txs
		ldx	tbl_offset		; 4
		lda	raster_data,x		; 4
		dex				; 2
		bpl	offset_ok
		ldx	#raster_start
		bne	store_offset
offset_ok:	nop
		nop
store_offset:	stx	tbl_offset		; 4
		ldy	#<raster_main
		sty	$fffe
		ldy	#>raster_main
		sty	$ffff
		nop
		nop
		nop
		nop
		nop
		;jmp	(action)
		sta	BG_COLOR_0
		sta	BORDER_COLOR
raster_done:
raster_next:	lda	raster_action,x
		sta	action+1
		ldy	raster_data,x
		cpy	VIC_RASTER
		bcs	hi_noswitch
		lda	VIC_CTL1
		eor	#%10000000
		sta	VIC_CTL1
hi_noswitch:	sty	VIC_RASTER
		dex
		lda	raster_action,x
		sta	action
		stx	tbl_offset
		lda	#$ff
		sta	VIC_IRR
		pla
		tay
		pla
		tax
		pla
		rti

setparm:	sta	VIC_CTL1
		jmp	raster_done

setcolor:	sta	BG_COLOR_0
		sta	BORDER_COLOR
		jmp	raster_done

sound_step:	lda	#<raster_main
		ldx	#>raster_main
		sta	$fffe
		stx	$ffff
		jsr	raster_next
		lda	#$ff
		sta	VIC_IRR
		lda	#>sound_task
		pha
		lda	#<sound_task
		pha
		lda	#0
		pha
		rti
sound_task:	jsr	snd_play
		pla
		tay
		pla
		tax
		pla
		rti

showsprites:	sta	SPRITE_SHOW
		jmp	raster_done

movesprites:	lda	#<raster_main
		ldx	#>raster_main
		sta	$fffe
		stx	$ffff
		jsr	raster_next
		lda	#$ff
		sta	VIC_IRR
		lda	#>sprites_task
		pha
		lda	#<sprites_task
		pha
		lda	#0
		pha
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
		sta	SPRITE_0_COL-$f8,x
		inx
		bne	spfok
		ldx	#$f8
spfok:		lda	#1
		sta	SPRITE_0_COL-$f8,x
		stx	flash_offset
		; now move sprites
spmove:		lda	SPRITE_X_HB
		ldx	#14
spm_while:	asl
		tay
		bcc	spm_l
		lda	SPRITE_0_X,x
		bne	spm_hd
		lda	#$ff
		sta	SPRITE_0_X,x
		bmi	spm_next
spm_hd:		dec	SPRITE_0_X,x
		iny
		bne	spm_next
spm_l:		lda	SPRITE_0_X,x
		bne	spm_ld
		lda	#$90
		sta	SPRITE_0_X,x
		iny
		bne	spm_next
spm_ld:		dec	SPRITE_0_X,x
spm_next:	tya
		dex
		dex
		bpl	spm_while
		sta	SPRITE_X_HB
		pla
		tay
		pla
		tax
		pla
		rti

raster_off:	rts	; dummy for now

.rodata

.ifdef DEBUG_IRQTIMING
raster_data:
;		      argument		rasterline
		.byte 13,		30
		.byte 12,		27
		.byte 11,		253
		.byte 10,		250
		.byte 9,		100
		.byte 8,		80
		.byte 7,		50
		.byte 6,		42
		.byte 5,		38
		.byte 4,		34
		.byte 3,		30
		.byte 2,		26
		.byte 1,		22
		.byte 0,		1
raster_start = *-raster_data-1

raster_action:
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
.else
raster_data:
;		      argument		rasterline
		.byte 0,		30
		.byte 6,		28
		.byte 14,		254
		.byte %00010011,	250
		.byte 0,		100
		.byte $ff,		80
		.byte %00111011,	50
		.byte 6,		44
		.byte 14,		40
		.byte 13,		36
		.byte 1,		32
		.byte 13,		28
		.byte 14,		24
		.byte 0,		1
		.byte 0,		30
		.byte 6,		27
		.byte 14,		253
		.byte %00010011,	250
		.byte 0,		100
		.byte $ff,		80
		.byte %00111011,	50
		.byte 6,		42
		.byte 14,		38
		.byte 13,		34
		.byte 1,		30
		.byte 13,		26
		.byte 14,		22
		.byte 0,		1
raster_start = *-raster_data-1

raster_action:
		.word sound_step
		.word setcolor
		.word setcolor
		.word setparm
		.word movesprites
		.word showsprites
		.word setparm
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word showsprites
		.word sound_step
		.word setcolor
		.word setcolor
		.word setparm
		.word movesprites
		.word showsprites
		.word setparm
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word setcolor
		.word showsprites
.endif

; Sprites:

header:		.byte	%00001010,%00000010,%10101000
		.byte	%00101101,%00001010,%01010110
		.byte	%00101101,%00001001,%01010111
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00001001,%00001001,%00001001
		.byte	%00100101,%01001011,%01010101
		.byte	%00100101,%01000011,%01010100
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	0
		.byte	%00000000,%10000010,%10100000
		.byte	%00000010,%11001011,%01011000
		.byte	%00000010,%11001011,%01010100
		.byte	%00000010,%01000000,%00000100
		.byte	%00000010,%01000000,%00000100
		.byte	%00000010,%01000000,%00000100
		.byte	%00001001,%00001010,%10100100
		.byte	%00001001,%00100101,%01010100
		.byte	%00001001,%00100101,%01010000
		.byte	%00001001,%00100100,%00000000
		.byte	%00001001,%00100100,%00000000
		.byte	%00100100,%00100100,%00000000
		.byte	%00100100,%00100100,%00000000
		.byte	%00100100,%00100110,%10100000
		.byte	%00100100,%00100101,%01011100
		.byte	%00100100,%00000101,%01011100
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	0
		.byte	%00101010,%10000000,%10101010
		.byte	%10100101,%01100010,%10010101
		.byte	%10010101,%01110010,%01010101
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10010000,%10010010,%01000010
		.byte	%10110101,%01010010,%11010101
		.byte	%00110101,%01000000,%11010101
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	0
		.byte	%00000010,%10100000,%00000000
		.byte	%10001001,%01011000,%00000010
		.byte	%11001001,%01011100,%00000010
		.byte	%01001001,%00000000,%00000010
		.byte	%01001001,%00000000,%00000010
		.byte	%01001001,%00000000,%00000010
		.byte	%01001001,%10101000,%00000010
		.byte	%01001001,%01010110,%00000010
		.byte	%01001001,%01010101,%00000010
		.byte	%01001001,%00001001,%00000010
		.byte	%01001001,%00001001,%00000010
		.byte	%01001001,%00001001,%00000010
		.byte	%01001001,%00001001,%00000010
		.byte	%01001001,%10101001,%00000010
		.byte	%01001011,%01010101,%00000010
		.byte	%00000011,%01010100,%00000010
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	0
		.byte	%10000000,%00000000,%00000000
		.byte	%11000000,%00000000,%00000000
		.byte	%11000000,%00000000,%00000000
		.byte	%01101010,%00000010,%00000010
		.byte	%01010101,%10001011,%00001011
		.byte	%01010101,%01001001,%00001001
		.byte	%01000000,%01001001,%00001001
		.byte	%01000000,%01001001,%00001001
		.byte	%01000000,%01000010,%01000100
		.byte	%01000000,%01000010,%01100100
		.byte	%01000000,%01000010,%01100100
		.byte	%01000000,%01000010,%01100100
		.byte	%01000000,%01000010,%01100100
		.byte	%01101010,%01000000,%10010000
		.byte	%01010101,%01000000,%10010000
		.byte	%01010101,%00000000,%10010000
		.byte	%00000000,%00000000,%10010000
		.byte	%00000000,%00000000,%10010000
		.byte	%00000000,%00000000,%10010000
		.byte	%00000000,%00000010,%11000000
		.byte	%00000000,%00000010,%11000000
		.byte	0
		.byte	%00000000,%10101010,%00001011
		.byte	%00000010,%11111111,%11001001
		.byte	%00000010,%11111111,%11000000
		.byte	%00000000,%00000010,%11000010
		.byte	%00000000,%00001011,%00001011
		.byte	%00000000,%00001011,%00001011
		.byte	%00000000,%00001011,%00001001
		.byte	%00000000,%00101100,%00001001
		.byte	%00000000,%00101100,%00001001
		.byte	%00000000,%00101100,%00001001
		.byte	%00000000,%10110000,%00001001
		.byte	%00000000,%10110000,%00001001
		.byte	%00000000,%10110000,%00001001
		.byte	%00000010,%11101010,%00001001
		.byte	%00000010,%11111111,%11001001
		.byte	%00000010,%11111111,%11001001
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	0
		.byte	%00000000,%00000010,%11000000
		.byte	%00000000,%00000010,%01000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00001010,%10000000,%10000010
		.byte	%00100101,%01010010,%11001011
		.byte	%00100101,%01010010,%11001011
		.byte	%00100100,%10010010,%01000000
		.byte	%00100100,%10110010,%01000000
		.byte	%00100100,%00110010,%01000010
		.byte	%00100100,%00000010,%01001001
		.byte	%00100100,%00000010,%01001001
		.byte	%00100100,%00000010,%01001001
		.byte	%00100100,%00000010,%01001001
		.byte	%00100100,%00000010,%01001001
		.byte	%00100100,%00000010,%01001001
		.byte	%00100100,%00000010,%01000001
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	0
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%10101000,%00001010,%10000000
		.byte	%01010110,%00101001,%01100000
		.byte	%01010101,%00100101,%01110000
		.byte	%00001001,%00100100,%00000000
		.byte	%00001001,%00100100,%00000000
		.byte	%10101001,%00100100,%00000000
		.byte	%01010101,%00100101,%01100000
		.byte	%01010101,%00000101,%01010000
		.byte	%00001001,%00000000,%10010000
		.byte	%00001001,%00000000,%10010000
		.byte	%10101001,%00001010,%10010000
		.byte	%01010111,%00101101,%01010000
		.byte	%01010111,%00101101,%01000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	%00000000,%00000000,%00000000
		.byte	0

