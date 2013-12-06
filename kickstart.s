;
; kickstart.s
;
; load the rest of the demo
;

.include "fastload.inc"

.import amigados
.import __AMIGADOS_LOAD__

.segment "KICKSTART"

		.word	$0801
                .word   bs_next
                .word   $17		; 23
                .byte   $9E		; SYS
                .byte	"2062", 0
                .byte	0
bs_next:	.word   0

loader:
		jsr	initfastload
		lda	#' '
		sta	fl_filename
		lda	#' '
		sta	fl_filename+1
		lda	#<__AMIGADOS_LOAD__
		sta	fl_loadaddr
		lda	#>__AMIGADOS_LOAD__
		sta	fl_loadaddr+1
		jsr	fastload
                sei
                lda     #$4c
                sta     loader
                lda     #<amigados
                sta     loader+1
                lda     #>amigados
                sta     loader+2
                cli
		jmp	amigados

; vim: et:si:ts=8:sts=8:sw=8
