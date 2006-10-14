;
; some raster-IRQ eye-candy
;

.include "vic.inc"
.include "gfx.inc"
.include "snd.inc"

.export raster_on
.export raster_off


.bss

interrupt_tmp:	.res	1
pointer:	.res	1
bg_save:	.res	1
flash_offset:	.res	1
flash_counter:	.res	1

.code

raster_on:
		; copy sprite data:
		ldx	#0
		stx	pointer		; needed later
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
		sei
		lda	#<raster_main
		ldx	#>raster_main
		sta	$0314
		stx	$0315
		lda	#%10000001
		sta	VIC_IRM
		jsr	raster_next
		cli
		rts

raster_next:
		ldx	pointer
		lda	raster_table,x
		bpl	next_ok
		ldx	#0
		lda	raster_table,x
next_ok:	lsr
		tay
		bcs	over_256
		lda	VIC_CTL1
		and	#%01111111
		sta	VIC_CTL1
		bne	goon
over_256:	lda	VIC_CTL1
		ora	#%10000000
		sta	VIC_CTL1
goon:		inx
		lda	raster_table,x
		sta	VIC_RASTER
		inx
		tya
		bne	other_cmd
		inx
		stx	pointer
		lda	raster_table-1,x
		bmi	next_setparm
		sta	interrupt_tmp
		lda	#(setcolor - irq_branch - 2)
		sta	irq_branch + 1
		rts
next_setparm:	and	#%01111111
		sta	interrupt_tmp
		lda	#(setparm - irq_branch - 2)
		sta	irq_branch + 1
		rts
other_cmd:	stx	pointer
		lsr
		beq	spcmd_bot
		lsr
		beq	spcmd_top
		lsr
		beq	spcmd_move
		lda	#(sound_step - irq_branch - 2)
		sta	irq_branch + 1
		rts
spcmd_move:	lda	#(sprites_move - irq_branch - 2)
		sta	irq_branch + 1
		rts
spcmd_bot:	lda	#(sprites_bottom - irq_branch - 2)
		sta	irq_branch + 1
		rts
spcmd_top:	lda	#(sprites_top - irq_branch - 2)
		sta	irq_branch + 1
		rts

raster_main:
		lda	VIC_IRR
		sta	VIC_IRR
irq_branch:	bmi	setcolor
		lda	$dc0d
		cli
		jmp	$ea31

setparm:	lda	interrupt_tmp
		sta	VIC_CTL1
		jsr	raster_next
		jmp	$ea7e

setcolor:	lda	interrupt_tmp
		sta	BG_COLOR_0
		sta	BORDER_COLOR
		jsr	raster_next
		jmp	$ea7e

sound_step:	jsr	snd_play
		jsr	raster_next
		jmp	$ea7e

sprites_top:	lda	#$ff
		sta	SPRITE_SHOW
		jsr	raster_next
		jmp	$ea7e

sprites_bottom: lda	#0
		sta	SPRITE_SHOW
		jsr	raster_next
		jmp	$ea7e

sprites_move:	; do flashing first
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
		jsr	raster_next
		jmp	$ea7e

raster_off:
		sei
		lda	#$31
		ldx	#$ea
		sta	$0314
		stx	$0315
		lda	#0
		sta	VIC_IRM
		cli
		sta	SPRITE_SHOW
		lda	bg_save
		sta	BG_COLOR_0
		lda	VIC_CTL1
		ora	#%00001000
		sta	VIC_CTL1
		rts

.rodata

raster_table:
		.byte	0,22,14
		.byte	0,26,13
		.byte	0,30,1
		.byte	0,34,13
		.byte	0,38,14
		.byte	0,42,6
		.byte	0,50,%10111011
		.byte	4,60
		.byte	8,80
		.byte	16,100
		.byte	0,250,%10010011
		.byte	0,253,14
		.byte	1,27,6
		.byte	3,30
		.byte	0,24,14
		.byte	0,28,13
		.byte	0,32,1
		.byte	0,36,13
		.byte	0,40,14
		.byte	0,44,6
		.byte	0,50,%10111011
		.byte	4,60
		.byte	8,80
		.byte	16,100
		.byte	0,250,%10010011
		.byte	0,254,14
		.byte	1,28,6
		.byte	3,30
		.byte	255

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

