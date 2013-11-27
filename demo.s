;
; Demo nach AmigaBASIC-Demo
;

GETKB		= $F142

tbllen		= 195

.include	"gfx.inc"
.include	"vic.inc"
.include	"snd.inc"

.import ziri_ambi

.import	raster_on
.import raster_off
.import key_pressed

.code
		; Initialisierung:
		ldx	#0
		stx	from1tbl
		stx	from2tbl
		stx	to1tbl
		stx	to2tbl
		lda	#tbllen
		sta	from1
		sta	from2
		lda	#tbllen - 123
		sta	to1
		sta	to2
		lda	#66
		sta	countdown
		lda	#<(cotable_a-1)
		ldx	#>(cotable_a-1)
		sta	from1ptr1+1
		stx	from1ptr1+2
		sta	from1ptr2+1
		stx	from1ptr2+2
		sta	from1ptr3+1
		stx	from1ptr3+2
		sta	from2ptr1+1
		stx	from2ptr1+2
		sta	from2ptr2+1
		stx	from2ptr2+2
		sta	from2ptr3+1
		stx	from2ptr3+2
		sta	to1ptr1+1
		stx	to1ptr1+2
		sta	to1ptr2+1
		stx	to1ptr2+2
		sta	to1ptr3+1
		stx	to1ptr3+2
		sta	to2ptr1+1
		stx	to2ptr1+2
		sta	to2ptr2+1
		stx	to2ptr2+2
		sta	to2ptr3+1
		stx	to2ptr3+2

		; Sound:
		lda	#%00001111
		sta	$D418
		lda	#<song
		sta	snd_songptr
		lda	#>song
		sta	snd_songptr+1
		lda	#12
		sta	snd_speed
		jsr	snd_init

		; Rahmenfarbe, Grafikmodus, Bildschirm löschen:
		lda	BORDER_COLOR
		sta	border
		lda	#6
		sta	BORDER_COLOR
		jsr	gfx_init
		lda	#1
		ldx	#6
		jsr	gfx_setcolor
		jsr	gfx_clear
		; Ambigramm:
		jsr	ziri_ambi
		; Raster-Effekt:
		jsr	raster_on
		; Zeichenmodus auf invertieren:
		lda	#MODE_INV
		sta	PLOT_MODE

		; Hauptschleife:
loop:		ldx	countdown
		beq	do2			; 2. Linie schon aktiv
		dex
		stx	countdown		; sonst weiterzählen
		jmp	do1

		; Linie 2:
do2:		ldy	from2
from2ptr1:	lda	$FFFF,y
		sta	PLOT_XL
		dey
from2ptr2:	lda	$FFFF,y
		sta	PLOT_XH
		dey
from2ptr3:	lda	$FFFF,y
		sta	PLOT_Y
		dey
		bne	cont2a
		lda	from2tbl
		eor	#1
		sta	from2tbl
		bne	from2_b
		lda	#<(cotable_a-1)
		ldx	#>(cotable_a-1)
		bne	fr2_cont
from2_b:	lda	#<(cotable_b-1)
		ldx	#>(cotable_b-1)
fr2_cont:	sta	from2ptr1+1
		stx	from2ptr1+2
		sta	from2ptr2+1
		stx	from2ptr2+2
		sta	from2ptr3+1
		stx	from2ptr3+2
		ldy	#tbllen
cont2a:		sty	from2
		ldy	to2
to2ptr1:	lda	$FFFF,y
		sta	LINETO_XL
		dey
to2ptr2:	lda	$FFFF,y
		sta	LINETO_XH
		dey
to2ptr3:	lda	$FFFF,y
		sta	LINETO_Y
		dey
		bne	cont2b
		lda	to2tbl
		eor	#1
		sta	to2tbl
		bne	to2_b
		lda	#<(cotable_a-1)
		ldx	#>(cotable_a-1)
		bne	to2_cont
to2_b:		lda	#<(cotable_b-1)
		ldx	#>(cotable_b-1)
to2_cont:	sta	to2ptr1+1
		stx	to2ptr1+2
		sta	to2ptr2+1
		stx	to2ptr2+2
		sta	to2ptr3+1
		stx	to2ptr3+2
		ldy	#tbllen
cont2b:		sty	to2
		jsr	gfx_line

		; Linie 1:
do1:		ldy	from1
from1ptr1:	lda	$FFFF,y
		sta	PLOT_XL
		dey
from1ptr2:	lda	$FFFF,y
		sta	PLOT_XH
		dey
from1ptr3:	lda	$FFFF,y
		sta	PLOT_Y
		dey
		bne	cont1a
		lda	from1tbl
		eor	#1
		sta	from1tbl
		bne	from1_b
		lda	#<(cotable_a-1)
		ldx	#>(cotable_a-1)
		bne	fr1_cont
from1_b:	lda	#<(cotable_b-1)
		ldx	#>(cotable_b-1)
fr1_cont:	sta	from1ptr1+1
		stx	from1ptr1+2
		sta	from1ptr2+1
		stx	from1ptr2+2
		sta	from1ptr3+1
		stx	from1ptr3+2
		ldy	#tbllen
cont1a:		sty	from1
		ldy	to1
to1ptr1:	lda	$FFFF,y
		sta	LINETO_XL
		dey
to1ptr2:	lda	$FFFF,y
		sta	LINETO_XH
		dey
to1ptr3:	lda	$FFFF,y
		sta	LINETO_Y
		dey
		bne	cont1b
		lda	to1tbl
		eor	#1
		sta	to1tbl
		bne	to1_b
		lda	#<(cotable_a-1)
		ldx	#>(cotable_a-1)
		bne	to1_cont
to1_b:		lda	#<(cotable_b-1)
		ldx	#>(cotable_b-1)
to1_cont:	sta	to1ptr1+1
		stx	to1ptr1+2
		sta	to1ptr2+1
		stx	to1ptr2+2
		sta	to1ptr3+1
		stx	to1ptr3+2
		ldy	#tbllen
cont1b:		sty	to1
		jsr	gfx_line

		; Ende wenn Taste gedrückt:
		lda	key_pressed
		bne	out
		jmp	loop
out:		jsr	raster_off
		jsr	gfx_done
		jsr	snd_stop
		lda	border
		sta	BORDER_COLOR
eat_keys:	jsr	GETKB
		bne	eat_keys
		rts

.bss
border:		.res	1
from1tbl:	.res	1
from1:		.res	1
to1tbl:		.res	1
to1:		.res	1
from2tbl:	.res	1
from2:		.res	1
to2tbl:		.res	1
to2:		.res	1
countdown:	.res	1

.rodata
cotable_a:	.byte	$C0,$01,$3F,$B8,$01,$3F,$B0,$01,$3F,$A8,$01,$3F
		.byte	$A0,$01,$3F,$98,$01,$3F,$90,$01,$3F,$88,$01,$3F
		.byte	$80,$01,$3F,$78,$01,$3F,$70,$01,$3F,$68,$01,$3F
		.byte	$60,$01,$3F,$58,$01,$3F,$50,$01,$3F,$48,$01,$3F
		.byte	$40,$01,$3F,$38,$01,$3F,$30,$01,$3F,$28,$01,$3F
		.byte	$20,$01,$3F,$18,$01,$3F,$10,$01,$3F,$08,$01,$3F
		.byte	$00,$01,$3F,$00,$01,$38,$00,$01,$30,$00,$01,$28
		.byte	$00,$01,$20,$00,$01,$18,$00,$01,$10,$00,$01,$08
		.byte	$00,$01,$00,$00,$00,$F8,$00,$00,$F0,$00,$00,$E8
		.byte	$00,$00,$E0,$00,$00,$D8,$00,$00,$D0,$00,$00,$C8
		.byte	$00,$00,$C0,$00,$00,$B8,$00,$00,$B0,$00,$00,$A8
		.byte	$00,$00,$A0,$00,$00,$98,$00,$00,$90,$00,$00,$88
		.byte	$00,$00,$80,$00,$00,$78,$00,$00,$70,$00,$00,$68
		.byte	$00,$00,$60,$00,$00,$58,$00,$00,$50,$00,$00,$48
		.byte	$00,$00,$40,$00,$00,$38,$00,$00,$30,$00,$00,$28
		.byte	$00,$00,$20,$00,$00,$18,$00,$00,$10,$00,$00,$08
		.byte	$00,$00,$00

cotable_b:	.byte	$07,$00,$00,$0F,$00,$00,$17,$00,$00,$1F,$00,$00
		.byte	$27,$00,$00,$2F,$00,$00,$37,$00,$00,$3F,$00,$00
		.byte	$47,$00,$00,$4F,$00,$00,$57,$00,$00,$5F,$00,$00
		.byte	$67,$00,$00,$6F,$00,$00,$77,$00,$00,$7F,$00,$00
		.byte	$87,$00,$00,$8F,$00,$00,$97,$00,$00,$9F,$00,$00
		.byte	$A7,$00,$00,$AF,$00,$00,$B7,$00,$00,$BF,$00,$00
		.byte	$C7,$00,$00,$C7,$00,$07,$C7,$00,$0F,$C7,$00,$17
		.byte	$C7,$00,$1F,$C7,$00,$27,$C7,$00,$2F,$C7,$00,$37
		.byte	$C7,$00,$3F,$C7,$00,$47,$C7,$00,$4F,$C7,$00,$57
		.byte	$C7,$00,$5F,$C7,$00,$67,$C7,$00,$6F,$C7,$00,$77
		.byte	$C7,$00,$7F,$C7,$00,$87,$C7,$00,$8F,$C7,$00,$97
		.byte	$C7,$00,$9F,$C7,$00,$A7,$C7,$00,$AF,$C7,$00,$B7
		.byte	$C7,$00,$BF,$C7,$00,$C7,$C7,$00,$CF,$C7,$00,$D7
		.byte	$C7,$00,$DF,$C7,$00,$E7,$C7,$00,$EF,$C7,$00,$F7
		.byte	$C7,$00,$FF,$C7,$01,$07,$C7,$01,$0F,$C7,$01,$17
		.byte	$C7,$01,$1F,$C7,$01,$27,$C7,$01,$2F,$C7,$01,$37
		.byte	$C7,$01,$3F

song:		.byte	7,%00010000,8,%00100000,9,%00100000
		.byte	10,%00110011,%11000100,11,%00110011,%01000100
		.byte	12,%00110011,%01110100
		.byte	2,G1,0
		.byte	1,G3,0
		.byte	4,1,A3,0
		.byte	4,1,B3,6,0
		.byte	4,1,D4,0
		.byte	4,1,C4,0
		.byte	4,1,C4,5,2,E1,0
		.byte	4,1,E4,0
		.byte	4,1,D4,0
		.byte	4,1,D4,5,2,B0,0
		.byte	4,1,G4,0
		.byte	4,1,FS4,0
		.byte	4,1,G4,5,2,E1,0
		.byte	4,1,D4,0
		.byte	4,1,B3,0
		.byte	4,1,G3,0
		.byte	4,1,A3,0
		.byte	4,1,B3,5,0
		.byte	4,1,C4,2,A0,0
		.byte	4,1,D4,0
		.byte	4,1,E4,0
		.byte	4,1,D4,5,2,B0,0
		.byte	4,1,C4,0
		.byte	4,1,B3,0
		.byte	4,1,A3,5,2,C1,0
		.byte	4,1,B3,0
		.byte	4,1,G3,0
		.byte	4,1,FS3,5,2,D1,0
		.byte	4,1,G3,0
		.byte	4,1,A3,0
		.byte	4,1,D3,5,2,FS1,0
		.byte	4,1,FS3,0
		.byte	4,1,A3,0
		.byte	4,1,C4,5,2,D1,0
		.byte	4,1,B3,0
		.byte	4,1,A3,0
		.byte	4,1,B3,5,2,G1,0
		.byte	4,1,G3,0
		.byte	4,1,A3,0
		.byte	4,1,B3,5,2,E1,0
		.byte	4,1,D4,0
		.byte	4,1,C4,0
		.byte	4,1,C4,5,2,C1,0
		.byte	4,1,E4,0
		.byte	4,1,D4,0
		.byte	4,1,D4,5,2,B0,0
		.byte	4,1,G4,0
		.byte	4,1,FS4,0
		.byte	4,1,G4,5,2,E1,0
		.byte	4,1,D4,0
		.byte	4,1,B3,0
		.byte	4,1,G3,5,2,D1,0
		.byte	4,1,A3,0
		.byte	4,1,B3,0
		.byte	4,1,A3,5,2,C1,0
		.byte	4,1,D4,0
		.byte	4,1,C4,0
		.byte	4,1,B3,5,2,CS1,0
		.byte	4,1,A3,0
		.byte	4,1,G3,0
		.byte	4,1,D3,5,2,D1,0
		.byte	4,1,G3,0
		.byte	4,1,FS3,0
		.byte	4,1,G3,5,2,G1,0
		.byte	4,1,B3,0
		.byte	4,1,D4,0
		.byte	4,1,G4,0
		.byte	4,1,D4,0
		.byte	4,1,B3,0
		.byte	4,1,G3,5,11,%00110011,%01110100,0
		.byte	4,1,B3,0
		.byte	4,1,D4,0
		.byte	4,1,G4,2,G1,3,B3,0
		.byte	0
		.byte	0
		.byte	4,7,%00100000,10,%00110011,%01110100
		.byte	1,D3,5,2,FS1,0
		.byte	0
		.byte	0
		.byte	4,1,G3,5,2,E1,6,3,C4,0
		.byte	0
		.byte	0
		.byte	4,1,A3,5,2,FS1,6,3,D4,0
		.byte	0
		.byte	0
		.byte	5,2,E1,0
		.byte	0
		.byte	0
		.byte	4,1,A3,5,2,D1,6,3,D4,0
		.byte	0
		.byte	0
		.byte	4,1,G3,5,2,E1,6,3,C4,0
		.byte	0
		.byte	0
		.byte	5,2,FS1,0
		.byte	0
		.byte	0
		.byte	4,1,D3,5,2,G1,6,3,B3,0
		.byte	0
		.byte	0
		.byte	4,1,FS3,5,2,D1,6,3,A3,0
		.byte 	4,7,%00010000,10,%00110011,%11000100
		.byte	1,D3,0
		.byte	4,1,E3,0
		.byte	4,1,FS3,0
		.byte	4,1,A3,0
		.byte	4,1,G3,0
		.byte	4,1,A3,5,2,D1,6,0
		.byte	4,1,C4,0
		.byte	4,1,B3,0
		.byte	4,1,C4,5,2,D1,0
		.byte	4,1,A3,0
		.byte	4,1,FS3,0
		.byte	4,1,D3,0
		.byte	4,1,FS3,0
		.byte	4,1,A3,0
		.byte	4,1,C4,5,0
		.byte	4,1,B3,0
		.byte	4,1,A3,0
		.byte	4,7,%00100000,10,%00110011,%01110100
		.byte	1,D3,2,G1,3,B3,0
		.byte	0
		.byte	0
		.byte	5,2,FS1,0
		.byte	0
		.byte	0
		.byte	4,1,G3,5,2,E1,6,3,C4,0
		.byte	0
		.byte	0
		.byte	4,1,B3,5,2,D1,6,3,D4,0
		.byte	0
		.byte	0
		.byte	5,2,G1,0
		.byte	0
		.byte	0
		.byte	4,1,D3,5,2,B0,6,3,B3,0
		.byte	0
		.byte	0
		.byte	4,1,E3,5,2,C1,6,3,A3,0
		.byte	6,3,B3,0
		.byte	6,3,C4,0
		.byte	4,1,D3,5,2,D0,6,3,B3,0
		.byte	0
		.byte	0
		.byte	4,1,C3,6,3,A3,0
		.byte	0
		.byte	0
		.byte	4,5,6,3,G3,255

