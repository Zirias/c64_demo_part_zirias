;
; line drawing
;
; 14/11/2005 Felix M. Palmen <fmp@palmen.homeip.net>

; Parameters for gfx_plot, first point of line, counted by gfx_line
.importzp PLOT_XL
.importzp PLOT_XH
.importzp PLOT_Y
.importzp PLOT_MODE

; gfx_plot function
.import gfx_plot

.export gfx_coreline
.export gfx_line

; input parameters, endpoint of line
.export	LINETO_XL
.export LINETO_XH
.export LINETO_Y

LINETO_XL	= $8b
LINETO_XH	= $8c
LINETO_Y	= $8d

; Distances x and y
DXL		= $8e
DXH		= $8f
DY		= $fd

; temporary distance difference for line algorithm
DTL		= $b5
DTH		= $b6

; counter
; *** weird semantics:
; *** (0,0) means 256 to go
; *** CNTL is decreased AFTER each plot and tested for 0, then (only then)
; *** CNTH is decreased.
; *** so, (0,1) means last point to plot.
CNTL		= $b7
CNTH		= $b8

; opcodes for DEC and INC in Zero-Page
; needed for self-modification in order to handle upwards and downwards
; lines with the same routine
ZPDEC		= $C6
ZPINC		= $E6

.code

; gfx_coreline:
; expects (x1,y1) in PLOT_*
;         (x2,y2) in LINETO_*
;	  x2 MUST be >= x1

gfx_coreline:
		lda	LINETO_XL	; compute
		sec			; DX
		sbc	PLOT_XL		
		sta	DXL
		lda	LINETO_XH
		sbc	PLOT_XH
		sta	DXH

		lda	LINETO_Y	; compute
		sec			; DY
		sbc	PLOT_Y		;
		bcs	cl_down		; y2 < y1? {
		lda	#ZPDEC		;   load opcode for DEC
		sta	cl_incdec1	;   and use DEC for counting
		sta	cl_incdec2	;   in y-direction
		lda	PLOT_Y		;   compute
		sec			;   DY
		sbc	LINETO_Y	;
		sta	DY		; 
		bcs	cl_cont		; } // bra
cl_down:	sta	DY		; else {
		lda	#ZPINC		;   load opcode for INC
		sta	cl_incdec1	;   use INC for counting
		sta	cl_incdec2	;   in y-direction
					; }
cl_cont:	lda	DXH		; highbyte of DX
		bne	cl_x		; not 0 -> DX > DY
		lda	DXL		; lowbyte of DX
		sec			;
		sbc	DY		; subtract DY
		bcs	cl_x		; positive? -> DX > DY

cl_y:		lda	DY		; load DY
		lsr	a		; 
		sta	DTL		; DT = DY/2
		ldx	DY		; initialize counter
		inx			;
		stx	CNTL		; with DY + 1
cl_y_l:		jsr	gfx_plot	; draw a point
cl_incdec1:	dec	PLOT_Y		; count in y-direction
		dec	CNTL		; decrease counter
		bne	cl_y_c1		; not yet zero -> go on
		rts			; *** done ***
cl_y_c1:	lda	DTL		; lowbyte DT
		sec			;
		sbc	DXL		; subtract DX
		sta	DTL		;
		bcs	cl_y_l		; underrun? then
		adc	DY		; add DY
		sta	DTL		;
		inc	PLOT_XL		; and increase X
		bne	cl_y_l		; "next"
		inc	PLOT_XH		; high-byte when necessary
		bne	cl_y_l		; "next"

cl_x:		lda	DXH		;
		clc			;
		lsr	a		;
		sta	DTH		; DT = DX/2
		lda	DXL		;
		lsr	a		;
		sta	DTL		;
		ldx	DXL		;
		inx
		stx	CNTL		; initialize counter
		lda	DXH		; with DX +1
		sta	CNTH		;
cl_x_l:		jsr	gfx_plot	; draw a point
		inc	PLOT_XL		; count in x-direction
		bne	cl_x_c1		;
		inc	PLOT_XH		; count highbyte when necessary
cl_x_c1:	dec	CNTL		; decrease
		bne	cl_x_c2		; counter
		dec	CNTH		; (highbyte)
		bpl	cl_x_c2		; until zero
		rts			; *** done ***
cl_x_c2:	lda	DTL		; lowbyte DT
		sec			;
		sbc	DY		; subtract DY
		sta	DTL		;
		bcs	cl_x_l		; no underrun -> "next"
		lda	DTH		; highbyte
		sbc	#0		; subtract "carry"
		sta	DTH		;
		bcs	cl_x_l		; no underrun -> "next"
		lda	DTL		; lowbyte DT
		adc	DXL		; add lowbyte DX
		sta	DTL		;
		lda	DTH		; highbyte DT
		adc	DXH		; add highbyte DX
		sta	DTH		;
cl_incdec2:	dec	PLOT_Y		; count in y-direction
		bne	cl_x_l		; "next"
		bpl	cl_x_l		; "next"


; gfx_line
; wraps gfx_coreline for application use
; expects (x1,y1) in PLOT_*
;         (x2,y2) in LINETO_*

gfx_line:
		lda	LINETO_XL	; compare
		sec			; x1 and x2
		sbc	PLOT_XL		;
		lda	LINETO_XH	;
		sbc	PLOT_XH		;
		bcs	gl_ok		; x2 >= x1 -> ok
		lda	LINETO_XL	; else
		ldx	PLOT_XL		; swap (x1,y1)
		sta	PLOT_XL		; and (x2,y2)
		stx	LINETO_XL	;
		lda	LINETO_XH	;
		ldx	PLOT_XH		;
		sta	PLOT_XH		;
		stx	LINETO_XH	;
		lda	LINETO_Y	;
		ldx	PLOT_Y		;
		sta	PLOT_Y		;
		stx	LINETO_Y	;
gl_ok:		jsr	gfx_coreline	; call gfx_coreline
		rts

