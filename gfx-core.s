;
; basic gfx-functions and global variables
;

.include "vic.inc"

.export gfx_init
.export gfx_done
.export gfx_setviewpage
.export gfx_setdrawpage
.export gfx_setcolor
.export gfx_clear
.export	gfx_coreplot
.export gfx_plot

.export PLOT_XL
.export PLOT_XH
.export PLOT_Y
.export PLOT_MODE

PLOT_XL		= $fa
PLOT_XH		= $fb
PLOT_Y		= $fc
PLOT_MODE	= $f9

.data
gfx_drawpage:	.byte	$e0
gfx_colpage:	.byte	$cc
gfx_tabhptr:	.word	gfx_tabh0

.code
gfx_init:
		lda	CIA2_DATA_A
		and	#%11111100
		sta	CIA2_DATA_A
		lda	VIC_CTL1
		ora	#%00100000
		sta	VIC_CTL1
		lda	VIC_MEMCTL
		and	#%00111111
		ora	#%00111000
		sta	VIC_MEMCTL
		rts

gfx_done:
		lda	CIA2_DATA_A
		ora	#%00000011
		sta	CIA2_DATA_A
		lda	VIC_CTL1
		and	#%11011111
		sta	VIC_CTL1
		lda	VIC_MEMCTL
		and	#%00010111
		sta	VIC_MEMCTL
		rts

gfx_setviewpage:
		bne	vp_1
		lda	CIA2_DATA_A
		and	#$FE
		sta	CIA2_DATA_A
		rts
vp_1:		lda	CIA2_DATA_A
		ora	#$01
		sta	CIA2_DATA_A
		rts

gfx_setdrawpage:
		bne	dp_1
		lda	#$e0
		sta	gfx_drawpage
		lda	#$dc
		sta	gfx_colpage
		lda	#<gfx_tabh0
		sta	gfx_tabhptr
		lda	#>gfx_tabh0
		sta	gfx_tabhptr+1
		rts
dp_1:		lda	#$a0
		sta	gfx_drawpage
		lda	#$8c
		sta	gfx_colpage
		lda	#<gfx_tabh1
		sta	gfx_tabhptr
		lda	#>gfx_tabh1
		sta	gfx_tabhptr+1
		rts

gfx_setcolor:
		stx	$9e
		asl	a
		asl	a
		asl	a
		asl	a
		adc	$9e
		ldx	gfx_colpage
		stx	$9f
		ldy	#0
		sty	$9e
		ldx	#$34
		sei
		stx	$01
		ldx	#$04
sc_loop:	sta	($9e),y
		iny
		bne	sc_loop
		inc	$9f
		dex
		bne	sc_loop
		ldx	#$37
		stx	$01
		cli
		rts

gfx_clear:
		lda	#0
		tay
		sta	$9e
		ldx	gfx_drawpage
		stx	$9f
		ldx	#$20
cl_loop:	sta	($9e),y
		iny
		bne	cl_loop
		inc	$9f
		dex
		bne	cl_loop
		rts

gfx_coreplot:
		lda	gfx_tabhptr
		sta	cp_addh+1
		lda	gfx_tabhptr+1
		sta	cp_addh+2
		ldx	PLOT_Y
		ldy	PLOT_XL
		tya
		and	#$f8
		clc
		adc	gfx_tabl,x
		sta	$9e
		lda	PLOT_XH
cp_addh:	adc	$FFFF,x
		sta	$9f
		lda	gfx_bits,y
		ldy	#0
		bit	PLOT_MODE
		bvs	cp_set
		bmi	cp_inv
cp_del:		eor	#$ff
		and	($9e),y
		sta	($9e),y
		rts
cp_set:		ora	($9e),y
		sta	($9e),y
		rts
cp_inv:		eor	($9e),y
		sta	($9e),y
		rts

gfx_plot:
		lda	#$34
		sei
		sta	$01
		jsr	gfx_coreplot
		lda	#$37
		sta	$01
		cli
		rts

.rodata
gfx_tabl:	.byte	$00,$01,$02,$03,$04,$05,$06,$07
		.byte	$40,$41,$42,$43,$44,$45,$46,$47
		.byte	$80,$81,$82,$83,$84,$85,$86,$87
		.byte	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
		.byte	$00,$01,$02,$03,$04,$05,$06,$07
		.byte	$40,$41,$42,$43,$44,$45,$46,$47
		.byte	$80,$81,$82,$83,$84,$85,$86,$87
		.byte	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
		.byte	$00,$01,$02,$03,$04,$05,$06,$07
		.byte	$40,$41,$42,$43,$44,$45,$46,$47
		.byte	$80,$81,$82,$83,$84,$85,$86,$87
		.byte	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
		.byte	$00,$01,$02,$03,$04,$05,$06,$07
		.byte	$40,$41,$42,$43,$44,$45,$46,$47
		.byte	$80,$81,$82,$83,$84,$85,$86,$87
		.byte	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
		.byte	$00,$01,$02,$03,$04,$05,$06,$07
		.byte	$40,$41,$42,$43,$44,$45,$46,$47
		.byte	$80,$81,$82,$83,$84,$85,$86,$87
		.byte	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
		.byte	$00,$01,$02,$03,$04,$05,$06,$07
		.byte	$40,$41,$42,$43,$44,$45,$46,$47
		.byte	$80,$81,$82,$83,$84,$85,$86,$87
		.byte	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
		.byte	$00,$01,$02,$03,$04,$05,$06,$07

gfx_tabh0:	.byte	$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
		.byte	$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1
		.byte	$E2,$E2,$E2,$E2,$E2,$E2,$E2,$E2
		.byte	$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3
		.byte	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
		.byte	$E6,$E6,$E6,$E6,$E6,$E6,$E6,$E6
		.byte	$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
		.byte	$E8,$E8,$E8,$E8,$E8,$E8,$E8,$E8
		.byte	$EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
		.byte	$EB,$EB,$EB,$EB,$EB,$EB,$EB,$EB
		.byte	$EC,$EC,$EC,$EC,$EC,$EC,$EC,$EC
		.byte	$ED,$ED,$ED,$ED,$ED,$ED,$ED,$ED
		.byte	$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF
		.byte	$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
		.byte	$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1
		.byte	$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2
		.byte	$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4
		.byte	$F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5
		.byte	$F6,$F6,$F6,$F6,$F6,$F6,$F6,$F6
		.byte	$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7
		.byte	$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9
		.byte	$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA
		.byte	$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB
		.byte	$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
		.byte	$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE

gfx_tabh1:	.byte	$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		.byte	$A1,$A1,$A1,$A1,$A1,$A1,$A1,$A1
		.byte	$A2,$A2,$A2,$A2,$A2,$A2,$A2,$A2
		.byte	$A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3
		.byte	$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5
		.byte	$A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
		.byte	$A7,$A7,$A7,$A7,$A7,$A7,$A7,$A7
		.byte	$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
		.byte	$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
		.byte	$AB,$AB,$AB,$AB,$AB,$AB,$AB,$AB
		.byte	$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC
		.byte	$AD,$AD,$AD,$AD,$AD,$AD,$AD,$AD
		.byte	$AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF
		.byte	$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
		.byte	$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
		.byte	$B2,$B2,$B2,$B2,$B2,$B2,$B2,$B2
		.byte	$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4
		.byte	$B5,$B5,$B5,$B5,$B5,$B5,$B5,$B5
		.byte	$B6,$B6,$B6,$B6,$B6,$B6,$B6,$B6
		.byte	$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7
		.byte	$B9,$B9,$B9,$B9,$B9,$B9,$B9,$B9
		.byte	$BA,$BA,$BA,$BA,$BA,$BA,$BA,$BA
		.byte	$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB
		.byte	$BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC
		.byte	$BE,$BE,$BE,$BE,$BE,$BE,$BE,$BE

gfx_bits:	.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
		.byte	$80,$40,$20,$10,$08,$04,$02,$01
