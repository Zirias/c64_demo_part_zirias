;
; sound player
;

.import snd_tbl

.export snd_speed
.export snd_songptr
.export snd_play
.export snd_init
.export snd_stop
.export snd_instr1
.export snd_instr2
.export snd_instr3

.code

getbyte:
		ldx	snd_playpos
gb_ptr:		lda	$FFFF,x
		inx
		stx	snd_playpos
		bne	gb_out
		inc	gb_ptr+2
gb_out:		rts

snd_play:
		lda	$DD06
		cmp	snd_speed
		beq	play
		rts
play:		lda	#%01001001
		sta	$DD0F
real_play:	jsr	getbyte
		tax
		bpl	play_disp
		lda	snd_songptr+1
		sta	gb_ptr+2
		lda	#0
		sta	snd_playpos
		jsr	getbyte
		tax
play_disp:	bne	goon
		rts
goon:		dex
		bne	goon1
		jmp	on_ch1
goon1:		dex
		bne	goon2
		jmp	on_ch2
goon2:		dex
		bne	goon3
		jmp	on_ch3
goon3:		dex
		bne	goon4
		jmp	off_ch1
goon4:		dex
		bne	goon5
		jmp	off_ch2
goon5:		dex
		bne	goon6
		jmp	off_ch3
goon6:		dex
		bne	goon7
		jmp	instr_ch1
goon7:		dex
		bne	goon8
		jmp	instr_ch2
goon8:		dex
		bne	goon9
		jmp	instr_ch3
goon9:		dex
		bne	goon10
		jmp	adsr_ch1
goon10:		dex
		bne	goon11
		jmp	adsr_ch2
goon11:		dex
		bne	goon12
		jmp	adsr_ch3
goon12:		rts
		
off_ch1:	lda	snd_instr1
		sta	$D404
		jmp	real_play
off_ch2:	lda	snd_instr2
		sta	$D40B
		jmp	real_play
off_ch3:	lda	snd_instr3
		sta	$D412
		jmp	real_play
on_ch1:		jsr	getbyte
		tax
		ldy	snd_tbl,x
		inx
		lda	snd_tbl,x
		tax
		lda	snd_instr1
		ora	#1
		sty	$D400
		stx	$D401
		sta	$D404
		jmp	real_play
on_ch2:		jsr	getbyte
		tax
		ldy	snd_tbl,x
		inx
		lda	snd_tbl,x
		tax
		lda	snd_instr2
		ora	#1
		sty	$D407
		stx	$D408
		sta	$D40B
		jmp	real_play
on_ch3:		jsr	getbyte
		tax
		ldy	snd_tbl,x
		inx
		lda	snd_tbl,x
		tax
		lda	snd_instr3
		ora	#1
		sty	$D40E
		stx	$D40F
		sta	$D412
		jmp	real_play
instr_ch1:	jsr	getbyte
		sta	snd_instr1
		jmp	real_play
instr_ch2:	jsr	getbyte
		sta	snd_instr2
		jmp	real_play
instr_ch3:	jsr	getbyte
		sta	snd_instr3
		jmp	real_play
adsr_ch1:	jsr	getbyte
		sta	$D405
		jsr	getbyte
		sta	$D406
		jmp	real_play
adsr_ch2:	jsr	getbyte
		sta	$D40C
		jsr	getbyte
		sta	$D40D
		jmp	real_play
adsr_ch3:	jsr	getbyte
		sta	$D413
		jsr	getbyte
		sta	$D414
		jmp	real_play

snd_init:
		lda	#$D0
		ldx	#$07
		sta	$DD04
		stx	$DD05
		lda	#%00000001
		sta	$DD0E
		lda	snd_speed
		sta	$DD06
		lda	#0
		sta	$DD07
		lda	#%01001001
		sta	$DD0F
		lda	snd_songptr
		ldx	snd_songptr+1
		sta	gb_ptr+1
		stx	gb_ptr+2
		ldx	#0
		stx	snd_playpos
		rts

snd_stop:
		lda	#0
		sta	$D404
		sta	$D40B
		sta	$D412
		rts

.bss
snd_speed:	.res	1
snd_songptr:	.res	2
snd_playpos:	.res	1
snd_instr1:	.res	1
snd_instr2:	.res	1
snd_instr3:	.res	1

