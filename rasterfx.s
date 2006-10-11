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

interrupt_tmp:	.res	1

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

raster_main:
		lda	VIC_IRR
		sta	VIC_IRR
irq_branch:	bmi	setcolor
		lda	$dc0d
		cli
		jmp	$ea31

setparm:	lda	interrupt_tmp
		sta	VIC_CTL1
		bne	out

setcolor:	lda	interrupt_tmp
		sta	BG_COLOR_0
		sta	BORDER_COLOR
out:		jsr	raster_next
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
		.byte	0,45,%10011011
		.byte	0,50,%10111011
		.byte	0,250,%10010011
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
		.byte	0,45,%10011011
		.byte	0,50,%10111011
		.byte	0,250,%10010011
		.byte	1,2,14
		.byte	1,6,13
		.byte	1,10,1
		.byte	1,14,13
		.byte	1,18,14
		.byte	1,22,6
		.byte	255

