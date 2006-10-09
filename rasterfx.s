;
; some raster-IRQ eye-candy
;

.include "vic.inc"
.include "gfx.inc"

.export raster_on
.export raster_off


.data

pointer:	.byte	0

.bss

next_color:	.res	1


.code

raster_on:
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
next_ok:	beq	over_256
		lda	VIC_CTL1
		ora	#%10000000
		sta	VIC_CTL1
		bne	goon
over_256:	lda	VIC_CTL1
		and	#%01111111
		sta	VIC_CTL1
goon:		inx
		lda	raster_table,x
		sta	VIC_RASTER
		inx
		lda	raster_table,x
		sta	next_color
		inx
		stx	pointer
		rts

raster_main:
		lda	VIC_IRR
		sta	VIC_IRR
		bmi	by_vic
		lda	$dc0d
		cli
		jmp	$ea31
by_vic:		lda	next_color
		nop
		nop
		sta	BORDER_COLOR
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
		rts

.rodata

raster_table:
		.byte	0,22,14
		.byte	0,26,13
		.byte	0,30,1
		.byte	0,34,13
		.byte	0,38,14
		.byte	0,42,6
		.byte	1,0,14
		.byte	1,4,13
		.byte	1,8,1
		.byte	1,12,13
		.byte	1,16,14
		.byte	1,20,6
		.byte	0,24,14
		.byte	0,28,13
		.byte	0,32,1
		.byte	0,36,13
		.byte	0,40,14
		.byte	0,44,6
		.byte	1,2,14
		.byte	1,6,13
		.byte	1,10,1
		.byte	1,14,13
		.byte	1,18,14
		.byte	1,22,6
		.byte	255

